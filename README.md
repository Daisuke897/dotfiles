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

## What's Included

- **Emacs configuration** (`init.el`, `early-init.el`)
- **Nix flake** for reproducible development environment with:
  - Language servers (TypeScript, Vue, Python, Rust, Fortran, YAML, LaTeX, Markdown)
  - Tree-sitter grammars
  - Development tools (ruff, pyright, bash-completion)
- **Ruff configuration** (`ruff.toml`)

## LICENSE
This program is licensed under the Apache License, Version 2.0.
