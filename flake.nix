{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";    
    flake-utils.url = "github:numtide/flake-utils";
    sbt.url = "github:zaninime/sbt-derivation/master";
    # recommended for first style of usage documented below, but not necessary
    sbt.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    sbt,
    flake-utils,
  }: 
    flake-utils.lib.eachDefaultSystem (system: 
    let
      pkgs = import nixpkgs {
        inherit system;
      };

    in {
      packages.default = import ./package.nix { pkgs = pkgs; sbt = sbt; self = self; };
      nixosModules = import ./module.nix { pkgs = pkgs; };
    }
  );
}
