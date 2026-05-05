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
