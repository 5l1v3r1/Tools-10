#!/bin/sh

PPA="ppa:kdenlive/kdenlive-stable"

# Adds kdenlive's PPA, and then updates and installs
if sudo add-apt-repository "$PPA"
then
	sudo apt-get update
	sudo apt-get install kdenlive
	return "$?"
else
	return 1
fi
