let
  self = builtins.getFlake (toString ./.);
  pkgs = self.inputs.nixpkgs.legacyPackages.${builtins.currentSystem};
  app = self.outputs.defaultPackage.${builtins.currentSystem};

in

with pkgs;
mkShell {
  buildInputs = [
    app
  ];
  shellHook = ''
    # fixes libstdc++ issues and libgl.so issues
    LD_LIBRARY_PATH=${stdenv.cc.cc.lib}/lib/:/run/opengl-driver/lib/
    # fixes xcb issues :
    QT_PLUGIN_PATH=${qt5.qtbase}/${qt5.qtbase.qtPluginPrefix}
  '';
}
