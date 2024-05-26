# Woomer - Boomer but for wayland

Zoomer application for wayland (linux) inspired by [tsoding's boomer](https://github.com/tsoding/boomer) written in rust

![demo of woomer](./demo.gif)

## Controls

- CTRL: show spotlight
- CTRL + SHIFT: Control spotlight radius using your mouse scroll
- You can drag your mouse
- Scrolling zooms in and out
- ESC or right click exits woomer
- R: Hot reload shaders (only works with `dev` feature)

## Building

Dependencies:

- wayland-client
- cmake
- rust
- pkg-config

Like with any other rust program you can run:

```sh
cargo b
```

However if you want hot reloading of the spotlight shader you can add the `dev` feature:

```sh
cargo b -F dev
```

## Installing using the Nix flake

You can also install woomer using the nix flake:

```nix
# flake.nix
{
  inputs = {
    woomer.url = "github:coffeeispower/woomer";
    # .....
  }
  # ....
}
```

After that, you can just install it along with wayland package

```nix
{inputs, system, ...}:
{
  home.packages = [
    # Required for the wayland-client library which is loaded at runtime
    wayland
    inputs.woomer.packages.${system}.default
    # ....
  ];
  # ....
}
```

If you're using hyprland or other wayland compositors configured using home manager and want to bind woomer to a key,
you have to set `LD_LIBRARY_PATH` for it to open correctly:
`LD_LIBRARY_PATH=${pkgs.wayland}/lib ${inputs.woomer.packages.${system}.default}/bin/woomer`  
I'm pretty sure there's a better way to do this automatically on my side but I haven't figured out yet.
