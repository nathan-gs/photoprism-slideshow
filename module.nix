{ pkgs, ... }:

{
  photoprism-slideshow = { lib, pkgs, config, ... }:
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