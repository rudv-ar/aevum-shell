#!/bin/bash

# file : services.sh
# function : sourced by autostart.sh to start services 

####################################### SERVICES ####################################
# is dunst active?
is_svc_dunst=false # replaced by shell native notify manager

# is mpd active?
is_svc_mpd=true

# is picom active?
is_svc_picom=true

# is snapsever running?
is_svc_snapserver=false # no longer required.

# what about vicinae?
is_svc_vicinae=true

# now comming to kdeconnectd
is_svc_kdeconnectd=true
