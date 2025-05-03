# Git Plugin for zsh-proxy

This plugin extends the functionality of zsh-proxy to integrate seamlessly with Git. It allows for automatic configuration of Git proxy settings based on the zsh-proxy environment.

## Features

- Synchronizes Git `http.proxy` and `https.proxy` settings with zsh-proxy configurations.
- Supports custom proxy settings for Git through zstyle configurations.

## Usage

Ensure that the zsh-proxy plugin is installed and configured. The Git plugin will automatically apply proxy settings to Git operations based on the defined zstyle rules for `:plugin:proxy:git`.

## Configuration

You can configure Git-specific proxy settings in your `.zshrc` or `.zshenv` file:

```zsh
zstyle ':plugin:proxy:git' http 'git-proxy.company.com:8080'
zstyle ':plugin:proxy:git' https 'git-proxy.company.com:8080'
```

## License

MIT
