# Photoprism Slideshow

A very basic Picture Frame side-app for [Photoprism](https://www.photoprism.app/).

Easiest to use with NixOS as a flake, but can be used outside. 

## Usage

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