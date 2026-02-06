{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-old.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs-old, flake-parts, ... }:
    let
      mkEnv = { pkgs, pkgs-old }:
        let
          mkGrammar = lang: grammar: pkgs.runCommand "tree-sitter-${lang}" {} ''
            mkdir -p $out/lib
            ln -s ${grammar}/parser $out/lib/libtree-sitter-${lang}.dylib
          '';
          mergedGrammars = pkgs.symlinkJoin {
            name = "merged-tree-sitter-grammars";
            paths = [
              (mkGrammar "python" pkgs-old.tree-sitter-grammars.tree-sitter-python)
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
          cfnLint = pkgs.python3Packages.cfn-lint.overrideAttrs (oldAttrs: {
            version = "1.44.0";
            src = pkgs.fetchFromGitHub {
              owner = "aws-cloudformation";
              repo = "cfn-lint";
              rev = "4bd61db11b8aa70ad467ec77fd253369471943d9";
              sha256 = "0c06168fisvzibp1wi25dpac4sa8s96527qwaqz6f7s7lv2qr3g5";
            };
            patchPhase = ''
              substituteInPlace pyproject.toml \
                --replace 'setuptools >= 80.10.2' 'setuptools >= 80.9.0'
            '';
            meta = oldAttrs.meta // {
              changelog = "https://github.com/aws-cloudformation/cfn-lint/blob/v1.44.0/CHANGELOG.md";
            };
          });
          rassumfrassum = pkgs.python3Packages.buildPythonPackage rec {
            pname = "rassumfrassum";
            version = "0.3.3";
            src = pkgs.fetchurl {
              url = "https://github.com/joaotavora/rassumfrassum/archive/refs/tags/v0.3.3.tar.gz";
              sha256 = "0d0r5xcr34fbqc5366pvvr6p2zbhvczrwi8v1i1igzcf2zmiky24";
            };
            pyproject = true;
            build-system = with pkgs.python3Packages; [ setuptools ];
            doCheck = false;
            meta = with pkgs.lib; {
              description = "Lightweight LSP multiplexer that exposes a single rass entry point";
              homepage = "https://github.com/joaotavora/rassumfrassum";
              license = licenses.gpl3Plus;
            };
          };
          shellPackages = [
            pkgs.typescript-language-server
            pkgs.vue-language-server
            pkgs.vscode-langservers-extracted
            pkgs.yaml-language-server
            pkgs.texlab
            pkgs.rust-analyzer
            pkgs.fortls
            pkgs.ruff
            pkgs.pyright
            pkgs.uv
            pkgs-old.marksman
            pkgs.taplo
            pkgs.dockerfile-language-server
            mergedGrammars
          ];
          homePackages = shellPackages ++ [
            pkgs.forgejo-cli
            pkgs.nodejs
            cfnLint
            rassumfrassum
          ];
        in
        {
          pkgs = pkgs;
          mergedGrammars = mergedGrammars;
          devShellPackages = shellPackages;
          homePackages = homePackages;
        };
      mkHome = system: homeDirectory:
        let
          pkgs = import inputs.nixpkgs { inherit system; };
          pkgs-old = import nixpkgs-old { inherit system; };
          env = mkEnv { inherit pkgs pkgs-old; };
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
      perSystem = { config, pkgs, system, ... }:
        let
          pkgs-old = import nixpkgs-old { inherit system; };
          env = mkEnv { inherit pkgs pkgs-old; };
        in
        {
          devShells.default = pkgs.mkShell {
            buildInputs = env.devShellPackages;
            shellHook = ''
              export TREE_SITTER_GRAMMAR_PATH="${env.mergedGrammars}/lib"
              export VUE_LSP_PATH="${env.pkgs.vue-language-server}/lib"
              if [ -d "$(pwd)/.venv/bin" ]; then
                export PATH="$(pwd)/.venv/bin:$PATH"
              fi
            '';
          };
        };
    };
}
