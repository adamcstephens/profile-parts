{
  config,
  lib,
  withSystem,
  ...
}: let
  defaults = config.profile-parts.default.darwin;
  globals = config.profile-parts.global.darwin;
in {
  options = {
    profile-parts.default.darwin = {
      enable = lib.mkOption {
        type = lib.types.bool;
        description = lib.mdDoc "Whether all darwinConfigurations should be enabled by default";
        default = true;
      };

      exposePackages = lib.mkEnableOption (lib.mdDoc "Expose all darwinConfigurations at `.#packages.<system>.darwin/<profile name>`");

      nix-darwin = lib.mkOption {
        type = lib.types.unspecified;
        description = lib.mdDoc "nix-darwin input to use for building all darwinConfigurations. Required";
      };

      nixpkgs = lib.mkOption {
        type = lib.types.unspecified;
        description = lib.mdDoc "The default nixpkgs input to use for building darwinConfigurations. Required";
      };

      system = lib.mkOption {
        type = lib.types.enum lib.platforms.all;
        description = lib.mdDoc "The default system to use for building darwinConfigurations";
        default = "aarch64-darwin";
      };
    };

    profile-parts.global.darwin = {
      modules = lib.mkOption {
        type = lib.types.unspecified; # TODO make function capable
        description = lib.mdDoc "List of modules to include in all darwinConfigurations. Can also be a function that will be passed the `name` and `profile`";
        default = [];
      };

      specialArgs = lib.mkOption {
        type = lib.types.attrsOf lib.types.unspecified;
        description = lib.mdDoc "`specialArgs` passed to all darwinConfigurations";
        default = {};
      };
    };

    profile-parts.darwin = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({
        name,
        config,
        ...
      }: {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            description = lib.mdDoc "Whether to expose the darwinConfiguration to the flake";
            default = defaults.enable;
          };

          directory = lib.mkOption {
            type = lib.types.str;
            description = lib.mdDoc "The home directory passed to darwin, or `home.homeDirectory`";
            default =
              if config.nixpkgs.legacyPackages.${config.system}.stdenv.isDarwin
              then "/Users/${config.username}"
              else "/home/${config.username}";
          };

          hostname = lib.mkOption {
            type = lib.types.str;
            description = lib.mdDoc "hostname of the final nixosConfiguration (`networking.hostName`). Defaults to profile name";
            default = name;
          };

          modules = lib.mkOption {
            type = lib.types.listOf lib.types.unspecified;
            description = lib.mdDoc "List of modules to include in the darwinConfiguration";
            default = [];
          };

          nix-darwin = lib.mkOption {
            type = lib.types.unspecified;
            description = lib.mdDoc "darwin input to use for building the darwinConfiguration. Required to be set per-profile or using `default.darwin.nix-darwin`";
            default = defaults.nix-darwin;
          };

          nixpkgs = lib.mkOption {
            type = lib.types.unspecified;
            description = lib.mdDoc "nixpkgs input to use for building the darwinConfiguration. Required to be set per-profile or using `default.darwin.nixpkgs";
            default = defaults.nixpkgs;
          };

          specialArgs = lib.mkOption {
            type = lib.types.attrsOf lib.types.unspecified;
            description = lib.mdDoc "`specialArgs` passed to the darwinConfiguration";
            default = {};
          };

          system = lib.mkOption {
            type = lib.types.enum lib.platforms.all;
            description = lib.mdDoc "system used for building the darwinConfiguration";
            default = defaults.system;
          };

          # readOnly

          finalDarwin = lib.mkOption {
            type = lib.types.unspecified;
            readOnly = true;
          };

          finalModules = lib.mkOption {
            type = lib.types.unspecified;
            description = lib.mdDoc "Final set of modules merge with global and profile";
            readOnly = true;
          };

          finalPackage = lib.mkOption {
            type = lib.types.unspecified;
            description = lib.mdDoc "Package to be added to the flake to provide schema-supported access to darwin system";
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
          lib.mkIf profile.enable {
            finalDarwin = withSystem profile.system ({...}:
              profile.nix-darwin.lib.darwinSystem {
                pkgs = profile.nixpkgs.legacyPackages.${profile.system};

                specialArgs = lib.recursiveUpdate globals.specialArgs profile.specialArgs;

                modules = profile.finalModules;
              });

            finalModules =
              globalModules
              ++ [{networking.hostName = lib.mkDefault profile.hostname;}]
              ++ profile.modules;

            finalPackage.${profile.system}."darwin/${name}" = profile.finalDarwin.system;
          };
      }));
      description = lib.mdDoc "";
    };
  };

  config = let
    enabledDarwins = lib.filterAttrs (_: v: v.enable) config.profile-parts.darwin;

    darwinProfiles = builtins.mapAttrs (_: config: config.finalDarwin) enabledDarwins;

    # group checks into system-based sortings
    packages = lib.zipAttrs (builtins.attrValues (lib.mapAttrs (_: i: i.finalPackage) enabledDarwins));
  in {
    flake.darwinConfigurations = darwinProfiles;

    perSystem = {system, ...}: {
      packages = lib.mkIf (defaults.exposePackages && (builtins.hasAttr system packages)) (lib.mkMerge packages.${system});
    };
  };
}
