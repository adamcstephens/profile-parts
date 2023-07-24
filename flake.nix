{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];

      perSystem = {pkgs, ...}: {
        devShells.default = pkgs.mkShellNoCC {
          packages = [pkgs.just];
        };
      };

      flake.flakeModules.home-manager = import ./parts/home-manager.nix;
      flake.flakeModules.nixos = import ./parts/nixos.nix;
    };
}
