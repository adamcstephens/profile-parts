# profile-parts

Simple NixOS or Home Manager profiles for [Flake Parts](https://flake.parts/)

Flake Parts provides a module system for flakes. This flake provides modules wrappers around common configuration targets (e.g. nixosConfigurations or homeManagerConfigurations) to simplify managing multiple "profiles" in a single flake.

Goals:

- Normalize configurations across profile types (e.g. home-manager `extraSpecialArgs` -> `specialArgs`)
- No flake inputs, users must bring their own
- Provide global configuration capability per profile type to simplify shared configurations
- Support multiple system architectures

## Getting Started

Add the necessary flake inputs to your `flake.nix`. This flake provides no inputs, so you will need to bring your own.

```nix
{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager.url = "github:nix-community/home-manager"; # only needed if configuring home-manager profiles
    nix-darwin.url = "github:lnl7/nix-darwin/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    profile-parts.url = "github:adamcstephens/profile-parts"; # or git+https://codeberg.org/adamcstephens/profile-parts.git
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.profile-parts.flakeModules.darwin
        inputs.profile-parts.flakeModules.home-manager
        inputs.profile-parts.flakeModules.nixos
      ];

      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
    };
}
```

See [examples](./example) or [my dotfiles](https://codeberg.org/adamcstephens/dotfiles/src/commit/9f59b704ff483e95cd640de77299e21a5fa2379d/home/profiles.nix) which has home-manager profiles.

## Credits

Much ❤️ to Nobbz for [inspiration](https://github.com/NobbZ/nixos-config/tree/55f5ce183e08e9045401e430d9ee9c99c0578bd4/parts)
