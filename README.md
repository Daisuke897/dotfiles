# Dotfiles

Personal configuration files for development environment and Emacs.

## Requirements
- [Nix](https://nixos.org/) with flakes enabled
- Emacs

## Usage

Enter the development shell with all language servers and tools:

```bash
nix develop
```

### Home Manager (optional)

Home Manager is available via this flake for adding user-level packages. Example:

```bash
home-manager switch --flake .#daisuke@linux
```

On macOS (ARM):

```bash
home-manager switch --flake .#daisuke@mac
```

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

## LICENSE
This program is licensed under the Apache License, Version 2.0.
