# Aevum Shell 

## what is aevum

aevum is a personal bspwm shell for Arch Linux. It is not a desktop environment, not a framework, and not meant to be generic. It is a tightly configured, opinionated rice built around a specific workflow — keyboard-driven, minimal, fast, and visually deliberate. I ported this from my previous project - [rudv-shell-1.0](https://github.com/rudv-ar/rudv-shell-1.0).

The name comes from the Latin *aevum* — meaning age or era. A small nod to the `revolution-18` idea this started from.

## Preview

>[!NOTE]
> This is in a low ram environment - so video can be lagging; ignore the lagging video and see the features alone. 

[Video Here](./assets/shell.mp4)

![View](./assets/view.png)

## stack

| role | tool |
|---|---|
| window manager | bspwm |
| hotkey daemon | sxhkd |
| compositor | picom (v12) |
| bar | quickshell |
| terminal | alacritty |
| shell | fish |
| prompt | starship |
| notifications | dunst |
| launcher | rofi |
| dock | plank |
| file manager | ranger |
| editor | neovim |
| media | mpv + mpd + ncmpcpp |
| theming | matugen + archcraft themes |
| lockscreen | betterlockscreen |


## structure

```
~/.config/aevum/
├── config/          # all app configs (symlinked to ~/.config/<app>)
│   ├── bspwm/
│   ├── sxhkd/
│   ├── kitty/
│   ├── fish/
│   ├── nvim/
│   ├── rofi/
│   ├── dunst/
│   ├── picom/
│   ├── ranger/
│   ├── vicinae/
│   └── ...
├── deps.sh          # dependency manager + installer
└── linker.sh        # symlink manager
```


## setup

**1. clone**

```
git clone https://github.com/yourname/aevum ~/.config/aevum
cd ~/.config/aevum
git switch main
```

**2. install deps**

```
bash ~/.config/aevum/deps.sh
```

Launches an interactive menu. Run option 1 first (repo + keyring), then 4 (install everything). Requires `yay` for AUR packages.

**3. link configs**

```
bash ~/.config/aevum/linker.sh add-all
```

Symlinks everything from `aevum/config/` into `~/.config/`. Safe to rerun — real directories get purged and relinked, existing symlinks are left alone unless you pass `-f`.


## branch model

| branch | purpose |
|---|---|
| `main` | stable, daily-driver config |
| `dev` | active development, experimental changes |

Switching branches live-switches your entire config instantly since everything is symlinked into the source tree.

```
git switch main   # stable rolling
git switch dev    # experimental
git switch stable # stable - slow releasing
```

Some apps only pick up changes after a restart or reload.

## tools

**deps.sh** — manages dependencies

```
deps install all
deps install pacman / yay
deps install <pkg> -f
deps verify all
deps setup keyring
deps setup keyring -r
```

**linker.sh** — manages symlinks

```
linker add <app> [-f]
linker remove <app> [-f]
linker verify <app> [-f]
linker add-all [-f]
linker verify-all [-f]
```


## hardware target

Built on constrained hardware — Intel GMA 900 (i915, GLES2 only), 2GB DDR2, BIOS system. All choices are made with this in mind. No Wayland. No heavy compositing tricks. No GPU-dependent effects. So, from my opinion, this should work for any age old processor and hardware. 


## status

early dev. structure is stable, configs are being migrated and tuned. not ready for anyone else to use completely - but only working stuffs are pushed - so you can try it.

## for developers 

While switching the git branches in the ~/.config/aevum, the picom compositor and quickshell may apply changes immeditately. If you feel that the UI is somewhat misalligned, either of the following should fix it : 

```bash
pkill qs && ~/.config/bspwm/widgets/quickshell/launch.sh & 
# or, reload the wm 
hotkey : press ctrl + shift + r

```
