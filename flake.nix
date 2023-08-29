{
  outputs = _: {
    flakeModules = {
      darwin = import ./parts/darwin.nix;
      home-manager = import ./parts/home-manager.nix;
      nixos = import ./parts/nixos.nix;
    };
  };
}
