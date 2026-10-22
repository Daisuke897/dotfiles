{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    let
      mkEnv = { pkgs }:
        let
          mkGrammar = lang: grammar: pkgs.runCommand "tree-sitter-${lang}" {} ''
            mkdir -p $out/lib
            ln -s ${grammar}/parser $out/lib/libtree-sitter-${lang}.dylib
          '';
          mergedGrammars = pkgs.symlinkJoin {
            name = "merged-tree-sitter-grammars";
            paths = [
              (mkGrammar "python" pkgs.tree-sitter-grammars.tree-sitter-python)
              (mkGrammar "yaml" pkgs.tree-sitter-grammars.tree-sitter-yaml)
              (mkGrammar "bash" pkgs.tree-sitter-grammars.tree-sitter-bash)
              (mkGrammar "tsx" pkgs.tree-sitter-grammars.tree-sitter-tsx)
              (mkGrammar "typescript" pkgs.tree-sitter-grammars.tree-sitter-typescript)
              (mkGrammar "markdown-inline" pkgs.tree-sitter-grammars.tree-sitter-markdown-inline)
              (mkGrammar "markdown" pkgs.tree-sitter-grammars.tree-sitter-markdown)
              (mkGrammar "json" pkgs.tree-sitter-grammars.tree-sitter-json)
              (mkGrammar "css" pkgs.tree-sitter-grammars.tree-sitter-css)
              (mkGrammar "nix" pkgs.tree-sitter-grammars.tree-sitter-nix)
              (mkGrammar "dockerfile" pkgs.tree-sitter-grammars.tree-sitter-dockerfile)
              (mkGrammar "toml" pkgs.tree-sitter-grammars.tree-sitter-toml)
            ];
          };
          cfnLint = pkgs.python3Packages.cfn-lint;
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
            mergedGrammars
            pkgs.forgejo-cli
            pkgs.nodejs
            cfnLint
            pkgs.rassumfrassum
            pkgs.gdal
            pkgs.docker
            pkgs.docker-compose
          ] ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
            pkgs.docker-credential-helpers
            pkgs.colima
            pkgs.shfmt
          ];
        in
        {
          pkgs = pkgs;
          mergedGrammars = mergedGrammars;
          homePackages = homePackages;
        };
      mkHome = system: homeDirectory:
        let
          pkgs = import inputs.nixpkgs { inherit system; };
          env = mkEnv { inherit pkgs; };
        in
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs;
          modules = [
            ({ pkgs, ... }: {
              home.username = "daisuke";
              home.homeDirectory = homeDirectory;
              home.stateVersion = "25.11";
              home.packages = env.homePackages;
              home.sessionVariables = {
                TREE_SITTER_GRAMMAR_PATH = "${env.mergedGrammars}/lib";
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
