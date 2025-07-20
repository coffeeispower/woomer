# Woomer - Boomer but for wayland

Zoomer application for wayland (linux) inspired by [tsoding's boomer](https://github.com/tsoding/boomer) written in rust

![demo of woomer](./demo.gif)

## Controls

| Control                                                   | Description                                  |
|-----------------------------------------------------------|----------------------------------------------|
| Right Click, <kbd>ESC</kbd>, <kbd>A</kbd> or <kbd>Q</kbd> | Quit the application.                        |
| <kbd>R</kbd>                                              | Reload the shaders (only for Developer mode) |
| Hold <kbd>CTRL</kbd>                                      | Enable flashlight effect.                    |
| Drag with left mouse button                               | Move the image around.                       |
| Scroll wheel                                              | Zoom in/out.                                 |
| <kbd>Ctrl</kbd> + <kbd>SHIFT</kbd> + Scroll wheel         | Change the radius of the flashlight.         |

## HiDPI Displays
### Hyprland
If you set your scaling different to 1.0 in your .config/hypr/hyprland.conf, you also need the following variables to be set:
```sh
$scale = 2
monitor = , highres, auto, $scale

xwayland {
  force_zero_scaling = true
}
env = GDK_SCALE,$scale
```

Please also refer to: [Hyprland Wiki](https://wiki.hyprland.org/Configuring/XWayland/)

## Building

Dependencies:

- wayland-client
- cmake
- rust
- pkg-config
- clang (for compiling raylib)
- libclang (for bindgen)

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

After that, you can just install it

```nix
{inputs, system, ...}:
{
  home.packages = [
    inputs.woomer.packages.${system}.default
    # ....
  ];
  # ....
}
```
