{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";

    zmk-nix = {
      url = "github:lilyinstarlight/zmk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, zmk-nix }: let
    forAllSystems = nixpkgs.lib.genAttrs (nixpkgs.lib.attrNames zmk-nix.packages);
    zephyrDepsHash = "sha256-reAWLQgGuZQiCiN5yGoVlbN6CT5yxl7lEk2/HbvL2x4=";

  in {
    packages = forAllSystems (system: rec {
      default = firmware;

      firmware = zmk-nix.legacyPackages.${system}.buildSplitKeyboard {
        name = "firmware";

        src = nixpkgs.lib.sourceFilesBySuffices self [ ".board" ".cmake" ".conf" ".defconfig" ".dts" ".dtsi" ".json" ".keymap" ".overlay" ".shield" ".yml" "_defconfig" ];

        board = "nice_nano_v2";
        # shield = "my_sofle_%PART%";
        shield = "my_sofle_%PART% nice_view_adapter nice_view";

        inherit zephyrDepsHash;

        meta = {
          description = "ZMK firmware";
          license = nixpkgs.lib.licenses.mit;
          platforms = nixpkgs.lib.platforms.all;
        };
      };

      reset_firmware = zmk-nix.legacyPackages.${system}.buildSplitKeyboard {
        name = "reset_firmware";

        src = nixpkgs.lib.sourceFilesBySuffices self [ ".board" ".cmake" ".conf" ".defconfig" ".dts" ".dtsi" ".json" ".keymap" ".overlay" ".shield" ".yml" "_defconfig" ];

        board = "nice_nano_v2";
        shield = "settings_reset";

        inherit zephyrDepsHash;

        meta = {
          description = "ZMK reset firmware";
          license = nixpkgs.lib.licenses.mit;
          platforms = nixpkgs.lib.platforms.all;
        };
      };

      flash = zmk-nix.packages.${system}.flash.override { inherit firmware; };
      reset_flash = zmk-nix.packages.${system}.flash.override { firmware = reset_firmware; };
      update = zmk-nix.packages.${system}.update;

    });

    devShells = forAllSystems (system: {
      default = zmk-nix.devShells.${system}.default;
    });
  };
}
