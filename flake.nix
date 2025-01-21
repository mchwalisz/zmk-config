{
  description = "sofle ZMK config";

  inputs = {
    zmk-config-nix.url = github:Tomaszal/zmk-config-nix;
    nixpkgs.follows = "zmk-config-nix/nixpkgs";
    flake-utils.follows = "zmk-config-nix/flake-utils";
    rnix-lsp.follows = "zmk-config-nix/rnix-lsp";
  };

  outputs = { self, nixpkgs, flake-utils, rnix-lsp, zmk-config-nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; }; in
      with pkgs;
      {
        devShells.default = mkShell {
          nativeBuildInputs = [
            rnix-lsp.defaultPackage.${system}
            cocogitto
          ];
        };

        packages.sofle_left = zmk-config-nix.packages.${system}.zmkBinary {
          config = ./config;
          board = "nice_nano_v2";
          shield = "splitkb_aurora_sofle_left";
        };
        packages.sofle_right = zmk-config-nix.packages.${system}.zmkBinary {
          config = ./config;
          board = "nice_nano_v2";
          shield = "splitkb_aurora_sofle_right";
        };
      }
    );
}
