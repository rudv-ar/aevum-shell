# Aevum Shell

Have you ever wondered how quickshell works in wayland? But its documentation says — it is not exclusive for wayland alone. Its basic non-wayland features are compatible with x11 as well, but we need to do other logic lifting which is not in x11 that is in wayland via scripts.

## Why Aevum Shell?

Being born into a desktop with low spec hardware — having all of the constraints that a student should not have (i.e, any programmer) — *2 GB DDR2 RAM*, *150 GB SATA HDD*, *BIOS input output system - Phoenix BIOS*, having *OpenGL version <=2.1* and *Intel Duo Core* and *no notable GPU* — my x11 managed to run the current state quickshell system.

This is specifically designed with constraints in mind — for low end systems, legacy systems, and x11 more importantly.

**Aevum Shell** is only for *tiling window managers* — whatever it is:

- **BSPWM** → the current choice of config.
- **i3WM** → future project after finishing BSPWM's shell integrations.
- **DWM** → ......
- ...... others too — planning to do it for most of the x11 WMs.

> [!NOTE]
> I was inspired to build **Aevum** mainly because I needed to use **caelestia shell** — but as I am on *X11* and not *Wayland* (constraints: OpenGL), I was in need of building a caelestia-style shell specifically for x11 usage. It is rare — you would not have seen a quickshell config for x11.

---

## Is Quickshell Usable in X11?

**Absolutely yes.** At least, that is what the official documentation says. You can read about it [here](https://quickshell.org/about/). As quickshell is essentially a **wrapper** for [QML](https://doc.qt.io/qt-6/qml-tutorial.html):

- It works **as smooth as** any other Qt based application.
- Extremely themeable.
- Ah come on, I am not advertising anymore.

### But!!!

**What about animations?**

I am not going to assure you that animations will be very fluid like water on your desktop — but animations work, they exist, they are tunable. It would be more comfortable if you have:

- **Some GPU that is not old**
- **OpenGL 3+ version**
- **A good processor that is not `Intel Duo Core`**
- **2GB+ RAM that is not `DDR2`**

> [!NOTE]
> All the above are a baseline — and I am on a baseline system. Animations are not as fluid as in caelestia shell, but they are smooth enough to be visually processed.

---

## Installation Process

> [!IMPORTANT]
> This shell is based on pre-installed themes, icons and fonts that come along with the **Archcraft** distribution — nothing but Arch with pre-installed themes. You will be prompted to add the Archcraft repo to your `/etc/pacman.conf`. If you prefer to use your own themes — **you are very well welcomed to skip that step.**

### Prerequisites

- An Arch-based Linux distribution
- X11 display server
- A supported tiling window manager (BSPWM recommended)
- `yay` or another AUR helper installed

### Steps

**1. Clone the repository**

```bash
git clone https://github.com/yourusername/aevum ~/.config/aevum
```

**2. Run the installer**

```bash
bash ~/.config/aevum/install.sh
```

This will:
- Install `fish` and set it as your default shell
- Link your fish config so `aevum` is immediately available
- Set up the Archcraft repo and keyring *(optional — skip if using your own themes)*
- Install all dependencies via `pacman` and `yay`
- Symlink all configs into `~/.config/`
- Symlink all local bins and share entries into `~/.local/`

**3. Open a new fish shell**

```bash
fish
```

`aevum` is now available. You can manage everything from here:

```
aevum deps install all        # install dependencies
aevum link-config add-all     # symlink configs
aevum link-local add-all      # symlink local bin/share
aevum deps verify all         # verify all deps
```

**4. Restart your session** and launch BSPWM.

---

## CLI — `aevum`

| Command | Description |
|---|---|
| `aevum` | cd into `~/.config/aevum` |
| `aevum deps <args>` | dependency manager |
| `aevum link-config <args>` | config symlink manager |
| `aevum link-local <args>` | local bin/share symlink manager |
| `aevum srcrec <args>` | screen recorder |
| `aevum help` | show usage |

---

## Credits

- [Quickshell](https://quickshell.org) — the shell framework that made this possible on X11
- [Caelestia Shell](https://github.com/caelestia-dots/shell) — the original inspiration
- [Archcraft](https://archcraft.io) — for the themes, icons, and fonts
