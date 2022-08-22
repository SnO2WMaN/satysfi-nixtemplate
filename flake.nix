{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    satysfi-upstream.url = "github:SnO2WMaN/SATySFi/sno2wman/nix-flake";
    satyxin.url = "github:SnO2WMaN/satyxin";
    satysfi-sno2wman.url = "github:SnO2WMaN/satysfi-sno2wman";

    # dev
    devshell.url = "github:numtide/devshell";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    satysfi-formatter.url = "github:SnO2WMaN/satysfi-formatter/nix-integrate";
    satysfi-language-server.url = "github:SnO2WMaN/satysfi-language-server/nix-integrate";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = with inputs; [
            devshell.overlay
            satyxin.overlays.default
            satysfi-sno2wman.overlays.default
            (final: prev: {
              satysfi = satysfi-upstream.packages.${system}.satysfi;
              satysfi-language-server = satysfi-language-server.packages.${system}.satysfi-language-server;
              satysfi-formatter = satysfi-formatter.packages.${system}.satysfi-formatter;
              satysfi-formatter-write-each = satysfi-formatter.packages.${system}.satysfi-formatter-write-each;
            })
          ];
        };
      in rec {
        packages = {
          satysfi-dist = pkgs.satyxin.buildSatysfiDist {
            packages = with pkgs.satyxinPackages; [
              uline
              bibyfi
              fss
            ];
          };
          main = pkgs.satyxin.buildDocument {
            satysfiDist = self.packages.${system}.satysfi-dist;
            name = "main";
            src = ./src;
            entrypoint = "main.saty";
          };
        };
        defaultPackage = self.packages."${system}".main;

        devShell = pkgs.devshell.mkShell {
          packages = with pkgs; [
            alejandra
            dprint
            satysfi
            satysfi-formatter-write-each
            satysfi-language-server
          ];
          commands = [
            {
              package = "treefmt";
              category = "formatter";
            }
          ];
        };
      }
    );
}
