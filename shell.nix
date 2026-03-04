{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Core build tools
    git
    curl
    unzip
    which
    bash
    cmake
    ninja
    pkg-config
    python3
    perl

    # X11 / graphics
    libGL
    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi
    xorg.libXext
    xorg.libXrender

    # Font/text rendering
    freetype.dev
    harfbuzz.dev
    graphite2.dev
    fontconfig
    fontconfig.dev

    # GTK / GLib / profiling
    gtk3.dev
    sysprof.dev

    # Runtime libraries
    libepoxy
  ];

  LD_LIBRARY_PATH = with pkgs;
    lib.makeLibraryPath [ fontconfig fontconfig.dev libepoxy ];

  shellHook = ''
        # Flutter in path
        export PATH=$PATH:$PWD/flutter/bin

        # pkg-config paths for headers and .pc files
        export PKG_CONFIG_PATH="${pkgs.fontconfig.dev}/lib/pkgconfig:${pkgs.graphite2.dev}/lib/pkgconfig:${pkgs.harfbuzz.dev}/lib/pkgconfig:${pkgs.freetype.dev}/lib/pkgconfig:${pkgs.sysprof.dev}/lib/pkgconfig:${pkgs.gtk3.dev}/lib/pkgconfig:${pkgs.gtk3.dev}/share/pkgconfig:$PKG_CONFIG_PATH"

        # Runtime libraries for linker
        export LDFLAGS="-L${pkgs.fontconfig}/lib $LDFLAGS"
      
    echo ${pkgs.fontconfig}
    pkg-config --libs fontconfig

  '';
}
