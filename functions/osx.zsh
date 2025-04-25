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
_get_noproxy() {
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

# Ensure functions are available if sourced directly (less critical now)
# typeset -f +x _get_active_network_service _parse_networksetup_output _get_proxy_settings _get_no_proxy &>/dev/null
