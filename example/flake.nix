{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager.url = "github:nix-community/home-manager";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    profile-parts.url = "git+https://codeberg.org/adamcstephens/profile-parts";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./example-home-manager.nix
        ./example-nixos.nix
      ];

      systems = ["x86_64-linux" "aarch64-linux"];
    };
}
