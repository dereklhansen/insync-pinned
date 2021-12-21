{
  description = "Working Insync 3 environment";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    nixpkgs-pinned = {
      url = "github:nixos/nixpkgs/b49473e6679c733f917254b786bfac42339875eb";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, flake-utils, nixpkgs, nixpkgs-pinned}:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };
        pkgs-pinned = import nixpkgs-pinned {
          inherit system;
          config = { allowUnfree = true; };
        };
        insync-v3 = pkgs-pinned.libsForQt515.callPackage ./insync-v3.nix {
          alsaLib = pkgs.alsa-lib;
        };
      in {
        packages.insync = insync-v3;
        devShell = pkgs.mkShell { buildInputs = [ pkgs.xdg_utils insync-v3 ]; };
        inherit nixpkgs;
        inherit nixpkgs-pinned;
      }
    );
}
