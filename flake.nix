{
  description = "Instant Haskell environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        ghcVersion = "ghc910";
        hp = pkgs.haskell.packages.${ghcVersion};

        cabalInit = pkgs.writeShellScriptBin "cabal-init" ''
          set -euo pipefail
          if [ $# -ne 1 ]; then
            echo "Usage: cabal-init <project-name>"
            exit 1
          fi
          project_name="$1"
          ${hp.cabal-install}/bin/cabal init --non-interactive \
            --package-name="$project_name" \
            --license=BSD-3-Clause \
            --libandexe \
            --tests \
            --main-is=Main.hs \
            --language=GHC2021
          cabal_file=$(${pkgs.findutils}/bin/find . -maxdepth 1 -name "*.cabal" -print -quit)
          if [ -n "$cabal_file" ]; then
            ${pkgs.gnused}/bin/sed -i 's/^cabal-version:.*$/cabal-version:      3.14/' "$cabal_file"
            echo "Patched $cabal_file: cabal-version -> 3.14 (HLS compatibility)"
          fi
        '';

        # Pick a compiler once.
        commonTools = [
          hp.ghc
          hp.cabal-install
          hp.haskell-language-server
          hp.hoogle
          hp.ghcid
          hp.fourmolu
          hp.fast-tags
          hp.hlint
          hp.hspec-discover
          pkgs.haskellPackages.cabal-gild
          pkgs.hpack
          cabalInit
        ];
      in {
        devShells.default = pkgs.mkShell {
          name = "hlox-dev-shell";
          packages = commonTools;
          shellHook = ''
            echo "Haskell development environment is ready!"
            echo "ghc=$(ghc --numeric-version),"
            echo "cabal=$(cabal --numeric-version),"
            echo "Try: cabal repl | ghci | ghcid --command 'cabal repl'"
          '';
        };
      }
    );
}
