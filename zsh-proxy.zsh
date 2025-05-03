_zsh_proxy_lib_dir="${0:A:h}/lib"
_zsh_proxy_plugins_dir="${0:A:h}/plugins"

zstyle -a ':plugin:proxy' type _zsh_proxy_types \
  || _zsh_proxy_types=(http https all no)

[[ -f "${_zsh_proxy_lib_dir}/get.zsh" ]] && source "${_zsh_proxy_lib_dir}/get.zsh"

typeset -A _zsh_proxy_get
if typeset -f _zsh_proxy_get_proxy >/dev/null; then
  for type in "${_zsh_proxy_types[@]}"; do
    # Ensure the function returns something before assigning
    local proxy_val="$(_zsh_proxy_get_proxy "${type}")"
    if [[ -n "$proxy_val" ]]; then
        _zsh_proxy_get["${type}"]="$proxy_val"
    fi
  done
fi

zstyle -a ':plugin:proxy' plugins _zsh_proxy_plugins \
  || _zsh_proxy_plugins=(shell)

for plugin in "${_zsh_proxy_plugins[@]}"; do
  local plugin_file="${_zsh_proxy_plugins_dir}/${plugin}/${plugin}.plugin.zsh"
  if [[ -f "$plugin_file" ]]; then
    source "$plugin_file"
  else
    # Optional: Warn if a configured plugin file is missing
    print -u2 "Warning: Plugin file not found: $plugin_file"
  fi
done

proxy() {
  local plugin type fn
  for plugin in "${_zsh_proxy_plugins[@]}"; do
    for type in "${_zsh_proxy_types[@]}"; do
      fn="_set_${plugin}_proxy"
      # Check if function exists before calling
      if typeset -f "$fn" >/dev/null; then
        # Call function directly using the variable 'fn'
        "$fn" "$type" "${_zsh_proxy_get["$type"]}"
      fi
    done
  done
}

proxys() {
  # Associative array to store results: Key="plugin:type", Value="proxy_data"
  typeset -A proxy_results

  local plugin type fn result
  for plugin in "${_zsh_proxy_plugins[@]}"; do
    fn="_get_${plugin}_proxy" # Construct function name
    if typeset -f "$fn" >/dev/null; then # Check if function exists
      for type in "${_zsh_proxy_types[@]}"; do
        # Call the specific plugin function and capture its output
        result=$("$fn" "$type")

        # If the function returned something, store it
        if [[ -n "$result" ]]; then
          proxy_results["${plugin}:${type}"]="$result"
        fi
      done
    fi
  done

  for plugin in "${_zsh_proxy_plugins[@]}"; do
    print -r -- "$plugin"
    for type in "${_zsh_proxy_types[@]}"; do
      [[ -n "${proxy_results["${plugin}:${type}"]}" ]] && print -r -- "$type: ${proxy_results["${plugin}:${type}"]}"
    done
  done
}

noproxy() {
  local plugin type fn
  for plugin in "${_zsh_proxy_plugins[@]}"; do
    for type in "${_zsh_proxy_types[@]}"; do
      fn="_unset_${plugin}_proxy"
      if typeset -f "$fn" >/dev/null; then
        "$fn" "$type"
      fi
    done
  done
}

set_proxy() {
  local plugin=$1 type=$2 proxy=$3 fn="_set_${plugin}_proxy"
  if typeset -f "$fn" >/dev/null; then
    "$fn" "$type" "$proxy"
  fi
}

unset_proxy() {
  local plugin=$1 type=$2 fn="_unset_${plugin}_proxy"
  if typeset -f "$fn" >/dev/null; then
    "$fn" "$type"
  fi
}

proxy

typeset -f +x proxy proxys noproxy set_proxy unset_proxy &>/dev/null
