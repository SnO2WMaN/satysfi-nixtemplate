{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
    satyxin.url = "github:SnO2WMaN/satyxin";
    satyxinur.url = "github:SnO2WMaN/satyxinur";
    satysfi-tools.url = "github:SnO2WMaN/satysfi-tools-nix";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    devshell,
    satyxin,
    satyxinur,
    satysfi-tools,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            devshell.overlay
            satyxin.overlay
            satyxinur.overlay
            satysfi-tools.overlay
          ];
        };
      in rec {
        packages.main = pkgs.satyxin.buildDocument {
          name = "main";
          src = ./src;
          filename = "main.saty";
          buildInputs = with pkgs.satyxinPackages; [
            uline
            bibyfi
            fss
          ];
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
