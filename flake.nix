{
  description = "Daisuke’s cross-platform Emacs + Home-Manager flake";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-25.05";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    systems = [
      { name = "linux"; system = "x86_64-linux"; homeDir = "/home/daisuke"; }
      { name = "macos"; system = "aarch64-darwin"; homeDir = "/Users/daisuke"; }
    ];

    mkHome = { name, system, homeDir }: let
      pkgs = import nixpkgs { inherit system; };
      emacsWithModules = pkgs.emacs30.override {
        withTreeSitter = true;
        withGTK = true;
        withModules = true;
      };
      emacsPkgs = pkgs.emacsPackagesFor emacsWithModules;
    in
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs system;
        home.username = "daisuke";
        home.homeDirectory = homeDir;

        modules = [
          ({ config, pkgs, ...}: {
            programs.emacs = {
              enable = true;
              package = emacsWithModules;
              extraPackages = epkgs: [
                epkgs.vterm
                epkgs.tree-sitter-langs
                epkgs.use-package
              ];
              extraConfig = builtins.readFile ./init.el;
            };
            home.file.".emacs.d/init.el".source = ./init.el;
          })
        ];
      };

      mkLspWrapper = { pkgs, name, npmPackages, bin }: pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = [ pkgs.nodejs pkgs.git ];
        text = ''
          CACHE_DIR="$HOME/.cache/${name}"
          export NODE_PATH="$CACHE_DIR/node_modules"
          export PATH="$CACHE_DIR/node_modules/.bin:$PATH"

          if [ ! -d "$CACHE_DIR/node_modules" ]; then
            echo "Installing ${name} into $CACHE_DIR..."
            mkdir -p "$CACHE_DIR"
            cd "$CACHE_DIR"
            npm install --no-save ${builtins.concatStringsSep " \\\n  " npmPackages}
          fi

          exec ${bin} "$@"
        '';
      };

      homeConfigs = builtins.listToAttrs (map (s:
        { name = "daisuke-${s.name}";
          value = mkHome s;}
      ) systems);
  in
    {
      homeConfigurations = homeConfigs;

      devShells = nixpkgs.lib.genAttrs (map (s: s.system) systems) (systemName: let
        pkgs = import nixpkgs { system = systemName; };
        lspWrappers = {
          typescript = mkLspWrapper {
            inherit pkgs;
            name = "typescript-lsp";
            npmPackages = [
              "typescript"
              "typescript-language-server"
              "@vue/typescript-plugin"
              "@astrojs/ts-plugin"
            ];
            bin = "typescript-language-server";
          };

          vue = mkLspWrapper {
            inherit pkgs;
            name = "vue-lsp";
            npmPackages = [ "@vue/language-server" ];
            bin = "vue-language-server";
          };

          astro = mkLspWrapper {
            inherit pkgs;
            name = "astro-lsp";
            npmPackages = [ "@astrojs/language-server" ];
            bin = "astro-ls";
          };

          eslint = mkLspWrapper {
            inherit pkgs;
            name = "eslint-lsp";
            npmPackages = [ "vscode-langservers-extracted" ];
            bin = "vscode-eslint-language-server";
          };

          css = mkLspWrapper {
            inherit pkgs;
            name = "css-lsp";
            npmPackages = [ "vscode-langservers-extracted" ];
            bin = "vscode-css-language-server";
          };

          html = mkLspWrapper {
            inherit pkgs;
            name = "html-lsp";
            npmPackages = [ "vscode-langservers-extracted" ];
            bin = "vscode-html-language-server";
          };

          json = mkLspWrapper {
            inherit pkgs;
            name = "json-lsp";
            npmPackages = [ "vscode-langservers-extracted" ];
            bin = "vscode-json-language-server";
          };
        };

        juliaLsp = pkgs.writeShellApplication {
          name = "julia-lsp";
          runtimeInputs = [ pkgs.julia ];
          text = ''
            CACHE_DIR="$HOME/.cache/julia-lsp"
            export JULIA_DEPOT_PATH="$CACHE_DIR"

            if [ ! -d "$CACHE_DIR/compiled" ]; then
              echo "Installing LanguageServer.jl into $CACHE_DIR..."
              mkdir -p "$CACHE_DIR"
              julia --project="$CACHE_DIR" -e '
                using Pkg
                Pkg.add("LanguageServer")
                Pkg.add("SymbolServer")
                Pkg.precompile()
              '
            fi

            exec julia "$@"
          '';
        };

        emacsDeps = with pkgs; [
          emacs

          # Tree-sitter
          tree-sitter

          # Typescript
          lspWrappers.typescript

          # ESLint / CSS / HTML / JSON
          lspWrappers.eslint
          lspWrappers.css
          lspWrappers.html
          lspWrappers.json

          # Vue / Astro
          lspWrappers.vue
          lspWrappers.astro

          # YAML
          nodePackages.yaml-language-server

          # Julia
          juliaLsp

          # LaTeX
          texlab

          # Rust
          rust-analyzer

          # Fortran
          fortls

          # Python3
          python313
          python313Packages.ruff
          pyright

          # Markdown
          marksman

          # Vterm
          cmake
          libtool
          libvterm
        ];
      in
         pkgs.mkShell { buildInputs = emacsDeps;}
      );
    };
}
