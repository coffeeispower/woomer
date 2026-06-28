{
  description = "Zoomer application for wayland inspired by tsoding's boomer";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    systems.url = "github:nix-systems/default";

    crane.url = "github:ipetkov/crane";
  };

  outputs = { self, nixpkgs, systems, crane, ... }:
    let
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in {
      checks = forEachSystem (system: {
        inherit (self.packages.${system}) woomer;
      });

      packages = forEachSystem (system: let
        pkgs = nixpkgs.legacyPackages.${system};
        craneLib = crane.mkLib pkgs;

        # Common arguments can be set here to avoid repeating them later
        # Note: changes here will rebuild all dependency crates
        commonArgs =
          let
            buildInputs = (with pkgs; [
              wayland
              glfw
              libgbm
            ]) ++ (
              with pkgs.xorg; [
              libX11.dev
              libXrandr.dev
              libXinerama.dev
              libXcursor.dev
              libXi.dev
            ]);

            craneLib = crane.mkLib pkgs;
          in {
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
            nativeBuildInputs = with pkgs; [
              cmake
              pkg-config
              clang
              wayland
            ];
            inherit buildInputs;
            LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;
            LIBCLANG_PATH = pkgs.libclang.lib + "/lib/";
          };
      in {
        woomer = self.packages.${system}.default;
        default = craneLib.buildPackage (commonArgs // {
          cargoArtifacts = craneLib.buildDepsOnly commonArgs;

          postFixup = ''
            patchelf $out/bin/woomer \
              --add-needed libwayland-client.so \
              --add-needed libwayland-cursor.so \
              --add-needed libwayland-egl.so \
              --add-rpath ${pkgs.lib.makeLibraryPath [ pkgs.wayland ]}
          '';

          meta = {
            description = "Zoomer application for Wayland inspired by tsoding's boomer";
            license = pkgs.lib.licenses.mit;
            mainProgram = "woomer";
          };
        });
      });

      apps = forEachSystem (system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        type = "app";
        program = pkgs.lib.getExe self.packages.${system}.default;
      });

      devShells = forEachSystem (system: let
        pkgs = nixpkgs.legacyPackages.${system};
        craneLib = crane.mkLib pkgs;
      in {
        default = craneLib.devShell {
          checks = self.checks.${system};
          packages = with pkgs; [
            rust-analyzer
          ];
          env = {
            inherit (self.packages.${system}.default)
              LIBCLANG_PATH LD_LIBRARY_PATH;
          };
          inputsFrom = [
            self.packages.${system}.default
          ];
        };
      });
    };
}