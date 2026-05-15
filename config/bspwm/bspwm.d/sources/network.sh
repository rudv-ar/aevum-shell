#!/bin/bash

# file : network.sh
# function : sourced by autostart.sh and other scripts involving network configuration


############################################ BOOLEANS ##########################################
# [ tip : these bools are used for logic gating and selective execution]

# is network enabled?
is_net=true

# is ethernet enabled?
is_net_ethernet=true

# is firewall enabled?
is_net_firewall=true

# is tor enabled?
is_net_tor=false

# is wifi enabled?
is_net_wifi=true

######################################### ETHERNET #############################################
# define the default ethernet interface
net_ethernet_interface='eth0'

# is this the real ethernet mac address?
net_ethernet_mac='aa:bb:cc:dd:ee:ff'

######################################## FIREWALL ##############################################

# define the firewall backend
net_firewall_backend='ufw'

# define the log levels
net_firewall_log_level='warn'

# firewall rules location
net_firewall_rules='/etc/firewall.rules'
net_retry=3
net_timeout=30

####################################### WIFI STUFF #############################################
net_wifi_driver='iwlwifi'
net_wifi_interface_1='wlan0'
net_wifi_interface_2='wlan1'


####################################### THE TOR HERE? #########################################
# set up tor proxy port
net_tor_proxy_port=9050

# set up the default tor config
net_tor_torrc="$HOME/.config/bspwm/apps/tor-instance/torrc"

# the below given are custom tor paths (visible only if tor is enabled)

net_tor_torerrors="$HOME/.config/bspwm/apps/tor-instance/errors/"
net_tor_torinstance="$HOME/.config/bspwm/apps/tor-instance"
net_tor_torlogs="$HOME/.config/bspwm/apps/tor-instance/logs"
