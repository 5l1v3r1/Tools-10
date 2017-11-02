#!/bin/sh

# https://eartoearoak.com/software/rtlsdr-scanner/rtlsdr-scanner-installation
DEST_BIN="/usr/local/bin/rtlsdr_scanner"


# Requirements
sudo apt-get install python python-wxgtk3.0 rtl-sdr

# Installation
sudo -H pip install -U rtlsdr_scanner
res="$?"

# Adds a little script to run the
code="#!/bin/sh
python -m rtlsdr_scanner
"

printf "Creating file '%s' with the following code: " "$DEST_BIN"
printf "%s\n" "$code" | sudo tee "$DEST_BIN"

if [ "$?" -eq 0 ]
then
	printf "Done"
else
	printf " --> Error creating file '%s' <-- " "$DEST_BIN"
	return "1"
fi

return "$res"
