{inputs, ...}: {
  imports = [
    inputs.profile-parts.flakeModules.nixos
  ];

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
