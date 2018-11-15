#!/bin/bash

if [ -z "$REMWSGWYD_OPTIONS" ]
then
  REMWSGWYD_OPTIONS='-l 7 -u -t'
fi

/sbin/remwsgwyd $REMWSGWYD_OPTIONS > /dev/null 2>&1 &

terminate=0

while [ true ]; do

	# Verify remwsgwyd is running
	remwsgwydnum=`ps aux | grep remwsgwyd | grep -v grep | wc -l`

        if [ $remwsgwydnum = 0 ]; then
                echo "No remwsgwyd process alive. Terminate container."
                terminate=1
        fi

        if [ $terminate != 0 ]; then
                break
        else
                sleep 60
        fi
done

