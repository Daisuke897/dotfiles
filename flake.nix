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
      pkgs = import nixpkgs { inherit systems; };
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

      homeConfigs = builtins.listToAttrs (map (s:
        { name = "daisuke-${s.name}";
          value = mkHome s;}
      ) systems);
  in
    {
      homeConfigurations = homeConfigs;

      devShells = builtins.listToAttrs (map (s:
        let pkgs = import nixpkgs { inherit (s) system; };

        emacsLspDeps = with pkgs; [
          emacs

          nodejs
          nodePackages.typescript-language-server

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
