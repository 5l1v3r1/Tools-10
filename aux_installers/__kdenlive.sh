#!/bin/sh

PPA="ppa:kdenlive/kdenlive-stable"
PKG="kdenlive"

# Checks if the PPA has already been added
if ! grep -q "^deb .*$PKG" /etc/apt/sources.list /etc/apt/sources.list.d/*
then
	# Adds kdenlive's PPA, and then updates and installs
	if sudo add-apt-repository "$PPA"
	then
		sudo apt-get update
		sudo apt-get install "$PKG"
		return $?
	else
		return 1
	fi
else
	sudo apt-get install "$PKG"
	return $?
fi
