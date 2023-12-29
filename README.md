# Photoprism Slideshow

A very basic Picture Frame side-app for [Photoprism](https://www.photoprism.app/).

Easiest to use with NixOS as a flake, but can be used outside. 

## Installation

In your `flake.nix`:

```nix
    inputs.photoprism-slideshow.url = "github:nathan-gs/photoprism-slideshow";
```

```nix
outputs.nixosConfigurations.your-pc = nixpkgs.lib.nixosSystem {
    modules = [
        # Point this to your original configuration.
        ./computers/your-pc.nix
        photoprism-slideshow.nixosModules.photoprism-slideshow
    ];
};
```

In your regular config:

```nix
  services.photoprism-slideshow = {
    enable = true;
    preload = true;
    interval = 40;
  };
```

The `preload` option copies your photoprism db at start and every 24h.

## Usage

It uses the photoprism endpoint to retrieve scaled photo's. 

There are 2 endpoints:

- `/#Album1,Album2,AlbumN` using Javascript to automatically advance
- `/random/Album1,Album2,AlbumN` a plain HTML version