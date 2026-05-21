# Aevum Shell 

Have you ever wondered how quickshell works in wayland? But it's documentation says - it is not exclusive for wayland alone. It's basic non wayland features are compactible with x11 as well, but we need to do other logic lifting which is not in x11 that is in wayland via scripts. 

## Why Aevum Shell? 

Being born into a desktop with low spec hardware - having all of the constraints that a student should not have (i.e, any programmer) - *2 GB DDR2 RAM*, *150 GB SATA HDD*, *BIOS input output system - Pheonix BIOS*, having *OPENGL version <=2.1* and *intel duo core* and *no notable GPU*,  my x11 managed to run the current state quickshell system. 

This is specifically designed with constraints in mind - for low end systems, legacy systems, and x11 more importantly. 

**Aevum Shell** is only for *tiling window managers* - whatever it is : 

- BSPWM -> the current choice of config. 
- I3WM -> future project after finishing BSPWM's shell intergrations.
- DWM -> ......
- ...... others too - planning to do it for most of the x11 WMs.

>[!NOTE]
> I was inspired to build **Aevum** - mainly because I need to use **caelestia shell** - but as I am in *X11* and not *Wayland* (constraints : opengl), I was in a need to build caelestia shell specifically for x11 usage. (it is rare though - you would not have seen a quickshell config for x11.)

## Is Quickshell usable in X11? 

**Absolutely yes.** Atleast, that is what the official documentation says so. You can read about it from [here](https://quickshell.org/about/). As quichshell is essentially a **wrapper** for [QML](https://doc.qt.io/qt-6/qml-tutorial.html) :

- It works **as smooth as** any other Qt based application.
- Extremely themeable.
- Ah come on, I am not advertising anymore. 

### But!!! 

**What about animations?** 

I am not going to assure you that animations will be very fluid like water in you desktop - but animations work - they exist, they are tunable. It would be more comfortable if you have : 

- **Some GPU that is not old**
- **OPENGL 3+ version** 
- **Good processor that is not `intel duo core`**
- **2GB+ RAM that is not `DDR2`**

>[!NOTE]
> All the above stuffs are a baseline and I am in a baseline system - Animations are not very fluid as in caelestia shell, but they are smooth enough to be visually processed. 


## Installation Process 

>[!IMPORTANT]
> This shell is based on pre installed themes, icons and fonts that come along with **archcraft** distribution. (Nothing but arch with pre installed themes). So you would be prompted to add archcraft repo to your `/etc/pacman.conf`. If you prefer to go with your own themes - **You are very well welcomed to skip that step**


