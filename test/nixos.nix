{inputs, ...}: {
  profile-parts.nixos = {
    check-defaults = {
      modules = [
        (inputs.nixpkgs + "/nixos/modules/installer/sd-card/sd-image-x86_64.nix")
        ({config, ...}: {
          assertions = [
            {
              assertion = config.networking.hostName == "check-defaults";
              message = "Default hostname is incorrect";
            }
          ];

          system.stateVersion = "23.05";
        })
      ];
    };

    check-overrides = {
      hostname = "overridden";
      system = "aarch64-linux";

      modules = [
        (inputs.nixpkgs + "/nixos/modules/installer/sd-card/sd-image-aarch64.nix")
        ({
          config,
          pkgs,
          specialInputs,
          ...
        }: {
          assertions = [
            {
              assertion = config.networking.hostName == "overridden";
              message = "Override hostname is incorrect";
            }
            {
              assertion = pkgs.system == "aarch64-linux";
              message = "Override system is incorrect";
            }
            {
              assertion = specialInputs == inputs;
              message = "specialArgs is not handled properly";
            }
          ];

          system.stateVersion = "23.05";
        })
      ];

      specialArgs = {specialInputs = inputs;};
    };
  };
}
