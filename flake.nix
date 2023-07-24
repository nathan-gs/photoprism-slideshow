{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";    
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
    flake-utils.url = "github:numtide/flake-utils";
    sbt.url = "github:zaninime/sbt-derivation/master";
    # recommended for first style of usage documented below, but not necessary
    sbt.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, flake-compat, sbt }:
    flake-utils.lib.eachDefaultSystem
      (
        system:
        let
          pkgs = import nixpkgs
            {
              inherit system; overlays = [
              self.overlays.default              
            ];
              config = {
                allowUnsupportedSystem = true;
              };
            };
        in
        with pkgs;
        rec {
          packages = flake-utils.lib.flattenTree {
            inherit (pkgs)
              photoprism-slideshow;
            default = pkgs.photoprism-slideshow;
          };

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

      overlays.default = final: prev: {
        photoprism-slideshow = with final;
          (
            sbt.lib.mkSbtDerivation {
              pname = "photoprism-slideshow";
              version = "0.0.1";
              pkgs = nixpkgs.legacyPackages.x86_64-linux;
              depsSha256 = "sha256-iBt8aH+0AcbhW4AuhCIurDMV6xqq/iP9+LABq+DuoEI=";
              buildInputs = [ ];
              src = self;
              nativeBuildInputs = [ ];
              buildPhase = ''
                sbt package
              '';

              installPhase = "mkdir -p $out; cp target/scala-*/*.jar $out/photoprism-slideshow.jar";

            }
          );
        
      };
  };
}