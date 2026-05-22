#!/usr/bin/env bash
# srcrec.sh — ffmpeg x11grab screen recorder with region select
# deps: ffmpeg, xdpyinfo, slop (for region mode)
# install: cp srcrec.sh ~/.local/bin/srcrec && chmod +x ~/.local/bin/srcrec

# ── Defaults ────────────────────────────────────────────────────
framerate=24
crf=23
preset="ultrafast"
output="output_$(date +%Y%m%d_%H%M%S).mp4"
scale="native"
draw_mouse=0
audio=0
duration=0
dry_run=0
display=":0.0"
region=0        # 0 = fullscreen, 1 = mouse-select region via slop

# ── State file ───────────────────────────────────────────────────
state_file="${HOME}/.config/aevum/settings/states/srcrec.state"

kill_previous() {
    if [[ -f "$state_file" ]]; then
        old_pid=$(grep '^pid=' "$state_file" | cut -d= -f2)
        if [[ -n "$old_pid" ]] && kill -0 "$old_pid" 2>/dev/null; then
            echo "[srcrec] killing previous recording (pid $old_pid)"
            kill -INT "$old_pid"
            # wait up to 2s for clean exit
            for i in {1..4}; do
                sleep 0.5
                kill -0 "$old_pid" 2>/dev/null || break
            done
            # force kill if still alive
            kill -0 "$old_pid" 2>/dev/null && kill -KILL "$old_pid"
        fi
        rm -f "$state_file"
    fi
}

write_state() {
    local ffmpeg_pid="$1"
    mkdir -p "$(dirname "$state_file")"
    cat > "$state_file" <<EOF
pid=$ffmpeg_pid
file=$output
started=$(date +%s)
EOF
}

cleanup() {
    rm -f "$state_file"
}
trap cleanup EXIT

# ── Usage ────────────────────────────────────────────────────────
usage() {
    cat <<HELP
srcrec — screen recorder (ffmpeg + x11grab)

Usage: srcrec [options]

Options:
  -r INT     Framerate          (default: 24)
  -c INT     CRF quality 0-51   (default: 23, lower = better)
  -p STR     x264 preset        (default: ultrafast)
             [ultrafast|superfast|veryfast|faster|fast|medium]
  -o FILE    Output filename    (default: output_TIMESTAMP.mp4)
  -s RES     Output scale       (default: native)
             [360|480|720|1080|native]
  -m 0|1     Draw mouse cursor  (default: 0)
  -a         Record audio       (default: off, uses pulse default)
  -d INT     Duration seconds   (default: 0 = unlimited)
  -D STR     X display          (default: :0.0)
  -R         Region select mode (draw region with mouse via slop)
  -n         Dry run, print command only
  -h         Show this help

Examples:
  srcrec                       # fullscreen, 24fps, no audio
  srcrec -R                    # select region with mouse
  srcrec -R -s 720             # region, upscale to 720p
  srcrec -s 480 -r 20          # fullscreen 480p, 20fps
  srcrec -s 1080 -r 30 -a      # fullscreen 1080p + audio
  srcrec -d 60 -o demo.mp4     # record for 60 seconds
  srcrec -n -R                 # dry run region mode
HELP
}

# ── Arg parsing ──────────────────────────────────────────────────
while getopts "r:c:p:o:s:m:ad:D:Rnh" opt; do
    case "$opt" in
        r) framerate="$OPTARG" ;;
        c) crf="$OPTARG" ;;
        p) preset="$OPTARG" ;;
        o) output="$OPTARG" ;;
        s) scale="$OPTARG" ;;
        m) draw_mouse="$OPTARG" ;;
        a) audio=1 ;;
        d) duration="$OPTARG" ;;
        D) display="$OPTARG" ;;
        R) region=1 ;;
        n) dry_run=1 ;;
        h) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done

# ── Dependency check ─────────────────────────────────────────────
if ! command -v ffmpeg &>/dev/null; then
    echo "[srcrec] error: ffmpeg not found" >&2
    exit 1
fi

if [[ "$region" -eq 1 ]] && ! command -v slop &>/dev/null; then
    echo "[srcrec] error: slop not found (needed for -R region mode)" >&2
    echo "         install: yay -S slop" >&2
    exit 1
fi

# ── Scale map ────────────────────────────────────────────────────
declare -A scale_map=(
    [360]="640:360"
    [480]="854:480"
    [720]="1280:720"
    [1080]="1920:1080"
)

if [[ "$scale" != "native" ]] && [[ ! -v "scale_map[$scale]" ]]; then
    echo "[srcrec] error: invalid scale '$scale'. Use: 360 480 720 1080 native" >&2
    exit 1
fi

