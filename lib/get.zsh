local lib_dir="${0:A:h}"
local os=${OSTYPE%%[0-9._/-]*}

if zstyle -t ':plugin:proxy' auto; then
  local os_helper="${lib_dir}/os/${os}.zsh"
  [[ -f $os_helper ]] && source "$os_helper"
fi

[[ -f "${lib_dir}/prefix.zsh" ]] && source "${lib_dir}/prefix.zsh"

_zsh_proxy_get_proxy() {
  local type="$1"
  local os_proxy zs_proxy proxy
  typeset -f _get_combined_proxy >/dev/null && os_proxy="$(_get_combined_proxy "$type")"
  zstyle -s ':plugin:proxy' $type zs_proxy
  proxy=${zs_proxy:-$os_proxy}

  if [[ $type != "no" && -n $proxy ]]; then
    typeset -f _proxy_prefix >/dev/null && proxy=$(_proxy_prefix "$type" "$proxy")
  fi

  print -r -- "${proxy}"
}
