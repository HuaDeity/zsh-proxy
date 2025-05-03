# Git Plugin for zsh-proxy

This plugin extends the functionality of zsh-proxy to integrate seamlessly with Git. It allows for automatic configuration of Git proxy settings based on the zsh-proxy environment.

## Features

- Synchronizes Git `http.proxy` and `https.proxy` settings with zsh-proxy configurations.
- Supports custom proxy settings for Git through command line.

## When to Use
- Only if using Git GUI client(such as [Fork](https://fork.dev), as the CLI will inherit from Environment Variables.
- Note that the Git GUI client [Tower](https://www.git-tower.com) will automatically inherit from login shell environment variables.
