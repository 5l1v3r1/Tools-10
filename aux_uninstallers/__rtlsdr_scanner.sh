#!/bin/sh

# https://eartoearoak.com/software/rtlsdr-scanner/rtlsdr-scanner-installation
DEST_BIN="/usr/local/bin/rtlsdr_scanner"

sudo -H pip uninstall rtlsdr_scanner
res="$?"

# Removes the binary
if [ -f "$DEST_BIN" ]
then
	sudo rm -v "$DEST_BIN"
fi

return "$res"
