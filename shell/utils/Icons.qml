pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    // Font family name mapped to Google's Material Icons/Symbols font file
    readonly property string fontFamily: "Material Symbols Rounded"

    // ── Exact class name → 4-digit MDI web codepoint ─────────────
    readonly property var _exact: ({
        // Terminals
        "kitty":            "terminal",   // terminal / code
        "alacritty":        "terminal",
        "wezterm":          "terminal",
        "st":               "terminal",
        "urxvt":            "terminal",
        "xterm":            "terminal",
        "foot":             "terminal",
        "konsole":          "terminal",
        "gnome-terminal":   "terminal",
        "tilix":            "terminal",
        "xfce4-terminal":   "terminal",
        // Browsers
        "firefox":          "captive_portal",   // language / web
        "librewolf":        "\ue894",
        "qutebrowser":      "\ue894",
        "chromium":         "\ue894",
        "google-chrome":    "\ue894",
        "brave-browser":    "\ue894",
        "thorium-browser":  "\ue894",
        "vivaldi-stable":   "\ue894",
        // Editors / IDE
        "code":             "\ue86f",   // code
        "code-oss":         "\ue86f",
        "vscodium":         "\ue86f",
        "neovide":          "\ue86f",
        "emacs":            "\ue86f",
        "zed":              "\ue86f",
        // File managers
        "thunar":           "\ue2c7",   // folder
        "nautilus":         "\ue2c7",
        "pcmanfm":          "\ue2c7",
        "nemo":             "\ue2c7",
        "dolphin":          "\ue2c7",
        "ranger":           "\ue2c7",
        "yazi":             "\ue2c7",
        // Music
        "spotify":          "\ue405",   // music_note
        "rhythmbox":        "\ue405",
        "clementine":       "\ue405",
        "deadbeef":         "\ue405",
        "ncmpcpp":          "\ue405",
        "cmus":             "\ue405",
        // Video
        "mpv":              "\ue04b",   // play_arrow / video
        "vlc":              "\ue04b",
        "celluloid":        "\ue04b",
        // Image
        "feh":              "\ue3f4",   // image
        "sxiv":             "\ue3f4",
        "nsxiv":            "\ue3f4",
        "eog":              "\ue3f4",
        "gimp":             "\ue3f4",
        "inkscape":         "\ue3f4",
        // Chat
        "discord":          "\ue0b7",   // chat / message
        "telegram-desktop": "\ue163",   // send
        "signal":           "\ue0b7",
        "element":          "\ue0b7",
        "slack":            "\ue0b7",
        // Mail
        "thunderbird":      "\ue158",   // mail
        "geary":            "\ue158",
        // Games
        "steam":            "\ue338",   // gamepad
        "lutris":           "\ue338",
        "heroic":           "\ue338",
        // Misc
        "obsidian":         "\ue865",   // description / text-document
        "zathura":          "\ue24d",   // insert_drive_file
        "evince":           "\ue24d",
        "pavucontrol":      "\ue050",   // volume_up
        "arandr":           "\ue31e",   // monitor / hardware
        "lxappearance":     "\ue8b8",   // settings / gear
    })

    // ── Category fallback (substring match) ───────────
    readonly property var _categories: [
        { keys: ["firefox","librewolf","chromium","brave","qutebrowser",
                 "thorium","vivaldi","epiphany","falkon"],
          cp: "\ue894" },
        { keys: ["kitty","alacritty","wezterm","urxvt","xterm","foot",
                 "konsole","tilix","terminal","term"],
          cp: "terminal" },
        { keys: ["code","vscodium","neovide","nvim","vim","emacs",
                 "zed","idea","pycharm","clion","rider","sublime"],
          cp: "\ue86f" },
        { keys: ["thunar","nautilus","pcmanfm","nemo","dolphin",
                 "ranger","yazi","files"],
          cp: "\ue2c7" },
        { keys: ["spotify","rhythmbox","deadbeef","cmus","ncmpcpp",
                 "clementine","music"],
          cp: "\ue405" },
        { keys: ["mpv","vlc","celluloid","totem","video"],
          cp: "\ue04b" },
        { keys: ["feh","sxiv","nsxiv","eog","gimp","inkscape","image",
                 "photo","viewer"],
          cp: "\ue3f4" },
        { keys: ["discord","telegram","signal","element","slack",
                 "matrix","chat"],
          cp: "\ue0b7" },
        { keys: ["thunderbird","geary","mail","mutt","neomutt"],
          cp: "\ue158" },
        { keys: ["steam","lutris","heroic","game","games"],
          cp: "\ue338" },
        { keys: ["settings","config","preferences","control"],
          cp: "\ue8b8" },
    ]

    // ── Public API ────────────────────────────────────
    function getIcon(className) {
        if (!className || !className.length) return "\ue8a6"   // open_in_full / maximize window fallback
        var lower = className.toLowerCase()

        if (_exact[lower]) return _exact[lower]

        for (var i = 0; i < _categories.length; i++) {
            var cat = _categories[i]
            for (var j = 0; j < cat.keys.length; j++) {
                if (lower.indexOf(cat.keys[j]) !== -1) {
                    return cat.cp
                }
            }
        }

        return "\ue8a6"   // Fallback window icon
    }
}

