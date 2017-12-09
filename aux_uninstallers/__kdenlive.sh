#!/bin/sh

PPA="ppa:kdenlive/kdenlive-stable"


sudo apt-get remove kdenlive
ret_code="$?"

printf "---- Package removed ----\n"
printf "=> Removing PPA: %s\n" "$PPA"

# Optionally, removes the PPA
if sudo add-apt-repository --remove "$PPA"
then
	printf "PPA left untouched\n"
else
	printf "PPA removed\n"
fi


return "$ret_code"
