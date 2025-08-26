with import <nixpkgs> { };
let
  gtk = gtk3;
  home = builtins.getEnv "HOME";
  android = pkgs.androidenv.composeAndroidPackages {
    toolsVersion = "26.1.1";
    platformToolsVersion = "34.0.5";
    buildToolsVersions = [ "30.0.3" ];
    platformVersions = [ "30" ];
    includeEmulator = true;
    includeSystemImages = true;
    abiVersions = [ "x86_64" ]; # required for emulator
  };
in mkShell {
  buildInputs =
    [ flutter gtk pkg-config cmake libsecret.dev ninja android.androidsdk ];

  PKG_CONFIG_PATH = "${gtk.dev}/lib/pkgconfig:${gtk.out}/lib/pkgconfig";
  LD_LIBRARY_PATH = "${pkgs.glib.out}/lib:$LD_LIBRARY_PATH";

  ANDROID_HOME = "${home}/.android-sdk";
  QT_QPA_PLATFORM = "xcb";
  ANDROID_SDK_ROOT = "${home}/.android-sdk";
  NIXPKGS_ACCEPT_ANDROID_SDK_LICENSE = 1;
  NIXPKGS_ALLOW_UNFREE = 1;
}

# export NIXPKGS_ACCEPT_ANDROID_SDK_LICENSE=1;export NIXPKGS_ALLOW_UNFREE=1;nix-shell
# emulator -avd test_avd
# ~/flutter/bin/flutter
