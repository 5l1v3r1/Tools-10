#!/bin/sh

# If Ruby's package manager isn't installed, just show an error message
if ! command -v gem >/dev/null
then
	printf " --> Error: 'gem' (Ruby's package manager) needs to be installed <-- \n"
	return 1
else
	sudo gem uninstall zsteg
	return $?
fi