# ── Mode: REGION (slop) ──────────────────────────────────────────
if [[ "$region" -eq 1 ]]; then

    echo "[srcrec] draw a region with your mouse (drag to select, ESC to cancel)"

    slop_out=$(slop -f "%x %y %w %h" \
                    -b 2 \
                    -c 0.92,0.68,0.47,0.9 \
                    -l) || { echo "[srcrec] selection cancelled"; exit 1; }

    read -r rx ry rw rh <<< "$slop_out"

    # dimensions cannot be odd — increment by one pixel if needed
    (( rw % 2 != 0 )) && (( rw++ ))
    (( rh % 2 != 0 )) && (( rh++ ))

    if [[ "$rw" -lt 16 || "$rh" -lt 16 ]]; then
        echo "[srcrec] error: selected region too small (${rw}x${rh})" >&2
        exit 1
    fi

    capture_input="${display}+${rx},${ry}"
    capture_size="${rw}x${rh}"

    if [[ "$scale" == "native" ]]; then
        vf_chain="format=yuv420p"
    else
        vf_chain="scale=${scale_map[$scale]}:flags=lanczos,format=yuv420p"
    fi

    region_info="region    : ${rw}x${rh} at +${rx},${ry}"

# ── Mode: FULLSCREEN ─────────────────────────────────────────────
else

    raw_dims=$(xdpyinfo 2>/dev/null | awk '/dimensions/{print $2}')
    raw_w=$(echo "$raw_dims" | cut -dx -f1)
    raw_h=$(echo "$raw_dims" | cut -dx -f2)

    capture_input="$display"
    capture_size="${raw_w}x${raw_h}"

    if [[ "$scale" == "native" ]]; then
        vf_chain="format=yuv420p"
    else
        vf_chain="scale=${scale_map[$scale]}:flags=lanczos,format=yuv420p"
    fi

    region_info="dimensions: ${raw_w}x${raw_h}"

fi

# ── Build ffmpeg command ──────────────────────────────────────────
cmd=(ffmpeg)

# input
cmd+=(-f x11grab -r "$framerate")
[[ -n "$capture_size" ]] && cmd+=(-video_size "$capture_size")
cmd+=(-i "$capture_input")

# audio
[[ "$audio" -eq 1 ]] && cmd+=(-f pulse -i default)

# duration
[[ "$duration" -gt 0 ]] && cmd+=(-t "$duration")

# video filters + codec
cmd+=(-vf "$vf_chain")
cmd+=(-c:v libx264 -preset "$preset" -crf "$crf")
cmd+=(-draw_mouse "$draw_mouse")

# audio codec
[[ "$audio" -eq 1 ]] && cmd+=(-c:a aac -b:a 128k)

# progress + output
cmd+=(-progress pipe:1 -nostats)
cmd+=("$output")

# ── Dry run ──────────────────────────────────────────────────────
if [[ "$dry_run" -eq 1 ]]; then
    echo "[srcrec] dry run:"
    echo "  ${cmd[*]}"
    exit 0
fi

# ── Kill any previous recording ──────────────────────────────────
kill_previous

# ── Info banner ──────────────────────────────────────────────────
echo "[srcrec] starting recording"
echo "  mode      : $([ "$region" -eq 1 ] && echo region || echo fullscreen)"
echo "  $region_info"
echo "  framerate : ${framerate}fps"
echo "  scale     : $scale"
echo "  crf       : $crf  preset: $preset"
echo "  audio     : $([ "$audio" -eq 1 ] && echo yes || echo no)"
echo "  output    : $output"
echo "  duration  : $([ "$duration" -gt 0 ] && echo "${duration}s" || echo unlimited)"
echo "  press Ctrl+C to stop"
echo ""

# ── Record ───────────────────────────────────────────────────────
# Use a FIFO so ffmpeg runs as a direct child (gives us its real PID),
# and we can still read its -progress output from the other end.

# close any actions pane before recording beings in case it is called from the pane 

qs -p ~/.config/bspwm/shell/rightpane/shell.qml ipc call rightpane close
progress_fifo=$(mktemp -u /tmp/srcrec_progress.XXXXXX)
mkfifo "$progress_fifo"
trap 'rm -f "$progress_fifo"; rm -f "$state_file"' EXIT

start_time=$(date +%s)

# Launch ffmpeg with stdout → FIFO, capture PID immediately
"${cmd[@]}" > "$progress_fifo" 2>/dev/null &
ffmpeg_pid=$!
write_state "$ffmpeg_pid"

# Read progress from the FIFO in the foreground
while IFS= read -r line; do
    if [[ "$line" == out_time=* ]]; then
        t="${line#out_time=}"
        t="${t%.*}"
        printf "\r[srcrec] REC %s" "$t"
    fi
done < "$progress_fifo"

wait "$ffmpeg_pid"
ffmpeg_exit=$?

rm -f "$progress_fifo"
end_time=$(date +%s)
elapsed=$(( end_time - start_time ))
echo ""

# ── Summary ──────────────────────────────────────────────────────
if [[ -f "$output" ]]; then
    size=$(du -h "$output" | cut -f1)
    mins=$(( elapsed / 60 ))
    secs=$(( elapsed % 60 ))
    printf "[srcrec] done\n"
    printf "  duration : %02d:%02d\n" "$mins" "$secs"
    printf "  file     : %s (%s)\n" "$output" "$size"
else
    echo "[srcrec] recording failed or no output written" >&2
    exit 1
fi

exit "$ffmpeg_exit"

