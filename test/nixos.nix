{inputs, ...}: {
  profile-parts.default.nixos = {
    inherit (inputs) nixpkgs;
    system = "aarch64-linux";

    exposePackages = true;
  };

  profile-parts.global.nixos = {
    modules = {
      name,
      profile,
    }: [
      (inputs.nixpkgs + "/nixos/modules/installer/sd-card/sd-image-x86_64.nix") # not all x86_64, but this is sufficient to eval

      {
        environment.etc.testfile.text = "${name}-test-${profile.system}";
      }
    ];
  };

  profile-parts.nixos = {
    check-defaults = {
      modules = [
        ({
          config,
          pkgs,
          ...
        }: {
          assertions = [
            {
              assertion = config.networking.hostName == "check-defaults";
              message = "Default hostname is incorrect";
            }
            {
              assertion = pkgs.system == "aarch64-linux";
              message = "Default `system` is not applied to final nixosConfiguration";
            }
          ];

          system.stateVersion = "23.05";
        })
      ];
    };

    check-disable = {
      enable = false;
    };

    check-globals = {
      system = "armv7l-linux";

      modules = [
        ({config, ...}: {
          assertions = [
            {
              assertion = config.environment.etc.testfile.text == "check-globals-test-armv7l-linux";
              message = "Global module is not correctly calling or applying function";
            }
          ];

          system.stateVersion = "23.05";
        })
      ];
    };

    check-overrides = {
      hostname = "overridden";
      system = "x86_64-linux";

      modules = [
        ({
          config,
          pkgs,
          specialInputs,
          ...
        }: {
          assertions = [
            {
              assertion = specialInputs == inputs;
              message = "specialArgs is not handled properly";
            }
            {
              assertion = pkgs.system == "x86_64-linux";
              message = "Override `system` is not applied to final nixosConfiguration";
            }
          ];

          system.stateVersion = "23.05";
        })
      ];

      specialArgs = {specialInputs = inputs;};
    };
  };
}
