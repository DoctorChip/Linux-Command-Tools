#!/usr/bin/env sh

#
# Finds a log folder (either log or logs) and then tail -f on the most recently modified log file.
#

if [ -d "log" ]; then
  logDir="log"
fi

if [ -d "logs" ]; then
  logDir="logs"
fi

echo "Found ${logDir} folder..." &&
cd $logDir && pwd &&
echo ">>> Latest modified log:" &&
file=$(find . -type f -printf '%p' | sort -r | sed -n 1p) &&
tail -f $file
