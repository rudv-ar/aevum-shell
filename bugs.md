[branch : dev]

:::to fix the following:::

::date - 22-05-2026

[status : pending]

: srcrec.sh - add file duplication logic
    ask either to overwrite |
    ask to record in new file | 

: SrcRec.qml - fix the mpv play logic 
    it should be able to play even when the recording is done via cmd line | 
    it should use the statefile for this purpose to play |
    it should be able to play from any rec, not just from videos directory |

[status : fixed]

: *Properties.qml - migrate to config logic 
    now users can change the settings via ~/.config/aevum/settings/config.json | 
    soon to be integrated into a settings gui |

:::to add the following:::

[status : pending]

: Caffeine.qml 
    a caelestia style always on mode using caffeine | 
    add exactly similar toggleable features as in caelestia |

: config.json 
    this config has all editable options, including padding | 
    add a new settings.json and a shell script to make changes in config.json based on settings.json |

[status : added]



