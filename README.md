# Neovim Configuration

My personal nvim configuration built on top of nvchad

---

## Languages & Stacks

| Language / Stack | LSP | Formatter | Linter | Debugger |
|---|---|---|---|---|
| JavaScript / JSX | ts_ls + biome | biome | biome | js-debug-adapter |
| TypeScript / TSX | ts_ls + biome | biome | biome | js-debug-adapter |
| React / Next.js | ts_ls + biome | biome | biome | js-debug-adapter |
| Go | gopls | gofumpt + goimports + golines | gopls | delve |
| Rust | rust-analyzer (rustaceanvim) | rustfmt | clippy | codelldb |
| Python | pyright + ruff | ruff | ruff | debugpy |
| C / C++ | clangd | clang-format | clangd | codelldb |
| Swift / SwiftUI | sourcekit-lsp | swiftformat | sourcekit-lsp | codelldb |
| Scala | metals (nvim-metals) | scalafmt | metals | metals (built-in) |
| Lua | lua_ls | stylua | lua_ls | — |
| HTML | html-lsp + emmet | biome | — | — |
| CSS / SCSS | cssls + tailwindcss | biome | — | — |
| JSON / JSONC | jsonls | biome | jsonls | — |
| YAML | yamlls | prettierd | yamlls | — |
| Markdown | marksman | prettierd | — | — |
| Svelte | svelte-ls | prettierd | — | — |
| Elixir / HEEx | elixir-ls + tailwindcss | mix | — | — |

---

## Features

### Editor
- **NvChad v2.5** base — statusline, dashboard, themes, file explorer
- **Treesitter** syntax highlighting for all languages above
- **Auto-pairs**, **auto-tags** (nvim-ts-autotag), **Emmet** expansion
- **Inlay hints** enabled on attach for every supporting LSP
- **Format on save** via conform.nvim for all languages
- **Markdown inline rendering** (render-markdown.nvim — no browser needed)
- **Session persistence** — restore your last workspace on startup
- **Gruvbox** theme

### Git
- **Gitsigns** — inline blame, hunk preview, hunk navigation

### Debugging (DAP)
- **nvim-dap-ui** — full visual debugger: variables, call stack, breakpoints, watch, REPL
- Auto-opens/closes UI when a debug session starts and ends
- Language adapters: delve (Go), debugpy (Python), codelldb (Rust/C/C++/Swift), js-debug-adapter (JS/TS), metals built-in (Scala)

### Language-specific extras
- **rustaceanvim** — Clippy on save, proc macro support, Rust-specific hover actions
- **nvim-metals** — Scala metals with inferred types and implicit arguments
- **gopher.nvim** — Go struct tag generation (`<leader>gsj`, `<leader>gsy`)
- **nvim-dap-go** — Go test debugging
- **nvim-dap-python** — Python test and script debugging

### Productivity
- **LeetCode** — solve problems without leaving Neovim (`<leader>lr` run, `<leader>ls` submit)
- **WakaTime** — automatic time tracking
- **Timerly** — Pomodoro timer
- **OpenCode** — AI coding assistant integration
- **vim-tmux-navigator** — seamless pane navigation across Neovim and tmux

---

## Keymaps

### Debug (DAP)
| Key | Action |
|---|---|
| `F5` | Start / Continue |
| `F10` | Step over |
| `F11` | Step into |
| `F12` | Step out |
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>du` | Toggle debugger UI |
| `<leader>dx` | Terminate session |
| `<leader>dr` | Toggle REPL |
| `<leader>dgt` | Debug Go test |

### LSP
| Key | Action |
|---|---|
| `<leader>lf` | Floating diagnostic |
| `<leader>es` | Elixir insert @spec |

### Git
| Key | Action |
|---|---|
| `<leader>ph` | Preview hunk |
| `<leader>bl` | Blame line |
| `<leader>tb` | Toggle line blame |
| `<leader>gd` | Diff this |
| `]h` / `[h` | Next / previous hunk |

### Navigation
| Key | Action |
|---|---|
| `<leader>ff` | Find file |
| `<leader>fw` | Live grep |
| `<leader>fo` | Recent files |
| `<leader>v` | Vertical split |
| `<C-h/j/k/l>` | Navigate windows / tmux panes |

### Session
| Key | Action |
|---|---|
| `<leader>qs` | Restore session |
| `<leader>ql` | Restore last session |
| `<leader>qd` | Stop saving session |

### LeetCode
| Key | Action |
|---|---|
| `<leader>lr` | Run tests |
| `<leader>ls` | Submit solution |

---

## Prerequisites

| Tool | Install |
|---|---|
| Neovim ≥ 0.10 | `brew install neovim` |
| Git | `brew install git` |
| Node.js | `brew install node` (required by many LSPs) |
| Rust toolchain | `curl https://sh.rustup.rs -sSf \| sh` |
| Go | `brew install go` |
| Python 3 | `brew install python` |
| Coursier (Scala/Metals) | `brew install coursier/formulas/coursier && cs setup` |
| A [Nerd Font](https://www.nerdfonts.com/) | set as your terminal font |
| `ripgrep` | `brew install ripgrep` (required by Telescope live grep) |

---

## Installation

```bash
# Back up existing config if you have one
mv ~/.config/nvim ~/.config/nvim.bak

# Clone this config
git clone https://github.com/db-keli/neovim-configuration ~/.config/nvim

# Open Neovim — Lazy installs all plugins automatically on first launch
nvim
```

On first launch Lazy.nvim will install all plugins. Mason will then auto-install all LSP servers, formatters, and debug adapters listed in `chadrc.lua`.

After plugins are installed, update Treesitter parsers:

```vim
:TSUpdate
```

### Scala (Metals)

Metals is not installed via Mason — it requires Coursier:

```bash
brew install coursier/formulas/coursier && cs setup
```

Open any `.scala` or `.sbt` file and Metals will download itself automatically on first attach.

### Rust

Make sure `rustfmt` and `clippy` are available (they come with the standard toolchain):

```bash
rustup component add rustfmt clippy
```
