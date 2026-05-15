#!/bin/bash

# file : bspwm.sh
# function : sources the config.sh file, applies all the configs

##################################################### SOURCES ###########################################
# source the necessary import files...
source "/home/rudv-ar/.config/bspwm/bspwm.d/exports.sh"

##################################################### BORDERS ###########################################
# set the border colors
bspwm_borders_active_color='#000000'
bspwm_borders_focused_color='#414868'
bspwm_borders_normal_color='#1e1e2e'

# set the border style
bspwm_borders_style='solid'

# set the border width 
bspwm_borders_width=2

##################################################### MONOCLE ############################################

bspwm_monocle_borderless=false
bspwm_monocle_gapless=false
bspwm_monocle_single=false

#################################################### PRESEL ##############################################

# setting the color for presel feedback
bspwm_presel_pfc='#000000'

# is bspwm having presel enabled? --> [ tip : see the BOOLEANS section...]

################################################### WINDOWS ##############################################

# set the window manager initial polarity and split scheme
bspwm_scheme_automatic_initial_polarity='second_child'
bspwm_scheme_automatic_scheme='spiral'

# set the window manager gap 
bspwm_window_gapped_gap=10

# set additional window manager padding
bspwm_window_padded_bottom=10
bspwm_window_padded_left=10
bspwm_window_padded_right=10
bspwm_window_padded_top=35

# set the status prefix
bspwm_window_prefix=''

# define the split ratio
bspwm_window_sr_ratio=0.5

################################################### BOOLEANS ###############################################

# [ tip : define the booleans so that scripts can apply logic upon them ]

# is bspwm having borders?
is_bspwm_borders=true

# is bspwm showing presel feedback?
is_bspwm_presel=false

# is bspwm set to automatic scheme?
is_bspwm_scheme_automatic=true

# is bspwm have gaps between windows?
is_bspwm_window_gapped=true

# is there any additional padding?
is_bspwm_window_padded=false


############################################## NOW THAT THE TRUTH CAN BE READ ###############################
# Signature? signed by toml-core via toml-to-sh
# Parent : bspwm.toml 


