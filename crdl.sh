#!/bin/sh

help='usage: download campaign from to autonumber [ volume ]

options:
    campaign      The number of the campaign to download from.
    from          The playlist item number of the first video.
    to            The playlist item number of the last video.
    autonumber    The episode number of the first video.
    volume        Set a value for the ffmpeg volume filter.'

# Check argument count and set volume filter if requested.
if [ $# -lt 4 -o $# -gt 5 ]; then
    printf '%s\n' "$help"
    exit 1
elif [ $# -eq 4 ]; then
    volume_filter="-c:a copy"
else
    volume_filter="-filter:a 'volume=${5}'"
fi

# Select correct URL.
if [ $1 -eq 1 ]; then
    url='https://youtube.com/playlist?list=PL1tiwbzkOjQz7D0l_eLJGAISVtcL7oRu_&si=_aR48fnGiVEruCYc'
elif [ $1 -eq 2 ]; then
    url='https://youtube.com/playlist?list=PL1tiwbzkOjQxD0jjAE7PsWoaCrs0EkBH2&si=CxL0i_3ZTPQJ0YQ5'
elif [ $1 -eq 3 ]; then
    url='https://youtube.com/playlist?list=PL1tiwbzkOjQydg3QOkBLG9OYqWJ0dwlxF&si=UiPOXygq34SIvulj'
else
    printf '%s\n' "error: campaign ${1} not found" >&2
    exit 1
fi

manual_ppc="mv %(filepath)q '%(filepath)s.tmp';ffmpeg -y -i '%(filepath)s.tmp' -map 0 -c:v copy -c:s copy ${volume_filter} -f mp4 %(filepath)q;rm '%(filepath)s.tmp'"

# Invoke yt-dlp.
yt-dlp \
    --playlist-items "${2}:${3}" \
    --yes-playlist \
    --concurrent-fragments 6 \
    --output "Critical.Role.C${1}E%(autonumber-1+${4})03d.%(title)s.%(ext)s" \
    --format "bv*[vcodec~='^((he|a)vc|h26[45])']+ba[acodec~='^(aac|mp4a.*)']" \
    --embed-subs \
    --sub-format 'srt' \
    --embed-thumbnail \
    --convert-thumbnails 'png' \
    --merge-output-format 'mp4' \
    --remux-video 'mp4' \
    --exec "$manual_ppc" \
    $url
