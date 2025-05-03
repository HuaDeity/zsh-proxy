typeset -a _zsh_proxy_shell_accept_type=(http https all no)

_set_shell_proxy() {
  local _proto="$1"
  
  # Check if protocol is in accepted types
  (( ${_zsh_proxy_shell_accept_type[(I)$_proto]} )) || return 0
  
  local _var="${_proto}_proxy" _val="$2"
  local _low="$_var" up="${_var:u}"
  export "${_low}=${_val}"
  export "${up}=${_val}"
}

_unset_shell_proxy() {
  local _proto="$1"
  
  # Check if protocol is in accepted types
  (( ${_zsh_proxy_shell_accept_type[(I)$_proto]} )) || return 0
  
  local _var="${_proto}_proxy" _val="$2"
  local _low="$_var" up="${_var:u}"
  unset "${_low}"
  unset "${up}"
}

_get_shell_proxy() {
  local _proto="$1"
  
  # Check if protocol is in accepted types
  (( ${_zsh_proxy_shell_accept_type[(I)$_proto]} )) || return ""
  
  local _var="${_proto}_proxy"
  local _low_var="$_var" _up_var="${_var:u}"
  # Use parameter expansion P for indirect reference
  local _low_val="${(P)_low_var}" _up_val="${(P)_up_var}"
  local result=""

  if [[ -n "$_low_val" && -n "$_up_val" ]]; then
    # Both are set
    if [[ "$_low_val" == "$_up_val" ]]; then
      result="$_low_val" # They are the same
    else
      result="${_low_val}|${_up_val}" # They differ, use separator
    fi
  elif [[ -n "$_low_val" ]]; then
    # Only lowercase is set
    result="$_low_val"
  elif [[ -n "$_up_val" ]]; then
    # Only uppercase is set
    result="$_up_val"
  fi
  # If neither was set, result remains ""

  print -r -- "$result" # Output the result or empty string
}
