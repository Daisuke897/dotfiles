{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-old.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ nixpkgs-old, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      perSystem = { config, pkgs, system, ... }:
      let
        pkgs-old = import nixpkgs-old { inherit system; };
        mkGrammar = lang: grammar: pkgs.runCommand "tree-sitter-${lang}" {} ''
          mkdir -p $out/lib
          ln -s ${grammar}/parser $out/lib/libtree-sitter-${lang}.dylib
        '';
        merged-grammars = pkgs.symlinkJoin {
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
          ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            # LSP Servers
            pkgs.typescript-language-server
            pkgs.vue-language-server
            pkgs.vscode-langservers-extracted
            pkgs.yaml-language-server
            pkgs.texlab
            pkgs.rust-analyzer
            pkgs.fortls
            pkgs.ruff
            pkgs.pyright
            pkgs.marksman

            merged-grammars
          ];

          shellHook = ''
            export TREE_SITTER_GRAMMAR_PATH="${merged-grammars}/lib"
            export VUE_LSP_PATH="${pkgs.vue-language-server}/lib"
          '';
        };
      };
    };
}
