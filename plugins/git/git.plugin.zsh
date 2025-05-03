typeset -a _zsh_proxy_git_accept_type=(http https)

_set_git_proxy() {
  local _proto="$1"
  
  # Check if protocol is in accepted types
  (( ${_zsh_proxy_git_accept_type[(I)$_proto]} )) || return 0
  
  git config --global "$_proto.proxy" "$2" &>/dev/null
}

_unset_git_proxy() {
  local _proto="$1"
  
  # Check if protocol is in accepted types
  (( ${_zsh_proxy_git_accept_type[(I)$_proto]} )) || return 0
  
  git config --global --unset "$_proto.proxy" &>/dev/null || true
}

_get_git_proxy() {
  local _proto="$1"
  
  # Check if protocol is in accepted types
  (( ${_zsh_proxy_git_accept_type[(I)$_proto]} )) || return ""
  
  local _val="$(git config --global --get "$_proto.proxy" 2>/dev/null)"

  # Return the value or empty string
  print -r -- "$_val"
}
