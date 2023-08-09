{inputs, ...}: {
  imports = [
    inputs.profile-parts.flakeModules.nixos
  ];

  #
  # defaults
  #
  profile-parts.default.nixos = {
    inherit (inputs) nixpkgs;

    enable = true;
    system = "x86_64-linux";
  };

  #
  # globals (merged with per-profile)
  #
  profile-parts.global.nixos = {
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
  profile-parts.nixos = {
    example = {
      hostname = "notexample";
      nixpkgs = inputs.nixpkgs;
      system = "x86_64-linux";

      modules = [
        (inputs.nixpkgs + "/nixos/modules/installer/sd-card/sd-image-x86_64.nix")
        (
          {
            inputs, # read from specialArgs
            pkgs,
            ...
          }: {
            environment.systemPackages = [
              inputs.nixpkgs.legacyPackages.${pkgs.system}.hello
            ];

            system.stateVersion = "23.05";
          }
        )
      ];

      specialArgs = {
        inherit inputs;
      };
    };
  };
}
