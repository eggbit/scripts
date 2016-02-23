#!/bin/bash

# twitch-dl: A script to download a user's recent broadcasts.
# Dependencies: livestreamer, jq, wget
# Usage: twitch-dl <user> <path>

# Make sure there are two arguments passed
if [[ "$#" -ne 2 ]]; then
    echo "Not enough arguments." # TODO: Show usage.
    exit 1;
fi

# Make sure second argument is a valid path.
if [[ ! -d "$2" ]]; then
    echo "Not a directory." # TODO: Show usage.
    exit 1;
fi

# Fetch Twitch data.
url="http://api.twitch.tv/kraken/channels/$1/videos?limit=8&offset=0&broadcasts=true&on_site=1"
json=$(wget -qO- $url)

# Extract information.
IFS=$'\n'
urls=($(echo $json | jq -r '.videos[].url'))
games=($(echo $json | jq -r '.videos[].game'))
titles=($(echo $json | jq -r '.videos[].title'))
dates=($(echo $json | jq -r '.videos[].recorded_at' | tr : _))
unset IFS

# Go through each URL and do the dew.
for (( i = 0; i < ${#urls[*]}; i++ )); do
    filepath="$2/${games[i]}-${dates[i]}.mp4"

    if [[ -f "$filepath" ]]; then
        echo "Skipping $filepath"
        continue
    fi

    # touch "$filepath"
    livestreamer -o "$filepath" --hls-segment-threads 4 "${urls[i]}" source
done
