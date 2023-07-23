{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";    
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, flake-compat }:
    flake-utils.lib.eachDefaultSystem
      (
        system:
        let
          pkgs = import nixpkgs
            {
              inherit system; overlays = [
              self.overlay              
            ];
              config = {
                allowUnsupportedSystem = true;
              };
            };
        in
        with pkgs;
        rec {
          packages = flake-utils.lib.flattenTree {
            photoprism-slideshow = pkgs.photoprism-slideshow;
          };

          #defaultPackage = packages.photoprism-slideshow;

          checks.build = packages.photoprism-slideshow;
          
        }
      ) // {
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

      overlay = final: prev: {
        photoprism-slideshow = with final;
          (
            stdenv.mkDerivation {
              name = "photoprism-slideshow";
              buildInputs = [];
              src = self;
              buildPhase = "";
              installPhase = "mkdir -p $out; cp *.jar $out/";
            }
          );
        
      };
  };
}