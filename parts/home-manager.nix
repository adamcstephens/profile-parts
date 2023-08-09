{
  config,
  lib,
  withSystem,
  ...
}: let
  defaults = config.profile-parts.default.home-manager;
  globals = config.profile-parts.global.home-manager;
in {
  options = {
    profile-parts.default.home-manager = {
      enable = lib.mkOption {
        type = lib.types.bool;
        description = lib.mdDoc "Whether all homeManagerConfigurations should be enabled by default";
        default = true;
      };

      home-manager = lib.mkOption {
        type = lib.types.unspecified;
        description = lib.mdDoc "home-manager input to use for building all homeManagerConfigurations. Required";
      };

      nixpkgs = lib.mkOption {
        type = lib.types.unspecified;
        description = lib.mdDoc "The default nixpkgs input to use for building homeManagerConfigurations. Required";
      };
    };

    profile-parts.global.home-manager = {
      modules = lib.mkOption {
        type = lib.types.unspecified; # TODO make function capable
        description = lib.mdDoc "List of modules to include in all homeManagerConfigurations. Can also be a function that will be passed the `name` and `profile`";
        default = [];
      };

      specialArgs = lib.mkOption {
        type = lib.types.attrsOf lib.types.unspecified;
        description = lib.mdDoc "`extraSpecialArgs` passed to all homeManagerConfigurations";
        default = {};
      };
    };

    profile-parts.home-manager = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({
        name,
        config,
        ...
      }: {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            description = lib.mdDoc "Whether to expose the homeManagerConfiguration to the flake";
            default = defaults.enable;
          };

          directory = lib.mkOption {
            type = lib.types.str;
            description = lib.mdDoc "The home directory passed to home-manager, or `home.homeDirectory`";
            default =
              if config.nixpkgs.legacyPackages.${config.system}.stdenv.isDarwin
              then "/Users/${config.username}"
              else "/home/${config.username}";
          };

          home-manager = lib.mkOption {
            type = lib.types.unspecified;
            description = lib.mdDoc "home-manager input to use for building the homeManagerConfiguration. Required to be set per-profile or using `default.home-manager.home-manager`";
            default = defaults.home-manager;
          };

          modules = lib.mkOption {
            type = lib.types.listOf lib.types.unspecified;
            description = lib.mdDoc "List of modules to include in the homeManagerConfiguration";
            default = [];
          };

          nixpkgs = lib.mkOption {
            type = lib.types.unspecified;
            description = lib.mdDoc "nixpkgs input to use for building the homeManagerConfiguration. Required to be set per-profile or using `default.home-manager.nixpkgs";
            default = defaults.nixpkgs;
          };

          specialArgs = lib.mkOption {
            type = lib.types.attrsOf lib.types.unspecified;
            description = lib.mdDoc "`extraSpecialArgs` passed to the homeManagerConfiguration";
            default = {};
          };

          system = lib.mkOption {
            type = lib.types.enum lib.platforms.all;
            default = "x86_64-linux";
          };

          username = lib.mkOption {
            type = lib.types.str;
            description = lib.mdDoc "The username passed to home-manager, or `home.username`. Defaults to profile name";
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

        config = let
          profile = config;
          globalModules =
            if lib.isFunction globals.modules
            then globals.modules {inherit name profile;}
            else globals.modules;
        in
          lib.mkIf config.enable {
            finalHome = withSystem config.system ({pkgs, ...}:
              config.home-manager.lib.homeManagerConfiguration {
                pkgs = config.nixpkgs.legacyPackages.${config.system};

                extraSpecialArgs = lib.recursiveUpdate globals.specialArgs profile.specialArgs;

                modules =
                  globalModules
                  ++ [
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
      description = lib.mdDoc "";
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
