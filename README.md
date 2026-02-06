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

The Home Manager configuration now installs the same language servers, formatters, `uv`, `ruff`, and helper tools that the dev shell provides, plus `cfn-lint`, `rassumfrassum`, and the merged tree-sitter grammars needed by Emacs. It also exports `TREE_SITTER_GRAMMAR_PATH` and `VUE_LSP_PATH` so Emacs launched via `bin/em` picks up those binaries without the need to run `nix develop`.

### Emacs launcher

`bin/em` still wraps `emacs` with `direnv exec` so project-local `.venv/bin` directories take precedence, but you can launch it without entering the dev shell because Home Manager already provides the shared language servers and LSP tooling.

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
