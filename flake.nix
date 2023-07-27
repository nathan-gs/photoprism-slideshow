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
      nixosModules.photoprism-slideshow = { lib, pkgs, config, ... }:
        let
          cfg = config.services.photoprism-slideshow;
        in
        {
          options = with lib; {
            services.photoprism-slideshow = {
              enable = mkOption {
                type = types.bool;
                default = false;
              };

              port = mkOption {
                type = types.int;
                default = 23234;
              };

              database = mkOption {
                type = types.str;
                default = "/var/lib/photoprism/index.db";
              };

              basePath = mkOption {
                type = types.str;
                default = "/slideshow";
              };              

              package = mkOption {
                type = types.package;
                default = self.outputs.packages."${pkgs.system}".photoprism-slideshow;
              };              
            };
          };

        config = with lib; mkIf cfg.enable {
          systemd.services.photoprism-slideshow = {
            enable = true;
            path = [ pkgs.jre ];
            environment = {
              SERVER_PORT = toString cfg.port;
              DATABASE = cfg.database;
              BASE_PATH = cfg.basePath;
            };
            script = ''
              java -jar ${cfg.package}/photoprism-slideshow.jar
            '';
          };
        };
      };
    }
  );
}
