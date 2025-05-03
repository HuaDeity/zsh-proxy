# zsh-proxy

A lightweight, cross-platform helper that automates *and* simplifies proxy configuration from your **zsh** session.

```
macOS • Linux • WSL • Any system with zsh & Git •
```

---

## Features

* **Auto-detect** system proxies on macOS (falls back gracefully on other OSes)
* **One zstyle per proxy kind** — provide full URIs, no more server/port pairs
* Mirrors lowercase ↔ uppercase env vars (`http_proxy` → `HTTP_PROXY`, etc.)
* **Toggle setters** — call `set_http_proxy <uri>` to set, call with *no arg* to unset
* Git integration (`http.proxy`, `https.proxy`) follows the same precedence

---

## Requirements

* `zsh` 5.0 or later
* [`git`](https://git-scm.com/) if you want Git proxy auto-config
* On macOS: network proxies should be configured in **System Settings → Network** (the plugin reads them via native commands)

> **Note**: No external dependencies or Python/Ruby helpers — pure zsh.

---

## Installation

### Manual

```bash
git clone https://github.com/huadeity/zsh-proxy.git ${ZDOTDIR}/plugins/zsh-proxy
echo 'source ${ZDOTDIR}/plugins/zsh-proxy/zsh-proxy.zsh'
```

### [Antidote](https://antidote.sh)

`antidote install huadeity/zsh-proxy`

### [Zim](https://zimfw.sh)

`zmodule huadeity/zsh-proxy`

### [Zcomet](https://zcomet.io)

`zcomet load huadeity/zsh-proxy`

### [Zgenom](https://github.com/jandamm/zgenom)

`zgenom load huadeity/zsh-proxy`

### [Oh-My-Zsh](https://ohmyz.sh)

```bash
# Inside custom plugins dir
git clone https://github.com/huadeity/zsh-proxy.git \
      ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-proxy

# ~/.zshrc
plugins=( ... zsh-proxy )
```

---

## Quick start

```zsh
proxy     # auto-configure from zstyle → OS → unset fallback
noproxy   # clear everything (env + Git)
```

### Manual setters (toggle)

| Function               | Action                                                  |
|-----------------------|---------------------------------------------------------|
| `set_http_proxy` URI  | Set `http_proxy` / `HTTP_PROXY`                        |
| **(call with no arg)**| Unset them                                             |
| `set_https_proxy` URI | Set `https_proxy` / `HTTPS_PROXY`                      |
| `set_socks_proxy` URI | Set `all_proxy` / `ALL_PROXY` (expects `socks5://…`)   |
| `set_no_proxy` LIST   | Set `no_proxy` / `NO_PROXY` (comma-separated list)     |
| `set_git_http_proxy` URI  | `git config --global http.proxy`                   |
| `set_git_https_proxy` URI | `git config --global https.proxy`                 |
| `list_proxy` | List setting proxy |

### Sample zstyle config

```zsh
# ~/.zshrc or ~/.zshenv
zstyle ':plugin:proxy'        http    '192.168.1.2:7890'
zstyle ':plugin:proxy'        https   '192.168.1.2:7890'
zstyle ':plugin:proxy'        socks   '127.0.0.1:8888'
zstyle ':plugin:proxy'        mixed   '127.0.0.1:8888'
zstyle ':plugin:proxy'        no      'localhost,127.0.0.1,.internal'

# Git can use a different endpoint if desired
zstyle ':plugin:proxy:git'    http    'git-proxy.company.com:8080'
zstyle ':plugin:proxy:git'    https   'git-proxy.company.com:8080'

# Run automatically on shell startup
zstyle ':plugin:proxy'        auto         yes   # default: no
```

Call `proxy` manually at any time to reload settings.

---

## How it works

1. **zstyle lookup**—User-defined URIs for each proxy kind have highest priority.
2. **macOS system proxy**—When on macOS & helper functions available, the plugin queries the active network service for `web`, `secureweb`, and `socksfirewall` proxies.
3. **Fallback**: If nothing is found, environment variables are unset.
4. **Git**: `git config --global http(s).proxy` is kept in sync with the chosen URIs (or removed when proxies are unset).

Everything is handled in pure zsh — no forks unless Git commands are needed.

---

## Recent Updates

- **Update to New Level (2025-05-03)**: Enhanced functionality and performance improvements as per the latest commit. Check the plugins directory for updated or new proxy management features.

---

## Contributing

Pull requests are welcome! Feel free to improve Linux/WSL auto-detection, add tests for other shells, or polish the README.

---

## License

MIT
