{
  lib,
  inputs,
  ...
}: {
  profile-parts.default.home-manager = {
    inherit (inputs) home-manager nixpkgs;
  };

  profile-parts.global.home-manager = {
    modules = {
      name,
      profile,
    }: [
      {
        home.file.testfile.text = "${name}-test-${profile.system}";
      }
    ];
  };

  profile-parts.home-manager = {
    check-defaults = {
      modules = [
        ({config, ...}: {
          assertions = [
            {
              assertion = config.home.homeDirectory == "/home/check-defaults";
              message = "Linux default home directory is incorrect";
            }
            {
              assertion = config.home.username == "check-defaults";
              message = "default username is incorrect";
            }
          ];

          home.stateVersion = "23.05";
        })
      ];
    };

    check-globals = {
      system = "aarch64-linux";

      modules = [
        ({config, ...}: {
          assertions = [
            {
              assertion = config.home.file.testfile.text == "check-globals-test-aarch64-linux";
              message = "Global module is not correctly calling or applying function";
            }
          ];

          home.stateVersion = "23.05";
        })
      ];
    };

    check-darwin = {
      system = "aarch64-darwin";

      modules = [
        ({config, ...}: {
          assertions = [
            {
              assertion = config.home.homeDirectory == "/Users/check-darwin";
              message = "Darwin default home directory is incorrect";
            }
          ];

          home.stateVersion = "23.05";
        })
      ];
    };

    check-overrides = {
      username = "overridden";
      directory = "/home/anotherdir";
      system = "aarch64-linux";

      modules = [
        ({
          config,
          lib,
          pkgs,
          specialInputs,
          ...
        }: {
          assertions = [
            {
              assertion = config.home.homeDirectory == "/home/anotherdir";
              message = "Override home directory is incorrect";
            }
            {
              assertion = config.home.username == "overridden";
              message = "Override username is incorrect";
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

          home.stateVersion = "23.05";
        })
      ];

      specialArgs = {specialInputs = inputs;};
    };
  };
}
