{
  config,
  inputs,
  lib,
  withSystem,
  ...
}: {
  options = {
    profile-parts.home-manager = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({
        name,
        config,
        ...
      }: {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            description = "Whether to expose the homeManagerConfiguration to the flake";
            default = true;
          };

          directory = lib.mkOption {
            type = lib.types.str;
            description = "The home directory passed to home-manager, or `home.homeDirectory`";
            default =
              if config.nixpkgs.legacyPackages.${config.system}.stdenv.isDarwin
              then "/Users/${config.username}"
              else "/home/${config.username}";
          };

          home-manager = lib.mkOption {
            type = lib.types.unspecified;
            description = "home-manager input to use for building the homeManagerConfiguration";
            default = inputs.home-manager;
          };

          modules = lib.mkOption {
            type = lib.types.listOf lib.types.unspecified;
            description = "List of modules to include in the homeManagerConfiguration";
            default = [];
          };

          nixpkgs = lib.mkOption {
            type = lib.types.unspecified;
            description = "nixpkgs input to use for building the homeManagerConfiguration";
            default = inputs.nixpkgs;
          };

          specialArgs = lib.mkOption {
            type = lib.types.attrsOf lib.types.unspecified;
            description = "`extraSpecialArgs` passed to the homeManagerConfiguration";
            default = {};
          };

          system = lib.mkOption {
            type = lib.types.enum lib.platforms.all;
            default = "x86_64-linux";
          };

          username = lib.mkOption {
            type = lib.types.str;
            description = "The username passed to home-manager, or `home.username`. Defaults to profile name";
            default = name;
          };

          # readOnly

          finalHome = lib.mkOption {
            type = lib.types.unspecified;
            readOnly = true;
          };

          finalPackage = lib.mkOption {
            type = lib.types.unspecified;
            description = lib.mdDoc "Package to be added to the flake to provide schema-supported access to activationPackage";
            readOnly = true;
          };
        };

        config = lib.mkIf config.enable {
          finalHome = withSystem config.system ({pkgs, ...}:
            config.home-manager.lib.homeManagerConfiguration {
              pkgs = config.nixpkgs.legacyPackages.${config.system};

              extraSpecialArgs = config.specialArgs;

              modules =
                [
                  {
                    home.homeDirectory = lib.mkDefault config.directory;
                    home.username = lib.mkDefault config.username;
                  }
                ]
                ++ config.modules;
            });

          finalPackage.${config.system}."home/${name}" = config.finalHome.activationPackage;
        };
      }));
    };
  };

  config = let
    homes = builtins.mapAttrs (_: config: config.finalHome) config.profile-parts.home-manager;

    # group checks into system-based sortings
    packages = lib.zipAttrs (builtins.attrValues (lib.mapAttrs (_: i: i.finalPackage) config.profile-parts.home-manager));
  in {
    flake.homeConfigurations = homes;

    perSystem = {system, ...}: {
      packages = lib.mkIf (builtins.hasAttr system packages) (lib.mkMerge packages.${system});
    };
  };
}
