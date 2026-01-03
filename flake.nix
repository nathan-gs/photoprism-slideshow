{
  description = "PhotoPrism slideshow server as a NixOS module";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";  # or keep "nixos-unstable" if you prefer
    flake-utils.url = "github:numtide/flake-utils";
    sbt.url = "github:zaninime/sbt-derivation/master";
    sbt.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, sbt }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Build the actual package
        photoprism-slideshow = pkgs.callPackage ./package.nix {
          inherit sbt self;
        };
      in
      {
        # Expose the package per system
        packages.default = photoprism-slideshow;
        packages.photoprism-slideshow = photoprism-slideshow;

        # Optional: useful for nix build .#checks.<system>.build
        # checks.build = photoprism-slideshow;
      }
    ) // {
      # The NixOS module — system-independent
      nixosModules.photoprism-slideshow = { lib, pkgs, config, ... }:
        let
          cfg = config.services.photoprism-slideshow;
          inherit (lib) mkEnableOption mkOption mkIf types;
        in
        {
          options.services.photoprism-slideshow = {
            enable = mkEnableOption "PhotoPrism slideshow server";

            port = mkOption {
              type = types.port;
              default = 23234;
              description = "Port on which the slideshow server listens.";
            };

            dsn = mkOption {
              type = types.str;
              default = "jdbc:sqlite:/var/lib/photoprism/index.db";
              description = "Database connection string.";
            };

            basePath = mkOption {
              type = types.str;
              default = "/slideshow";
              description = "Base path for the web server.";
            };

            package = mkOption {
              type = types.package;
              description = "The photoprism-slideshow package to use.";
              # Modern, warning-free way to get the per-system package
              default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
              defaultText = lib.literalExpression "self.packages.\${pkgs.stdenv.hostPlatform.system}.default";
            };

            interval = mkOption {
              type = types.int;
              default = 10;
              description = "Slide change interval in seconds.";
            };

            photoprismUrl = mkOption {
              type = types.str;
              default = "";
              description = "Base URL of the PhotoPrism instance (used for auth/proxy).";
            };
          };

          config = mkIf cfg.enable {
            systemd.services.photoprism-slideshow = {
              description = "PhotoPrism Slideshow Server";
              after = [ "network.target" ];
              wantedBy = [ "multi-user.target" ];

              environment = {
                SERVER_PORT = toString cfg.port;
                DSN = cfg.dsn;
                BASE_PATH = cfg.basePath;
                INTERVAL = toString cfg.interval;
                PHOTOPRISM_URL = cfg.photoprismUrl;
              };

              serviceConfig = {
                ExecStart = "${cfg.package}/bin/photoprism-slideshow";
                DynamicUser = true;
                Restart = "on-failure";

                # Hardening (unchanged from your original)
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
                RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
                RestrictNamespaces = true;
                RestrictRealtime = true;
                RestrictSUIDSGID = true;
                SystemCallArchitectures = "native";
                SystemCallFilter = [ "@system-service @pkey" "~@privileged @resources" ];
                UMask = "0077";
              };
            };
          };
        };
    };
}
