{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      perSystem = { config, pkgs, system, ... }: {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.vscode-langservers-extracted
            pkgs.yaml-language-server
            pkgs.texlab
            pkgs.rust-analyzer
            pkgs.fortls
            pkgs.ruff
            pkgs.pyright
            pkgs.marksman
          ];
        };
      };
    };
}
