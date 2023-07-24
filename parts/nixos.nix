{
  config,
  inputs,
  lib,
  withSystem,
  ...
}: {
  options = {
    profile-parts.nixos = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({
        name,
        config,
        ...
      }: {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            description = "Whether to expose the nixosConfiguration to the flake";
            default = true;
          };

          hostname = lib.mkOption {
            type = lib.types.str;
            description = "hostname of the final nixosConfiguration (`networking.hostName`). Defaults to profile name";
            default = name;
          };

          modules = lib.mkOption {
            type = lib.types.listOf lib.types.unspecified;
            description = "List of modules to include in the nixosConfiguration";
            default = [];
          };

          nixpkgs = lib.mkOption {
            type = lib.types.unspecified;
            description = "nixpkgs input to use for building the nixosConfiguration";
            default = inputs.nixpkgs;
          };

          specialArgs = lib.mkOption {
            type = lib.types.attrsOf lib.types.unspecified;
            description = "`specialArgs` passed to the nixosConfiguration";
            default = {};
          };

          system = lib.mkOption {
            type = lib.types.enum ["x86_64-linux" "aarch64-linux"];
            description = "The system used when defining the nixosConfiguration";
            default = "x86_64-linux";
          };

          # readOnly

          finalNixos = lib.mkOption {
            type = lib.types.unspecified;
            description = "The final nixosConfiguration";
            readOnly = true;
          };
        };

        config = lib.mkIf config.enable {
          finalNixos = withSystem config.system (
            {...}:
              config.nixpkgs.lib.nixosSystem {
                inherit (config) specialArgs system;

                modules = [{networking.hostName = lib.mkDefault config.hostname;}] ++ config.modules;
              }
          );
        };
      }));
    };
  };

  config = let
    profiles = builtins.mapAttrs (_: config: config.finalNixos) (lib.filterAttrs (_: v: v.enable) config.profile-parts.nixos);
  in {
    flake.nixosConfigurations = profiles;
  };
}
