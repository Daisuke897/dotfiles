{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/26.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ flake-parts, ... }:
    let
      mkEnv = { pkgs }:
        let
          myEmacs = pkgs.emacsWithPackagesFromUsePackage {
            package = pkgs.emacs;

            config = ./init.el;

            alwaysEnsure = true;

            extraEmacsPackages = epkgs: [
              epkgs.use-package
              epkgs.treesit-grammars.with-all-grammars
            ] ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
              epkgs.mozc
            ];
          };

          homePackages = [
            pkgs.typescript-language-server
            pkgs.vue-language-server
            pkgs.vscode-langservers-extracted
            pkgs.yaml-language-server
            pkgs.bash-language-server
            pkgs.texlab
            pkgs.rust-analyzer
            pkgs.fortls
            pkgs.ruff
            pkgs.ty
            pkgs.uv
            pkgs.marksman
            pkgs.taplo
            pkgs.dockerfile-language-server
            pkgs.forgejo-cli
            pkgs.nodejs
            pkgs.python3Packages.cfn-lint
            pkgs.rassumfrassum
            pkgs.gdal
            pkgs.docker
            pkgs.docker-compose
          ] ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
            pkgs.docker-credential-helpers
            pkgs.colima
            pkgs.shfmt
          ] ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            pkgs.mozc
          ];
        in
        {
          pkgs = pkgs;
          myEmacs = myEmacs;
          homePackages = homePackages;
        };
      mkHome = system: homeDirectory:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ inputs.emacs-overlay.overlays.default ];
          };
          env = mkEnv { inherit pkgs; };
        in
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs;
          modules = [
            ({ pkgs, ... }: {
              home.username = "daisuke";
              home.homeDirectory = homeDirectory;
              home.stateVersion = "26.05";
              home.packages = env.homePackages;
              programs.emacs = {
                enable = true;
                package = env.myEmacs;
              };
              services.emacs = {
                enable = true;
                defaultEditor = true;
              };
              home.sessionVariables = {
                VUE_LSP_PATH = "${env.pkgs.vue-language-server}/lib";
              };
            })
          ];
        };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      flake.homeConfigurations = {
        "daisuke@linux" = mkHome "x86_64-linux" "/home/daisuke";
        "daisuke@mac" = mkHome "aarch64-darwin" "/Users/daisuke";
      };
    };
}
