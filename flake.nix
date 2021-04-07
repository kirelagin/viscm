# SPDX-FileCopyrightText: 2021 Serokell <https://serokell.io/>
#
# SPDX-License-Identifier: MPL-2.0

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    poetry.url = "github:nix-community/poetry2nix";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, poetry }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlay = self: super: {
          qhull = super.qhull.overrideAttrs (old: {
            name = "qhull-2020.2";
            src = self.fetchFromGitHub {
              owner = "qhull";
              repo = "qhull";
              rev = "613debeaea72ee66626dace9ba1a2eff11b5d37d";
              hash = "sha256-djUO3qzY8ch29AuhY3Bn1ajxWZ4/W70icWVrxWRAxRc=";
            };
          });
        };

        pkgs = import nixpkgs { inherit system; overlays = [ poetry.overlay overlay ]; };
        inherit (pkgs) poetry2nix;

        poetryOverlay = self: super: {
          matplotlib = super.matplotlib.overridePythonAttrs (old: {
            propagatedBuildInputs = old.propagatedBuildInputs ++ [
              pkgs.qhull
              self.certifi
            ];
            postPatch = old.postPatch + ''
              cat >> setup.cfg <<EOF
              system_qhull = True
              EOF
            '';
          });
        };

        src = ./.;
        app = poetry2nix.mkPoetryApplication {
          projectDir = src;
          overrides = [ poetry2nix.defaultPoetryOverrides poetryOverlay ];
          postInstall = ''
            for i in "$out"/bin/*; do
              wrapProgram $i --prefix QT_PLUGIN_PATH : "${pkgs.qt5.qtbase}/${pkgs.qt5.qtbase.qtPluginPrefix}"
            done
          '';
        };

      in rec {
        defaultPackage = app;

        defaultApp = {
          type = "app";
          program = "${defaultPackage}/bin/viscm";
        };

        devShell = pkgs.mkShell {
          buildInputs = [ app ];
          shellHook = ''
            QT_PLUGIN_PATH="${pkgs.qt5.qtbase}/${pkgs.qt5.qtbase.qtPluginPrefix}:$QT_PLUGIN_PATH"
          '';
        };
      }
    );
}
