{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      perSystem = { config, pkgs, system, ... }: let
        devInputs = with pkgs; [
          typescript-language-server
          vscode-langservers-extracted
          yaml-language-server
          vue-language-server
          astro-language-server
          texlab
          rust-analyzer
          fortls
          ruff
          pyright
          marksman
        ];

      in {
        devShells.default = pkgs.mkShell {
          buildInputs = devInputs;
          shellHook = ''
            # init.el をプロジェクトのものにリンク（上書きしない）
            if [ ! -e "$HOME/.emacs.d/init.el" ]; then
              mkdir -p $HOME/.emacs.d
              ln -s ${toString ./init.el} $HOME/.emacs.d/init.el
            fi
          '';
        };
      };
    };
}
