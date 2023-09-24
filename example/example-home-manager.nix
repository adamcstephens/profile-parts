{inputs, ...}: {
  imports = [
    inputs.profile-parts.flakeModules.home-manager
  ];

  #
  # defaults
  #
  profile-parts.default.home-manager = {
    inherit (inputs) home-manager nixpkgs;

    enable = true;
    system = "x86_64-linux";

    exposePackages = true; # expose packages for homeManagerConfigurations, e.g. .#home/superadam

    username = "adam";
  };

  #
  # globals (merged with per-profile)
  #
  profile-parts.global.home-manager = {
    modules = {
      name,
      profile,
    }: [];
    # alternative: modules = [];

    specialArgs = {};
  };

  #
  # profiles
  #
  profile-parts.home-manager = {
    superadam = {
      home-manager = inputs.home-manager;
      nixpkgs = inputs.nixpkgs;

      username = "notadam";
      directory = "/home/adamshome";

      modules = [
        {
          home.stateVersion = "23.05";
        }
        ({
          inputs, # read from specialArgs
          pkgs,
          ...
        }: {
          home.packages = [inputs.nixpkgs.legacyPackages.${pkgs.system}.hello];
        })
      ];

      specialArgs = {inherit inputs;};
    };
  };
}
