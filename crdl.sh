#!/bin/sh

progname="$(basename $0)"

help="usage: ${progname} <campaign> <from> <to> <autonumber> [ <volume> ]

options:
    campaign      The campaign to download from.
    from          The playlist item number of the first video.
    to            The playlist item number of the last video.
    autonumber    The episode number of the first video.
    volume        Set a value for the ffmpeg volume filter.

possible campaign values:
    VM            Campaign 1 – Vox Machina
    MN            Campaign 2 – Mighty Nein
    HB            Campaign 3 – Hells Bells
    EXU           Exandria Unlimited
    EXUC          Exandria Unlimited: Calamity
    EXUD          Exandria Unlimited: Divergence
    AU            Age of Umbra
    url           if none of the above, interpret as URL"

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
if [ "$1" = 'VM' ]; then
    url='https://youtube.com/playlist?list=PL1tiwbzkOjQz7D0l_eLJGAISVtcL7oRu_&si=_aR48fnGiVEruCYc'
    show='C1 - Vox Machina'
elif [ "$1" = 'MN' ]; then
    url='https://youtube.com/playlist?list=PL1tiwbzkOjQxD0jjAE7PsWoaCrs0EkBH2&si=CxL0i_3ZTPQJ0YQ5'
    show='C2 - Mighty Nein'
elif [ "$1" = 'HB' ]; then
    url='https://youtube.com/playlist?list=PL1tiwbzkOjQydg3QOkBLG9OYqWJ0dwlxF&si=UiPOXygq34SIvulj'
    show='C3 - Hells Bells'
elif [ "$1" = 'EXU' ]; then
    url='https://youtube.com/playlist?list=PL1tiwbzkOjQzSnYHVT8X4pyMIbSX3i4gz&si=VAptRwwPPt2OwB7m'
    show='Exandria Unlimited'
elif [ "$1" = 'EXUC' ]; then
    url='https://youtube.com/playlist?list=PL1tiwbzkOjQwzhdskYekmjr0h2tsbKaZw&si=a8MxLSI_q7Sr_DAD'
    show='Exandria Unlimited: Calamity'
elif [ "$1" = 'EXUD' ]; then
    url='https://www.youtube.com/playlist?list=PL1tiwbzkOjQw_Q6CICX-9Rmoj2-OOvgPF'
    show='Exandria Unlimited: Divergence'
elif [ "$1" = 'AU' ]; then
    url='https://www.youtube.com/playlist?list=PL1tiwbzkOjQyLAwOfoBe6HjYZMnQbXNaZ'
    show='Age of Umbra'
else
    url="$1"
    show="Unknown"
fi

prefix="${show} E%(autonumber-1+${4})03d "

# Invoke yt-dlp.
yt-dlp \
    --playlist-items "${2}:${3}" \
    --yes-playlist \
    --concurrent-fragments 6 \
    --output "${show} %(meta_title)s.%(ext)s" \
    --format "bv*+ba" \
    --write-subs \
    --sub-format 'srt' \
    --write-thumbnail \
    --embed-metadata \
    --replace-in-metadata 'title' ' \| .* \| .* Episode [0-9]*' '' \
    --parse-metadata "${show}:%(meta_show)s" \
    --parse-metadata "%(autonumber+${4})03d:%(meta_episode_id)s" \
    --parse-metadata "%(autonumber+${4})03d:%(meta_episode_sort)s" \
    --parse-metadata "E%(meta_episode_id)03d %(title)s:%(meta_title)s" \
    $url
