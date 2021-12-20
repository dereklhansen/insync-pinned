{
  description = "Working Insync 3 environment";

  inputs = {
    nixpkgs-pinned = {
      url = "github:nixos/nixpkgs/b49473e6679c733f917254b786bfac42339875eb";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, flake-utils, nixpkgs-pinned}:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs-pinned = import nixpkgs-pinned {
          inherit system;
          config = { allowUnfree = true; };
        };
        insync-v3 = pkgs-pinned.insync-v3.overrideAttrs (old: rec {
          version = "3.6.1.50206";

          src = pkgs-pinned.fetchurl {
            url = "http://s.insynchq.com/builds/${old.pname}_${version}-focal_amd64.deb";
            sha256 = "sha256-OHZoZlLsLFkN5juvQP4TF3laDYQ7g4NULragJaZRniY=";
          };
          buildInputs = old.buildInputs ++ [
            pkgs-pinned.xorg.libxcb
            pkgs-pinned.libxkbcommon
            pkgs-pinned.libdrm
          ];
        installPhase = ''
          mkdir -p $out/bin $out/lib $out/share
          cp -R usr/* $out/
          rm $out/lib/insync/libGLX.so.0
          rm $out/lib/insync/libdrm*.so*
          rm $out/lib/insync/libxkbcommon*.so*
          rm $out/lib/insync/libQt5*
          sed -i 's|/usr/lib/insync|/lib/insync|' "$out/bin/insync"
          wrapQtApp "$out/lib/insync/insync"
        '';
        });
      in {
        packages.insync = insync-v3;
        devShell = pkgs-pinned.mkShell { buildInputs = [ pkgs-pinned.xdg_utils insync-v3 ]; };
      }
    );
}
