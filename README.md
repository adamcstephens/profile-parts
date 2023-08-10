# profile-parts

Simple NixOS or Home Manager profiles for [Flake Parts](https://flake.parts/)

Flake Parts provides a module system for flakes. This flake provides modules wrappers around common configuration targets (e.g. nixosConfigurations or homeManagerConfigurations) to simplify managing multiple "profiles" in a single flake.

## Getting Started

Add the necessary flake inputs to your `flake.nix`. This flake provides no inputs, so you will need to bring your own.

```nix
{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager.url = "github:nix-community/home-manager"; # only needed if configuring home-manager profiles
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    profile-parts.url = "github:adamcstephens/profile-parts"; # or git+https://codeberg.org/adamcstephens/profile-parts.git
  };
}
```

See [examples](./example) or [my dotfiles](https://codeberg.org/adamcstephens/dotfiles/src/commit/9f59b704ff483e95cd640de77299e21a5fa2379d/home/profiles.nix) which has home-manager profiles.

## Credits

Much ❤️ to Nobbz for [inspiration](https://github.com/NobbZ/nixos-config/tree/55f5ce183e08e9045401e430d9ee9c99c0578bd4/parts)
