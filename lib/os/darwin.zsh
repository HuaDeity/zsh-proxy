# macOS specific proxy detection functions

# --- Generic Interface Implementation for macOS ---

# Get the primary network service name
_get_active_network_service() {
  # Using networksetup, specific to macOS
  networksetup -listallnetworkservices | grep -E 'Wi-Fi|AirPort|Ethernet|Display.' | head -1
}

# Parse networksetup output (macOS specific helper)
# Renamed for consistency, but still macOS-specific in implementation
_parse_networksetup_output() {
  local output="$1"
  typeset -A settings
  settings=( Server "" Port "" Enabled "No" )
  settings[Server]=$(echo "$output" | grep -oE '^Server: .*' | sed -E 's/^Server: //')
  settings[Port]=$(echo "$output" | grep -oE '^Port: .*' | sed -E 's/^Port: //')
  settings[Enabled]=$(echo "$output" | grep -oE '^Enabled: .*' | sed -E 's/^Enabled: //')
  # Return key-value pairs for capture
  print -r -- "${(kv)settings}"
}

# Get proxy settings (server, port, enabled) for a specific type
# Usage: typeset -A result; eval "result=($(_get_proxy_settings 'web' 'Wi-Fi'))"
_get_proxy_settings() {
  local proxy_command_type="$1" # e.g., "web", "secureweb", "socksfirewall"
  local network_service="$2"
  local proxy_info=""

  # Silently return disabled state if no service provided
  [[ -z "$network_service" ]] && print -r -- "${(kvp):-Enabled No}" && return 1

  # Use a subshell to suppress potential errors from networksetup (macOS specific)
  proxy_info=$( (
      case "$proxy_command_type" in
          web) networksetup -getwebproxy "$network_service" ;;
          secureweb) networksetup -getsecurewebproxy "$network_service" ;;
          socksfirewall) networksetup -getsocksfirewallproxy "$network_service" ;;
          *) return 1 ;; # Unknown type handled silently here
      esac
  ) 2>/dev/null ) # Suppress stderr from networksetup

  # Check if the command execution failed or produced no output
  if [[ $? -ne 0 || -z "$proxy_info" ]]; then
      print -r -- "${(kvp):-Enabled No}" # Return default disabled state
      return 1
  fi

  # Parse and return (using the macOS-specific helper)
  _parse_networksetup_output "$proxy_info"
}

# Get the bypass domain list (noproxy)
# Usage: local domains=$(_get_noproxy 'Wi-Fi')
_get_no_proxy() {
  local network_service="$1"
  local bypass_domains=""

  # Return empty string if no service
  [[ -z "$network_service" ]] && print -r -- "" && return 1

  # Fetch bypass domains using networksetup (macOS specific), suppress stderr
  bypass_domains=$(networksetup -getproxybypassdomains "$network_service" 2>/dev/null | tr '\n' ',')

  # Check if the command failed or returned the 'no domains' message or empty
  if [[ $? -ne 0 || "$bypass_domains" == *"There aren't any bypass domains"* || -z "$bypass_domains" ]]; then
      print -r -- "" # Return empty string
  else
      # Return comma-separated list (without trailing comma)
      print -r -- "${bypass_domains%,}"
  fi
}

_ns=$(_get_active_network_service); [[ -z "$_ns" ]] && return

_get_combined_proxy() {
  local _type="$1";
  if [[ $_type == "no" ]]; then
    print -r -- "$(_get_no_proxy "$_ns")"
  else
    local _kind
    case $_type in
      http)
        _kind="web"
        ;;
      https)
        _kind="secureweb"
        ;;
      all)
        _kind="socksfirewall"
        ;;
      *)
        return 1
        ;;
    esac
    # Get the proxy settings as raw output
    local _raw_settings
    _raw_settings="$(_get_proxy_settings "$_kind" "$_ns")"
    [[ $? -ne 0 || -z "$_raw_settings" ]] && return 1

    # Use safer pattern matching instead of eval
    local _server _port _enabled
    _server=$(echo "$_raw_settings" | grep -o 'Server [^[:space:]]*' | cut -d' ' -f2)
    _port=$(echo "$_raw_settings" | grep -o 'Port [^[:space:]]*' | cut -d' ' -f2)
    _enabled=$(echo "$_raw_settings" | grep -o 'Enabled [^[:space:]]*' | cut -d' ' -f2)

    # Check if we have all required values and if proxy is enabled
    if [[ "$_enabled" != "Yes" || -z "$_server" || -z "$_port" ]]; then
      return 1
    fi

    print -r -- "${_server}:${_port}"
  fi
}
