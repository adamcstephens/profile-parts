{inputs, ...}: {
  imports = [
    inputs.profile-parts.flakeModules.home-manager
  ];

  profile-parts.home-manager = {
    adam = {
      username = "john";
      directory = "/home/george";

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
