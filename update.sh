#!/usr/bin/env bash

set -e # Exit on failure

# Download latest Chrome and Edge releases info from APT repo
CHROME_RELEASES=$(curl -sfSL "http://dl.google.com/linux/chrome/deb/dists/stable/main/binary-amd64/Packages")
EDGE_RELEASES=$(curl -sfSL "https://packages.microsoft.com/repos/edge/dists/stable/main/binary-amd64/Packages")

CHROME_STABLE=$(echo ${CHROME_RELEASES} | grep -o "google-chrome-stable_.*" | cut -d_ -f2)
CHROME_UNSTABLE=$(echo ${CHROME_RELEASES} | grep -o "google-chrome-unstable_.*" | cut -d_ -f2)
EDGE_STABLE=$(echo ${EDGE_RELEASES} | grep -o "microsoft-edge-stable_.*" | cut -d_ -f2)
EDGE_UNSTABLE=$(echo ${EDGE_RELEASES} | grep -o "microsoft-edge-dev_.*" | cut -d_ -f2)
FIREFOX_STABLE=$(curl -s "https://download.mozilla.org/?product=firefox-latest" -I | grep -o "releases/.*" | cut -d/ -f2)
FIREFOX_UNSTABLE=$(curl -s "https://download.mozilla.org/?product=firefox-beta-latest" -I | grep -o "releases/.*" | cut -d/ -f2)

NOW=$(date +%F)

echo "Latest releases as of ${NOW}:"
echo "Chrome stable: ${CHROME_STABLE}, unstable: ${CHROME_UNSTABLE}"
echo "Edge stable: ${EDGE_STABLE}, unstable: ${EDGE_UNSTABLE}"
echo "Firefox stable: ${FIREFOX_STABLE}, unstable: ${FIREFOX_UNSTABLE}"

# Update browser versions in JSON
for browser in chrome edge firefox; do
  for rel in stable unstable; do
    VAR=$(echo ${browser}_${rel} | tr '[:lower:]' '[:upper:]')

    # Skip if variable is not set
    [ -z ${!VAR} ] && continue

    # Check if entry does not exist yet
    if [[ -z $(jq '.'${browser}'.'${rel}'[] | select (.version=="'${!VAR%%-*}'")' browsers.json) ]]; then
      # Build JSON entry to add
      JSON='[{"version": "'${!VAR%%-*}'", '
      if [[ ${browser} == "chrome" ]]; then
        JSON+='"filename": "'${!VAR}'", ';
      fi
      JSON+='"updated": "'${NOW}'"}]'

      # Add to JSON
      jq ".${browser}.${rel} += ${JSON}" browsers.json > browsers.tmp
      mv browsers.tmp browsers.json
      echo "Updated stable ${browser} version to ${!VAR%%-*}"
    fi
  done
done

if [ ! -s browsers.json ]; then
  exit 1
fi
