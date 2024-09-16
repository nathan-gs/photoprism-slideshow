{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    sbt.url = "github:zaninime/sbt-derivation/master";
    # recommended for first style of usage documented below, but not necessary
    sbt.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self
    , nixpkgs
    , sbt
    , flake-utils
    ,
    }:
    flake-utils.lib.eachDefaultSystem
      (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
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

              port = mkOption {
                type = types.int;
                default = 23234;
              };

              dsn = mkOption {
                type = types.str;
                default = "jdbc:sqlite:/var/lib/photoprism/index.db";
              };

              basePath = mkOption {
                type = types.str;
                default = "/slideshow";
              };

              package = mkOption {
                type = types.package;
                default = self.outputs.packages."${pkgs.system}".default;
              };

              interval = mkOption {
                type = types.int;
                default = 10;
              };

              photoprismUrl = mkOption {
                type = types.str;
                default = "";
              };
            };
          };

          config = with lib; mkIf cfg.enable {

            systemd.services.photoprism-slideshow = {
              enable = true;
              path = [ ];
              environment = {
                SERVER_PORT = toString cfg.port;
                DSN = cfg.dsn;
                BASE_PATH = cfg.basePath;
                INTERVAL = toString cfg.interval;
                PHOTOPRISM_URL = cfg.photoprismUrl;
              };

              script = ''
                ${cfg.package}/bin/photoprism-slideshow
              '';
              wantedBy = [ "multi-user.target" ];
              after = [ "network.target" ];
              serviceConfig = {
                DynamicUser = true;
                Restart = "on-failure";
                CacheDirectory = "";
                # Hardening
                CapabilityBoundingSet = "";
                DeviceAllow = "";
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
                SupplementaryGroups = [ ];
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
