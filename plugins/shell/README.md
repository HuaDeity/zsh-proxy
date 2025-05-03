# Shell Plugin for zsh-proxy

This plugin extends the functionality of zsh-proxy to manage shell environment proxy settings. It simplifies the process of setting and unsetting proxy variables in your zsh session.

## Features

- Automatically sets shell environment variables like `http_proxy`, `https_proxy`, and `all_proxy` based on zstyle configurations.
- Provides functions to toggle proxy settings on and off easily.

## Usage

Ensure that the zsh-proxy plugin is installed and configured. Use the provided functions to manage proxy settings directly from your shell:

```zsh
set_http_proxy <uri>  # Set HTTP proxy
set_https_proxy <uri> # Set HTTPS proxy
set_socks_proxy <uri> # Set SOCKS proxy (all_proxy)
noproxy              # Unset all proxy variables
```

## Configuration

Configure proxy settings in your `.zshrc` or `.zshenv` file using zstyle:

```zsh
zstyle ':plugin:proxy' http '192.168.1.2:7890'
zstyle ':plugin:proxy' https '192.168.1.2:7890'
zstyle ':plugin:proxy' socks '127.0.0.1:8888'
```

## License

MIT
