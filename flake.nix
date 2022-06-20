{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
    satyxin.url = "github:SnO2WMaN/satyxin";
    satysfi-tools.url = "github:SnO2WMaN/satysfi-tools-nix";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    satysfi-uline = {
      url = "github:puripuri2100/SATySFi-uline";
      flake = false;
    };
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    devshell,
    satyxin,
    satysfi-tools,
    satysfi-uline,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            devshell.overlay
            satyxin.overlay
            satysfi-tools.overlay
          ];
        };
      in rec {
        packages = flake-utils.lib.flattenTree rec {
          main = pkgs.satyxin.buildDocument {
            name = "main";
            src = ./src;
            filename = "main.saty";
            buildInputs = [
              satysfiPackages.satysfi-uline
            ];
          };
          satysfiPackages = {
            satysfi-uline = pkgs.satyxin.buildPackage {
              name = "satysfi-uline";
              src = satysfi-uline;
              path = "uline.satyh";
            };
          };
        };
        defaultPackage = packages.main;

        devShell = pkgs.devshell.mkShell {
          imports = [
            (pkgs.devshell.importTOML ./devshell.toml)
          ];
        };
      }
    );
}
