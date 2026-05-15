pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs.settings

Singleton {
    id: root

    readonly property PwNode sink:   Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    readonly property real   volume:        sink?.audio?.volume ?? 0.0
    readonly property bool   muted:         sink?.audio?.muted  ?? false
    readonly property bool   ready:         sink?.ready         ?? false
    readonly property int    volumePercent: Math.round(volume * 100)
    readonly property string volumeString:  volumePercent + "%"

    readonly property string iconGlyph: {
        if (muted || volume <= 0.0) return "\uf6a9"
        if (volume < 0.34)          return "\uf026"
        if (volume < 0.67)          return "\uf027"
        return                             "\uf028"    
    }

    function setVolume(v) {
        if (!root.ready || !sink?.audio) return
        sink.audio.volume = Math.max(0.0, Math.min(1.0, v))
    }

    function toggleMute() {
        if (!root.ready || !sink?.audio) return
        sink.audio.muted = !sink.audio.muted
    }

    function adjustVolume(delta) {
        setVolume(root.volume + delta)
    }
}

