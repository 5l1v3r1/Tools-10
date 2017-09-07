#!/bin/sh

FILENAME="rpatool"

URL="https://raw.githubusercontent.com/Shizmob/rpatool/master/$FILENAME"
DESTINATION="/usr/local/bin/$FILENAME"


code="$(sudo curl -# -w "%{http_code}" "$URL" -L -o "$DESTINATION")"

# Checks curl's return code and the servers' answer
if [ $? -eq 0 ] && [ "$code" = "200" ]
then
	sudo chmod +x "$DESTINATION"
	return 0
else
	return "$code"
fi
