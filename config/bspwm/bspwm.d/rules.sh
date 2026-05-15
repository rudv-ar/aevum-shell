#!/bin/bash 

################################# Declare Variables #####################################
#-----------------------------------Web Apps---------------------------------------------
declare -a code=(
    Geany 
    code-oss
)

#------------------------------Office Apps-----------------------------------------------
declare -a office=(
    Gucharmap 
    Atril 
    Evince
    libreoffice-writer 
    libreoffice-calc 
    libreoffice-impress
    libreoffice-startcenter 
    libreoffice 
    Soffice 
    *:libreofficedev 
    *:soffice
)

#-------------------------------Media Apps-----------------------------------------------
declare -a media=(
    Audacity 
    Music 
    MPlayer 
    Lxmusic 
    Inkscape 
    Gimp-2.10 
    obs
)

#-------------------------------system settings------------------------------------------
declare -a settings=(
    Lxappearance 
    toml-gui
    ty-wall
    Lxtask 
    Lxrandr
    bspwm-settings
    Arandr
    System-config-printer.py 
    Pavucontrol Exo-helper-1
    Xfce4-power-manager-settings
)

#----------------------------always floating apps----------------------------------------
declare -a floating=(
    alacritty-float 
    toml-gui
    ty-wall
    cavasik 
    kitty-float 
    Pcmanfm 
    Onboard 
    Yad 
    'Firefox:Places'
    Viewnior 
    feh 
    Nm-connection-editor 
    calamares 
    Calamares
    bspwm-settings
    scrcpy
)


################################## bspc rules ###########################################
## Manage all the unmanaged windows remaining from a previous session.
bspc wm --adopt-orphans

## remove all rules first
bspc rule -r *:*

#------------------------------ Define Window Specific Applications----------------------

# Open desktop in workspace 1
# You can add something here, like the for looped declarative aproach!


# Open web apps in workspace 2
bspc rule -a firefox desktop='^2' follow=on focus=on
bspc rule -a chromium desktop='^2' follow=on focus=on


# Open code apps in workspace 4
for i in ${code[@]}; do
   bspc rule -a $i desktop='^4' follow=on focus=on 
done


# Open office apps in workspace 5
for i in ${office[@]}; do
   bspc rule -a $i desktop='^5' follow=on focus=on 
done


# Open media apps in workspace 7
for i in ${media[@]}; do
   bspc rule -a $i desktop='^7' state=floating follow=on focus=on 
done


# Open system settings in workspace 8
bspc rule -a 'VirtualBox Manager' desktop='^8' follow=on focus=on
bspc rule -a GParted desktop='^8' follow=on focus=on

for i in ${settings[@]}; do
   bspc rule -a $i desktop='^8' state=floating follow=on focus=on
done


# Always floating apps
for i in ${floating[@]}; do
   bspc rule -a $i state=floating follow=on focus=on; done

############################# vicinae, toml-gui position, etc #######################################
bspc rule -a vicinae state=floating follow=on focus=on border=false rectangle=700x500+350+768
bspc rule -a command state=floating follow=on focus=on border=false rectangle=700x500+350+768
#bspc rule -a toml-gui state=floating follow=on focus=on border=false sticky=true rectangle=700x500+350+768
#bspc rule -a ty-wall state=floating follow=on focus=on border=false sticky=true rectangle=700x253+350+768
bspc rule -a Plank manage=off

############################## General Rules #########################################

bspc rule -a stalonetray state=floating manage=off
bspc rule -a '' name=quickshell state=floating layer=above sticky=on focusable=off border=off
bspc rule -a 'qs-topbar:qs-topbar' manage=on border=off locked=on sticky=on layer=above state=floating focus=off

############################ External Rules ##########################################

# if you have any, then place them @ exter_rules dir and run from there.



