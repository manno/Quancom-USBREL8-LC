#!/bin/sh
while true; do 
	./shotgun config.ru -o localhost -p 4567 
	echo "pausing 10 seconds"
	sleep 10
done
