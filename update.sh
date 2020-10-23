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

# Update stable versions in JSON
[[ -z $(jq '.chrome.stable[] | select (.version=="'$CHROME_STABLE'")' browsers.json) ]] \
  && echo "Stable Chrome version not found yet in JSON" \
  && jq '.chrome.stable += [{"version": "'$CHROME_STABLE'", "updated": "'$NOW'"}]' browsers.json > browsers.tmp \
  && mv browsers.tmp browsers.json \
  && echo "Updated stable Chrome version to ${CHROME_STABLE}"
[[ -z $(jq '.firefox.stable[] | select (.version=="'$FIREFOX_STABLE'")' browsers.json) ]] \
  && echo "Stable Firefox version not found yet in JSON" \
  && jq '.firefox.stable += [{"version": "'$FIREFOX_STABLE'", "updated": "'$NOW'"}]' browsers.json > browsers.tmp \
  && mv browsers.tmp browsers.json \
  && echo "Updated stable Firefox version to ${FIREFOX_STABLE}"

# Update unstable versions in JSON
[[ -z $(jq '.chrome.unstable[] | select (.version=="'$CHROME_UNSTABLE'")' browsers.json) ]] \
  && echo "Unstable Chrome version not found yet in JSON" \
  && jq '.chrome.unstable += [{"version": "'$CHROME_UNSTABLE'", "updated": "'$NOW'"}]' browsers.json > browsers.tmp \
  && mv browsers.tmp browsers.json \
  && echo "Updated unstable Chrome version to ${CHROME_UNSTABLE}"
[[ -z $(jq '.firefox.unstable[] | select (.version=="'$FIREFOX_UNSTABLE'")' browsers.json) ]] \
  && echo "Unstable Firefox version not found yet in JSON" \
  && jq '.firefox.unstable += [{"version": "'$FIREFOX_UNSTABLE'", "updated": "'$NOW'"}]' browsers.json > browsers.tmp \
  && mv browsers.tmp browsers.json \
  && echo "Updated unstable Firefox version to ${FIREFOX_UNSTABLE}"