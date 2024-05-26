
{
  description = "Zoomer application for wayland inspired by tsoding's boomer";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, crane, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        craneLib = crane.mkLib pkgs;

        # Common arguments can be set here to avoid repeating them later
        # Note: changes here will rebuild all dependency crates
        commonArgs = rec {
          src = let
              shaderFilter = path: _type: builtins.match ".*fs$" path != null;
              shaderOrCargo = path: type:
                (shaderFilter path type) || (craneLib.filterCargoSources path type);
            in
            pkgs.lib.cleanSourceWith {
              src = craneLib.path ./.;
              filter = shaderOrCargo;
            };
          strictDeps = true;
          nativeBuildInputs = (with pkgs; [
            cmake
            pkg-config
            clang
            wayland
          ]);
          buildInputs = (with pkgs; [
            wayland
            glfw
          ]) ++ (
            with pkgs.xorg; [
            libX11.dev
            libXrandr.dev
            libXinerama.dev
            libXcursor.dev
            libXi.dev
          ]);
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;
          LIBCLANG_PATH = pkgs.libclang.lib + "/lib/";
        };

        woomer = craneLib.buildPackage (commonArgs // {
          cargoArtifacts = craneLib.buildDepsOnly commonArgs;
        });
      in
      {
        checks = {
          inherit woomer;
        };

        packages.default = woomer;

        apps.default = flake-utils.lib.mkApp {
          drv = woomer;
        };

        devShells.default = craneLib.devShell {
          inherit (commonArgs) nativeBuildInputs buildInputs LIBCLANG_PATH;
          # Inherit inputs from checks.
          checks = self.checks.${system};
          packages = with pkgs; [
            rust-analyzer
          ];

        };
      });
}
