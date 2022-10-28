#!/bin/sh

set -eu pipefail

blocker () {
  grep -q "$1" /etc/blocklist.txt || echo "$1" >> /etc/blocklist.txt
}

echo "==> Updating environment..."
</proc/1/environ awk -v RS='\0' '{gsub("\047", "\047\\\047\047"); print "export \047" $0 "\047"}' > /etc/environment
echo "==> Sourcing environment..."
. /etc/environment
echo "==> Saving blocklist..."
echo "$BLOCKLISTS" | while read -r URL; do blocker "$URL"; done
echo "==> Updating sqlite3..."
cat /etc/blocklist.txt | xargs -I {} sudo sqlite3 /etc/pihole/gravity.db "INSERT OR IGNORE INTO adlist (Address) VALUES ('{}');"
echo "==> Updating gravity..."
pihole -g
echo "==> Success!"
