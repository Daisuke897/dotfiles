# Dotfiles

Personal configuration files for development environment and Emacs.

## Requirements
- [Nix](https://nixos.org/) with flakes enabled
- Emacs

## Usage

Apply the Home Manager configuration to install all shared tooling:

```bash
home-manager switch --flake .#daisuke@linux
```

On macOS (ARM):

```bash
home-manager switch --flake .#daisuke@mac
```

### Home Manager config

The Home Manager configuration now installs the same language servers, formatters, `uv`, `ruff`, and helper tools that the dev shell used to provide, plus `cfn-lint`, `rassumfrassum`, and the merged tree-sitter grammars needed by Emacs. It also exports `TREE_SITTER_GRAMMAR_PATH` and `VUE_LSP_PATH` so Emacs picks up those binaries without needing `nix develop`.

### Emacs launcher

Launch Emacs normally; project-local `.venv/bin` directories still take precedence whenever you start Emacs from a shell inside the project directory because `direnv` is applied there.

### Python Virtual Environment

This project uses [uv](https://docs.astral.sh/uv/) for Python dependency management. When using [direnv](https://direnv.net/), the virtual environment is automatically synchronized:

```bash
direnv allow
```

If not using direnv, manually sync the Python environment:

```bash
uv sync
```

## What's Included

- **Emacs configuration** (`init.el`, `early-init.el`)
- **Nix flake** for reproducible development environment with:
  - Language servers (TypeScript, Vue, Python, Rust, Fortran, YAML, LaTeX, Markdown)
  - Tree-sitter grammars
  - Development tools (ruff, pyright, bash-completion)
- **Ruff configuration** (`ruff.toml`)
- **GitHub Copilot CLI skills** (`copilot/skills/`) - custom extensions for Copilot CLI
  - AWS role assumption and SSO login
  - Commit message generation
  - Forgejo instance operations

## GitHub Copilot CLI Skills

Custom skills for the GitHub Copilot CLI are included in `copilot/skills/`. These are symlinked to `~/.copilot/skills` for seamless integration across machines.

**Setup on new machines**:
```bash
ln -s ~/dotfiles/copilot/skills ~/.copilot/skills
```

See [`copilot/skills/README.md`](./copilot/skills/README.md) for skill details.

## LICENSE
This program is licensed under the Apache License, Version 2.0.
