#!/bin/sh

progname="$(basename $0)"

help="usage: ${progname} <campaign> <from> <to>

options:
    campaign      The campaign to download from.
    from          The playlist item number of the first video.
    to            The playlist item number of the last video.

possible campaign values:
    VM            Campaign 1 – Vox Machina
    MN            Campaign 2 – The Mighty Nein
    HB            Campaign 3 – Hells Bells
    EXU           Exandria Unlimited
    EXUC          Exandria Unlimited: Calamity
    EXUD          Exandria Unlimited: Divergence
    AU            Age of Umbra
    url           if none of the above, interpret as URL"

# Check argument count and set volume filter if requested.
if [ $# -ne 3 ]; then
    printf '%s\n' "$help"
    exit 1
fi

# Select correct URL.
if [ "$1" = 'VM' ]; then
    url='https://youtube.com/playlist?list=PL1tiwbzkOjQz7D0l_eLJGAISVtcL7oRu_&si=_aR48fnGiVEruCYc'
    season_nr='1'
elif [ "$1" = 'MN' ]; then
    url='https://youtube.com/playlist?list=PL1tiwbzkOjQxD0jjAE7PsWoaCrs0EkBH2&si=CxL0i_3ZTPQJ0YQ5'
    season_nr='2'
elif [ "$1" = 'HB' ]; then
    url='https://youtube.com/playlist?list=PL1tiwbzkOjQydg3QOkBLG9OYqWJ0dwlxF&si=UiPOXygq34SIvulj'
    season_nr='3'
elif [ "$1" = 'EXU' ]; then
    url='https://youtube.com/playlist?list=PL1tiwbzkOjQzSnYHVT8X4pyMIbSX3i4gz&si=VAptRwwPPt2OwB7m'
    season_nr='51'
elif [ "$1" = 'EXUC' ]; then
    url='https://youtube.com/playlist?list=PL1tiwbzkOjQwzhdskYekmjr0h2tsbKaZw&si=a8MxLSI_q7Sr_DAD'
    season_nr='52'
elif [ "$1" = 'EXUD' ]; then
    url='https://www.youtube.com/playlist?list=PL1tiwbzkOjQw_Q6CICX-9Rmoj2-OOvgPF'
    season_nr='53'
elif [ "$1" = 'AU' ]; then
    url='https://www.youtube.com/playlist?list=PL1tiwbzkOjQyLAwOfoBe6HjYZMnQbXNaZ'
    season_nr='54'
else
    url="$1"
    season_nr="NA"
fi

# Invoke yt-dlp.
yt-dlp \
    --playlist-items "${2}:${3}" \
    --yes-playlist \
    --concurrent-fragments 6 \
    --format 'bv*+ba' \
    --write-subs \
    --sub-format 'srt' \
    --write-thumbnail \
    --embed-metadata \
    --parse-metadata 'Critical Role:%(meta_show)s' \
    --parse-metadata '%(title)s:(?P<title>.+) \|.*\|.*Episode (?P<episode_id>\d+).*' \
    --parse-metadata "${season_nr}:%(season_number)s" \
    --output 'Critical Role S%(season_number)02dE%(episode_id)03d %(title)s.%(ext)s' \
    $url
