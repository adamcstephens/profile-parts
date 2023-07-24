{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager.url = "github:nix-community/home-manager";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    profile-parts.url = "git+https://codeberg.org/adamcstephens/profile-parts.git";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./home-manager.nix
        ./nixos.nix

        inputs.profile-parts.flakeModules.home-manager
        inputs.profile-parts.flakeModules.nixos
      ];

      systems = ["x86_64-linux" "aarch64-darwin"];
    };
}
