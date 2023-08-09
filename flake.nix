{
  outputs = _: {
    flakeModules = {
      home-manager = import ./parts/home-manager.nix;
      nixos = import ./parts/nixos.nix;
    };
  };
}
