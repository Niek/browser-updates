#!/bin/bash

# Download latest Chrome releases info from APT repo
RELEASES=$(curl -s "http://dl.google.com/linux/chrome/deb/dists/stable/main/binary-amd64/Packages")

CHROME_STABLE=$(echo ${RELEASES} | grep -o "google-chrome-stable_.*" | cut -d_ -f2)
CHROME_UNSTABLE=$(echo ${RELEASES} | grep -o "google-chrome-unstable_.*" | cut -d_ -f2)
FIREFOX_STABLE=$(curl -s "https://download.mozilla.org/?product=firefox-latest" -I | grep -o "releases/.*" | cut -d/ -f2)
FIREFOX_UNSTABLE=$(curl -s "https://download.mozilla.org/?product=firefox-beta-latest" -I | grep -o "releases/.*" | cut -d/ -f2)

NOW=$(date +%F)

echo "Latest releases as of ${NOW}:"
echo "Chrome stable: ${CHROME_STABLE}, unstable: ${CHROME_UNSTABLE}"
echo "Firefox stable: ${FIREFOX_STABLE}, unstable: ${FIREFOX_UNSTABLE}"

# Update browser versions in JSON
for browser in chrome firefox; do
  for rel in stable unstable; do
    VAR=$(echo ${browser}_${rel} | tr '[:lower:]' '[:upper:]')
    if [[ -z $(jq '.'${browser}'.'${rel}'[] | select (.version=="'${!VAR%%-*}'")' browsers.json) ]]; then
      jq '.'${browser}'.'${rel}' += [{"version": "'${!VAR%%-*}'", "filename": "'${!VAR}'", "updated": "'${NOW}'"}]' browsers.json > browsers.tmp
      mv browsers.tmp browsers.json
      echo "Updated stable ${browser} version to ${!VAR%%-*}"
    fi
  done
done