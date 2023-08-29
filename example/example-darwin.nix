{inputs, ...}: {
  imports = [
    inputs.profile-parts.flakeModules.darwin
  ];

  #
  # defaults
  #
  profile-parts.default.darwin = {
    inherit (inputs) nix-darwin nixpkgs;

    enable = true;
    system = "aarch64-darwin";
  };

  #
  # globals (merged with per-profile)
  #
  profile-parts.global.darwin = {
    modules = {
      name,
      profile,
    }: [];
    # alternative: modules = [];

    specialArgs = {};
  };

  #
  # profiles
  #
  profile-parts.darwin = {
    example = {
      hostname = "notexample";
      nix-darwin = inputs.nix-darwin;
      nixpkgs = inputs.nixpkgs;
      system = "aarch64-darwin";

      modules = [
        (
          {
            inputs, # read from specialArgs
            pkgs,
            ...
          }: {
            fonts.fonts = [pkgs.dejavu_fonts];
            system.stateVersion = 4;
          }
        )
      ];

      specialArgs = {
        inherit inputs;
      };
    };
  };
}
