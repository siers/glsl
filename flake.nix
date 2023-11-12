{
  description = "shader dev flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem
      (system:
        with nixpkgs.legacyPackages.${system};
        let
          ghc =
            haskellPackages.ghcWithPackages
              (pkgs: with pkgs; [
                base
                linear
                recursion-schemes
              ]);
        in
          {
            devShells.default =
              mkShell {
                buildInputs = [
                  glslls
                  ghc
                  haskell-language-server
                  gnuplot
                ];
              };
          }
        );
}
