#!/usr/bin/env bash
# Turns a downloaded clip into a Bangunin video alarm.
#
#   tool/add_alarm_clip.sh <input-video> <id> [start-seconds] [length-seconds]
#
#   tool/add_alarm_clip.sh ~/Downloads/sahur.mp4 sahur_woi
#   tool/add_alarm_clip.sh ~/Downloads/phone.mp4 phone_ringing 3.5 8
#
# Writes three files to assets/clips/, then prints the AlarmClips entry to
# paste into lib/features/alarms/domain/alarm_clip.dart:
#
#   <id>.mp4  muted H.264 video, max 720px, 30fps (the ringing screen plays it)
#   <id>.m4a  the clip's audio, loudness-normalised hot for an alarm (the
#             alarm stream plays this, never the video, so media volume at 0
#             can't silence the alarm)
#   <id>.jpg  thumbnail for the picker and for the frame before video starts
#
# Needs ffmpeg and ffprobe on PATH. Songs are the one thing not to use here:
# a clip that is really a commercial track is what gets an app taken down.
set -euo pipefail

if [[ $# -lt 2 ]]; then
  sed -n '2,19p' "$0" | sed 's/^# \{0,1\}//'
  exit 64
fi

input=$1
id=$2
start=${3:-0}
length=${4:-}

if [[ ! -f $input ]]; then
  echo "error: no such file: $input" >&2
  exit 66
fi
if [[ ! $id =~ ^[a-z0-9_]+$ ]]; then
  echo "error: id must be lower_snake_case (a-z, 0-9, _): $id" >&2
  exit 65
fi
for bin in ffmpeg ffprobe; do
  command -v "$bin" >/dev/null || { echo "error: $bin not found" >&2; exit 69; }
done

root=$(cd "$(dirname "$0")/.." && pwd)
out="$root/assets/clips"
mkdir -p "$out"

trim=(-ss "$start")
[[ -n $length ]] && trim+=(-t "$length")

probe() { ffprobe -v error -show_entries "$1" -of csv=p=0 "$2"; }

if [[ -z $(probe stream=codec_type "$input" | grep -x audio || true) ]]; then
  echo "error: $input has no audio track, and the audio is the alarm" >&2
  exit 65
fi

# Long side capped at 720, short side kept even for H.264.
scale="scale='if(gt(iw,ih),min(720,iw),-2)':'if(gt(iw,ih),-2,min(720,ih))'"

echo "video..."
ffmpeg -v error -y "${trim[@]}" -i "$input" -an \
  -vf "$scale,fps=30" -c:v libx264 -profile:v main -pix_fmt yuv420p \
  -crf 28 -preset slow -movflags +faststart "$out/$id.mp4"

echo "audio..."
ffmpeg -v error -y "${trim[@]}" -i "$input" -vn \
  -af "loudnorm=I=-10:TP=-1:LRA=11" -ar 44100 -ac 2 \
  -c:a aac -b:a 128k "$out/$id.m4a"

echo "thumbnail..."
duration=$(probe format=duration "$out/$id.mp4")
at=$(awk -v d="$duration" 'BEGIN { t = d / 3; print (t > 1 ? 1 : t) }')
ffmpeg -v error -y -ss "$at" -i "$out/$id.mp4" -frames:v 1 \
  -vf "scale=360:-2" -q:v 4 "$out/$id.jpg"

audio_duration=$(probe format=duration "$out/$id.m4a")
bytes=$(( $(wc -c <"$out/$id.mp4") + $(wc -c <"$out/$id.m4a") + $(wc -c <"$out/$id.jpg") ))

printf '\n%s: %.1fs video, %.1fs audio, %s KB total\n' \
  "$id" "$duration" "$audio_duration" $(( bytes / 1024 ))
awk -v d="$duration" 'BEGIN { exit !(d > 30) }' &&
  echo "warning: over 30s. Alarms loop, so shorter clips hit harder and ship smaller."
(( bytes > 3 * 1024 * 1024 )) &&
  echo "warning: over 3 MB. Every bundled clip adds to the download size."

cat <<EOF

Add to AlarmClips.all in lib/features/alarms/domain/alarm_clip.dart:

    AlarmClip(
      id: '$id',
      titleEn: 'TODO',
      titleId: 'TODO',
      category: ClipCategory.funny,
      // onboarding: true,
    ),
EOF
