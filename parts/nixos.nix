{
  config,
  lib,
  withSystem,
  ...
}: let
  defaults = config.profile-parts.default.nixos;
  globals = config.profile-parts.global.nixos;
in {
  options = {
    profile-parts.default.nixos = {
      enable = lib.mkOption {
        type = lib.types.bool;
        description = lib.mdDoc "Whether all nixosConfigurations should be enabled by default";
        default = true;
      };

      exposePackages = lib.mkEnableOption (lib.mdDoc "Expose all nixosConfigurations at `.#packages.<system>.nixos/<profile name>`");

      nixpkgs = lib.mkOption {
        type = lib.types.unspecified;
        description = lib.mdDoc "The default nixpkgs input to use for building nixosConfigurations. Required";
      };

      system = lib.mkOption {
        type = lib.types.enum lib.platforms.linux;
        description = lib.mdDoc "The default system used when defining the nixosConfiguration";
        default = "x86_64-linux";
      };
    };

    profile-parts.global.nixos = {
      modules = lib.mkOption {
        type = lib.types.unspecified; # TODO make function capable
        description = lib.mdDoc "List of modules to include in all nixosConfigurations. Can also be a function that will be passed the `name` and `profile`";
        default = [];
      };

      specialArgs = lib.mkOption {
        type = lib.types.attrsOf lib.types.unspecified;
        description = lib.mdDoc "`specialArgs` passed to all nixosConfigurations";
        default = {};
      };
    };

    profile-parts.nixos = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({
        name,
        config,
        ...
      }: {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            description = lib.mdDoc "Whether to expose the nixosConfiguration to the flake";
            default = defaults.enable;
          };

          hostname = lib.mkOption {
            type = lib.types.str;
            description = lib.mdDoc "hostname of the final nixosConfiguration (`networking.hostName`). Defaults to profile name";
            default = name;
          };

          meta = lib.mkOption {
            type = lib.types.attrsOf lib.types.unspecified;
            description = lib.mdDoc "Meta information for external use in other flake-parts modules.";
            default = {};
          };

          modules = lib.mkOption {
            type = lib.types.listOf lib.types.unspecified;
            description = lib.mdDoc "List of modules to include in the nixosConfiguration";
            default = [];
          };

          nixpkgs = lib.mkOption {
            type = lib.types.unspecified;
            description = lib.mdDoc "nixpkgs input to use for building the nixosConfiguration";
            default = defaults.nixpkgs;
          };

          specialArgs = lib.mkOption {
            type = lib.types.attrsOf lib.types.unspecified;
            description = lib.mdDoc "`specialArgs` passed to the nixosConfiguration";
            default = {};
          };

          system = lib.mkOption {
            type = lib.types.enum lib.platforms.linux;
            description = lib.mdDoc "The system used when defining the nixosConfiguration";
            default = defaults.system;
          };

          # readOnly

          finalNixos = lib.mkOption {
            type = lib.types.unspecified;
            description = lib.mdDoc "The final nixosConfiguration";
            readOnly = true;
          };

          finalPackage = lib.mkOption {
            type = lib.types.unspecified;
            description = lib.mdDoc "Package to be added to allow building nixos profile top-level";
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
          lib.mkIf profile.enable rec {
            finalNixos = withSystem profile.system (
              {...}:
                profile.nixpkgs.lib.nixosSystem {
                  inherit (profile) system;

                  modules =
                    globalModules
                    ++ [{networking.hostName = lib.mkDefault profile.hostname;}]
                    ++ profile.modules;

                  specialArgs = lib.recursiveUpdate globals.specialArgs profile.specialArgs;
                }
            );

            finalPackage.${profile.system}."nixos/${name}" = finalNixos.config.system.build.toplevel;
          };
      }));
    };
  };

  config = let
    enabledNixos = lib.filterAttrs (_: v: v.enable) config.profile-parts.nixos;

    profiles = builtins.mapAttrs (_: config: config.finalNixos) enabledNixos;

    # group checks into system-based sortings
    packages = lib.zipAttrs (builtins.attrValues (lib.mapAttrs (_: i: i.finalPackage) enabledNixos));
  in {
    flake.nixosConfigurations = profiles;

    perSystem = {system, ...}: {
      packages = lib.mkIf (defaults.exposePackages && (builtins.hasAttr system packages)) (lib.mkMerge packages.${system});
    };
  };
}
