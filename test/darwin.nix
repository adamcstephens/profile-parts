{inputs, ...}: {
  profile-parts.default.darwin = {
    inherit (inputs) nix-darwin nixpkgs;
    system = "aarch64-darwin";

    # required to ensure checks run
    exposePackages = true;
  };

  profile-parts.global.darwin = {
    modules = {
      name,
      profile,
    }: [
      {
        networking.computerName = "whyglobal";
        system.stateVersion = 3;
      }
    ];
  };

  profile-parts.darwin = {
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
              assertion = pkgs.system == "aarch64-darwin";
              message = "Default `system` is not applied to final darwinConfiguration";
            }
          ];
        })
      ];
    };

    check-disable = {
      enable = false;
    };

    check-globals = {
      modules = [
        ({config, ...}: {
          assertions = [
            {
              assertion = config.networking.computerName == "whyglobal";
              message = "Global module is not correctly calling or applying function";
            }
            {
              assertion = config.system.stateVersion == 3;
              message = "Global module is not correctly calling or applying function";
            }
          ];
        })
      ];
    };

    check-overrides = {
      hostname = "overridden";
      system = "x86_64-darwin";

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
              assertion = pkgs.system == "x86_64-darwin";
              message = "Override `system` is not applied to final darwinConfiguration";
            }
          ];
        })
      ];

      specialArgs = {specialInputs = inputs;};
    };
  };
}
