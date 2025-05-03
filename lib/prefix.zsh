_proxy_prefix() {
  local var=$1 val=$2

  if [[ -z "$val" ]]; then
    printf 'Error: no proxy target provided\n' >&2
    return 1
  fi

  zstyle -s ':plugin:proxy:prefix' http  http_prefix \
    || http_prefix=http
  zstyle -s ':plugin:proxy:prefix' https https_prefix \
    || https_prefix=http
  zstyle -s ':plugin:proxy:prefix' all   all_prefix \
    || all_prefix=socks5

  case "$var" in
    http)
      # if it lacks any scheme, prefix http://
      [[ "$val" == *://* ]] || val="$http_prefix://$val"
      ;;
    https)
      # if it lacks any scheme, prefix https://
      [[ "$val" == *://* ]] || val="$https_prefix://$val"
      ;;
    all)
      # if it lacks any scheme, prefix socks5://
      [[ "$val" == *://* ]] || val="$all_prefix://$val"
      ;;
    *)
      printf 'Error: unknown proxy kind %q\n' "$var" >&2
      return 2
      ;;
  esac

  print -r -- "$val"
}
