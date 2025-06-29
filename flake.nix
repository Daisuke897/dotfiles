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
    in
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs system;
        home.username = "daisuke";
        home.homeDirectory = homeDir;

        modules = [
          ({ config, pkgs, ...}: {
            programs.emacs = {
              enable = true;
              package = pkgs.emacs;
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

      devShells = builtins.listToAttrs (map (s:
        let pkgs = import nixpkgs { inherit (s) system; };

        typescriptLsp = mkLspWrapper {
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

        vueLsp = mkLspWrapper {
          inherit pkgs;
          name = "vue-lsp";
          npmPackages = [ "@vue/language-server" ];
          bin = "vue-language-server";
        };

        astroLsp = mkLspWrapper {
          inherit pkgs;
          name = "astro-lsp";
          npmPackages = [ "@astrojs/language-server" ];
          bin = "astro-ls";
        };

        eslintLsp = mkLspWrapper {
          inherit pkgs;
          name = "eslint-lsp";
          npmPackages = [ "vscode-langservers-extracted" ];
          bin = "vscode-eslint-language-server";
        };

        cssLsp = mkLspWrapper {
          inherit pkgs;
          name = "css-lsp";
          npmPackages = [ "vscode-langservers-extracted" ];
          bin = "vscode-css-language-server";
        };

        emacsLspDeps = with pkgs; [
          emacs

          nodejs

          # Typescript
          typescriptLsp

          # Eslint
          eslintLsp

          # CSS
          cssLsp

          # Vue
          vueLSP

          # Astro
          astroLsp

          # YAML
          nodePackages.yaml-language-server

          python3
          python3Packages.python-lsp-server

          rust-analyzer
        ];

        in
          { name = s.system;
            value = pkgs.mkShell { buildInputs = [ pkgs.emacs ];};
          }
      ) systems);
    };
}
