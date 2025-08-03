{
  description = "Daisuke’s devShell-first Emacs flake";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-25.05";
    };
  };

  outputs = { self, nixpkgs, ... }:
  let
    systems = ["x86_64-linux" "aarch64-darwin" ];

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

    mkDevShell = system: let
      pkgs = import nixpkgs { inherit system; };

      baseEmacs = pkgs.emacs30.override {
        withTreeSitter        = true;
        withGTK3              = true;
        withNativeCompilation = true;
      };

      emacsFull = pkgs.emacs.pkgs.withPackages (epkgs: with epkgs; [
        baseEmacs
        vterm
        use-package
        tree-sitter-langs
      ]);

      lspWrappers = {
        typescript = mkLspWrapper {
          inherit pkgs;
          name = "typescript-lsp";
          npmPackages = [
            "typescript"
            "typescript-language-server"
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
        emacsFull
        tree-sitter
        libvterm

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
      ];
    in
      pkgs.mkShell {
        buildInputs = emacsDeps;
        shellHook = ''
          [ -L $HOME/.emacs.d/init.el ] || {
            mkdir -p $HOME/.emacs.d
            ln -s ${toString ./init.el} $HOME/.emacs.d/init.el
          }
          export PATH=${pkgs.lib.makeBinPath emacsDeps}:$PATH
        '';
      };
  in
    {
      devShells = nixpkgs.lib.genAttrs systems (system: mkDevShell system);
    };
}
