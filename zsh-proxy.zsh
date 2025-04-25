#!/bin/zsh

# ---------------------------------------------------------------------------
#  Lightweight proxy‑helper for zsh (macOS‑aware)
# ---------------------------------------------------------------------------
#  Highlights
#  ──────────
#  •   One zstyle key per proxy kind → full URI (http://host:port or socks5://host:port)
#  •   Automatically mirrors lowercase → uppercase env vars (http_proxy → HTTP_PROXY …)
#  •   One‑shot setters now **toggle**: give a URI to set, call with no arg to unset.
#  •   Works with the original macOS helpers that ship functions:
#        _get_active_network_service  _get_proxy_settings  _get_no_proxy
#    If these exist but **_get_combined_proxy** does *not*, we shim it at runtime.
# ---------------------------------------------------------------------------

# --- Plugin Core -----------------------------------------------------------

# Locate plugin root & per‑OS function dir
typeset -g _zsh_proxy_plugin_dir=${0:A:h}
typeset -g _zsh_proxy_functions_dir="${_zsh_proxy_plugin_dir}/functions"

# --- OS helper sourcing ----------------------------------------------------

typeset -g _zsh_proxy_os_funcs_loaded=0
typeset -g _zsh_proxy_os_type="unknown"

if [[ "$OSTYPE" == darwin* ]]; then
  _zsh_proxy_os_type="osx"
  local os_func_file="${_zsh_proxy_functions_dir}/osx.zsh"
  if [[ -f "$os_func_file" ]]; then
    source "$os_func_file"
    # Shim _get_combined_proxy when absent.
    if ! typeset -f _get_combined_proxy >/dev/null && \
       typeset -f _get_proxy_settings  >/dev/null && \
       typeset -f _get_active_network_service >/dev/null; then
      _get_combined_proxy() {
        local _kind="$1" _ns="$(_get_active_network_service)"; [[ -z "$_ns" ]] && return
        typeset -A _ps; eval "_ps=($(_get_proxy_settings $_kind $_ns))"
        [[ "${_ps[Enabled]}" != "Yes" || -z "${_ps[Server]}" || -z "${_ps[Port]}" ]] && return
        local _proto="http"; [[ "$1" == "socksfirewall" ]] && _proto="socks5"
        print -- "${_proto}://${_ps[Server]}:${_ps[Port]}"
      }
    fi
    if typeset -f _get_combined_proxy >/dev/null && \
       typeset -f _get_no_proxy >/dev/null; then
      _zsh_proxy_os_funcs_loaded=1
    fi
  fi
fi

# --- INTERNAL helpers ------------------------------------------------------

_set_env() {
  local _var="$1" _val="$2"
  [[ -z "$_val" ]] && return
  export "${_var}=${_val}"
  case "$_var" in
    http_proxy)  export HTTP_PROXY="$_val"  ;;
    https_proxy) export HTTPS_PROXY="$_val" ;;
    all_proxy)   export ALL_PROXY="$_val"   ;;
  esac
}

_unset_env() {
  unset "$1"
  case "$1" in
    http_proxy)  unset HTTP_PROXY  ;;
    https_proxy) unset HTTPS_PROXY ;;
    all_proxy)   unset ALL_PROXY   ;;
    no_proxy)    unset NO_PROXY    ;;
  esac
}

_set_git()   { git config --global "$1" "$2" &>/dev/null }
_unset_git() { git config --global --unset "$1" &>/dev/null || true }

# --- PUBLIC one‑shot setters (toggle behaviour) ---------------------------
set_http_proxy()  { [[ -n "$1" ]] && _set_env http_proxy  "$1" || _unset_env http_proxy; }
set_https_proxy() { [[ -n "$1" ]] && _set_env https_proxy "$1" || _unset_env https_proxy; }
set_socks_proxy() { [[ -n "$1" ]] && _set_env all_proxy   "$1" || _unset_env all_proxy; }
set_no_proxy()    { [[ -n "$1" ]] && export no_proxy="$1" NO_PROXY="$1" || _unset_env no_proxy; }
set_git_http_proxy()  { [[ -n "$1" ]] && _set_git http.proxy  "$1" || _unset_git http.proxy; }
set_git_https_proxy() { [[ -n "$1" ]] && _set_git https.proxy "$1" || _unset_git https.proxy; }

# --- Main public entry -----------------------------------------------------
proxy() {
  local zs_http zs_https zs_socks zs_all zs_no_proxy zs_git_http zs_git_https
  zstyle -s ':plugin:proxy'     http_proxy  zs_http
  zstyle -s ':plugin:proxy'     https_proxy zs_https
  zstyle -s ':plugin:proxy'     socks_proxy zs_socks
  zstyle -s ':plugin:proxy'     all_proxy   zs_all
  zstyle -s ':plugin:proxy'     no_proxy    zs_no_proxy
  zstyle -s ':plugin:proxy:git' http_proxy  zs_git_http
  zstyle -s ':plugin:proxy:git' https_proxy zs_git_https

  local os_http="" os_https="" os_socks="" os_no=""
  if (( _zsh_proxy_os_funcs_loaded )); then
    os_http=$(_get_combined_proxy web)
    os_https=$(_get_combined_proxy secureweb)
    os_socks=$(_get_combined_proxy socksfirewall)
    os_no=$(_get_no_proxy)
  fi

  local http_uri="${zs_http:-${zs_all:-$os_http}}"
  local https_uri="${zs_https:-${zs_all:-${zs_http:-$os_https}}}"
  local socks_uri="${zs_socks:-${zs_all:-$os_socks}}"

  set_http_proxy  "$http_uri"
  set_https_proxy "$https_uri"
  set_socks_proxy "$socks_uri"

  set_no_proxy "${zs_no_proxy:-$os_no}"

  set_git_http_proxy  "${zs_git_http:-$http_uri}"
  set_git_https_proxy "${zs_git_https:-$https_uri}"
}

noproxy() {
  _unset_env http_proxy https_proxy all_proxy no_proxy
  _unset_git http.proxy https.proxy
}

# --- Auto‑run on load? -----------------------------------------------------
if zstyle -t ':plugin:proxy' auto; then proxy; fi

# --- List proxy environment variables ---------------------------------------
list_proxy() {
  echo "http_proxy=$http_proxy"
  echo "https_proxy=$https_proxy"
  echo "all_proxy=$all_proxy"
  echo "no_proxy=$no_proxy"
  echo "HTTP_PROXY=$HTTP_PROXY"
  echo "HTTPS_PROXY=$HTTPS_PROXY"
  echo "ALL_PROXY=$ALL_PROXY"
  echo "NO_PROXY=$NO_PROXY"
  echo "git.http.proxy=$(git config --global --get http.proxy)"
  echo "git.https.proxy=$(git config --global --get https.proxy)"
}

# --- Export wrappers -------------------------------------------------------
typeset -f +x proxy noproxy list_proxy \
              set_http_proxy set_https_proxy set_socks_proxy set_no_proxy \
              set_git_http_proxy set_git_https_proxy &>/dev/null
