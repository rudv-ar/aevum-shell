pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Singleton {
    id: root

    // ── Sink (output) ─────────────────────────────────
    readonly property PwNode sink:   Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    readonly property real volume:       sink?.audio?.volume   ?? 0
    readonly property bool muted:        sink?.audio?.muted    ?? false
    readonly property real sourceVolume: source?.audio?.volume ?? 0
    readonly property bool sourceMuted:  source?.audio?.muted  ?? false

    // ── All nodes ─────────────────────────────────────
    property list<PwNode> sinks:   []
    property list<PwNode> sources: []
    property list<PwNode> streams: []

    // ── Sink control ──────────────────────────────────
    function setVolume(v: real): void {
        if (!sink?.ready || !sink?.audio) return
        sink.audio.muted  = false
        sink.audio.volume = Math.max(0, Math.min(1.5, v))
    }

    function incrementVolume(): void { setVolume(volume + 0.05) }
    function decrementVolume(): void { setVolume(volume - 0.05) }

    function toggleMute(): void {
        if (sink?.ready && sink?.audio)
            sink.audio.muted = !sink.audio.muted
    }

    // ── Source control ────────────────────────────────
    function setSourceVolume(v: real): void {
        if (!source?.ready || !source?.audio) return
        source.audio.muted  = false
        source.audio.volume = Math.max(0, Math.min(1.5, v))
    }

    function incrementSourceVolume(): void { setSourceVolume(sourceVolume + 0.05) }
    function decrementSourceVolume(): void { setSourceVolume(sourceVolume - 0.05) }

    function toggleSourceMute(): void {
        if (source?.ready && source?.audio)
            source.audio.muted = !source.audio.muted
    }

    // ── Output cycling ────────────────────────────────
    function cycleOutput(): void {
        if (sinks.length === 0) return
        const i = sinks.findIndex(s => s === sink)
        Pipewire.preferredDefaultAudioSink = sinks[(i + 1) % sinks.length]
    }

    function setAudioSink(node: PwNode):   void { Pipewire.preferredDefaultAudioSink   = node }
    function setAudioSource(node: PwNode): void { Pipewire.preferredDefaultAudioSource = node }

    // ── Stream helpers ────────────────────────────────
    function getStreamVolume(stream: PwNode): real { return stream?.audio?.volume ?? 0 }
    function getStreamMuted(stream: PwNode):  bool { return !!stream?.audio?.muted }

    function setStreamVolume(stream: PwNode, v: real): void {
        if (!stream?.ready || !stream?.audio) return
        stream.audio.muted  = false
        stream.audio.volume = Math.max(0, Math.min(1.5, v))
    }

    function setStreamMuted(stream: PwNode, m: bool): void {
        if (stream?.ready && stream?.audio) stream.audio.muted = m
    }

    function getStreamName(stream: PwNode): string {
        if (!stream) return "Unknown"
        return stream.properties["application.name"] || stream.description || stream.name || "Unknown"
    }

    // ── Node tracking ─────────────────────────────────
    Connections {
        target: Pipewire.nodes
        function onValuesChanged(): void {
            const ns = [], nr = [], nm = []
            for (const n of Pipewire.nodes.values) {
                if (!n.isStream) {
                    if (n.isSink)     ns.push(n)
                    else if (n.audio) nr.push(n)
                } else if (n.audio)   nm.push(n)
            }
            root.sinks   = ns
            root.sources = nr
            root.streams = nm
        }
    }

    PwObjectTracker {
        objects: [...root.sinks, ...root.sources, ...root.streams]
    }
}
