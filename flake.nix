{
  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    freckle.url = "github:freckle/flakes?dir=main";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    inputs:
    inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        nixpkgs-stable = inputs.nixpkgs-stable.legacyPackages.${system};
        nixpkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
        freckle = inputs.freckle.packages.${system};
        freckleLib = inputs.freckle.lib.${system};
      in
      {
        devShells.default = nixpkgs-stable.mkShell {
          buildInputs = [ nixpkgs-unstable.zlib ];
          nativeBuildInputs = [
            freckle.fourmolu-0-17-x
            (freckleLib.haskellBundle {
              ghcVersion = "ghc-9-10-3";
              enableHLS = true;
            })
          ];
          shellHook = ''export STACK_YAML=stack.yaml'';
        };

        devShells.nightly = nixpkgs-unstable.mkShell {
          buildInputs = [ nixpkgs-unstable.zlib ];
          nativeBuildInputs = [
            freckle.fourmolu-0-17-x
            nixpkgs-unstable.haskell.compiler.ghc9122
            nixpkgs-unstable.stack
          ];
          shellHook = ''export STACK_YAML=stack-nightly.yaml'';
        };
      }
    );
}
