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
      #checks.build = self.packages.default;
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

          preload = mkOption {
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
            default = self.outputs.packages."${pkgs.system}".default;
          };              
        };
      };

      config = with lib; mkIf cfg.enable {
      
        systemd.services.photoprism-slideshow-reload = mkIf cfg.preload {
          enable = true;
          startAt = "*-*-* 01:34:00";
          script = ''
            ${pkgs.systemd}/bin/systemctl reload photoprism-slideshow
          '';
        };
        

        systemd.services.photoprism-slideshow = {
          enable = true;
          path = [ pkgs.jre ];
          preStart = if cfg.preload then ''
            cd /var/cache/photoprism-slideshow
            [ -e photoprism-slideshow.db ] && rm -- photoprism-slideshow.db
            ${pkgs.sqlite}/bin/sqlite3 ${cfg.database} ".clone photoprism-slideshow.db"
          '' else "";
          environment = {
            SERVER_PORT = toString cfg.port;
            DATABASE = if cfg.preload then "/var/cache/photoprism-slideshow/photoprism-slideshow.db" else cfg.database;
            BASE_PATH = cfg.basePath;
          };

          script = ''
            java -jar ${cfg.package}/photoprism-slideshow.jar
          '';
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];
          serviceConfig = {
            DynamicUser = true;
            Restart = "on-failure";
            CacheDirectory = "photoprism-slideshow";
            # Hardening
            CapabilityBoundingSet = "";
            DeviceAllow = false;
            DevicePolicy = "closed";
            LockPersonality = true;
            MemoryDenyWriteExecute = false;
            NoNewPrivileges = true;
            PrivateDevices = true;
            PrivateUsers = true;
            PrivateTmp = true;
            ProtectClock = true;
            ProtectControlGroups = true;
            ProtectHome = true;
            ProtectHostname = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            ProtectProc = "invisible";
            ProcSubset = "pid";
            ProtectSystem = "strict";
            RemoveIPC = true;
            RestrictAddressFamilies = [
              "AF_INET"
              "AF_INET6"
            ];
            RestrictNamespaces = true;
            RestrictRealtime = true;
            RestrictSUIDSGID = true;
            SupplementaryGroups = [];
            SystemCallArchitectures = "native";
            SystemCallFilter = [
              "@system-service @pkey"
              "~@privileged @resources"
            ];
            UMask = "0077";
          };
        };
      };
    };
  };
}
