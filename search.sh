#!/bin/sh

AUTHORS="Foo-Manrot"
LAST_MODIF_DATE="2017-08-09"
VERSION="v1.0"

#####
# Searcher for the tools contained on 'tools.json'
#
# Requires:
#	jq
####


###
# Colours and formats to prettify the output
#
PRETTY_RESET=$(tput sgr0)

PRETTY_RED=$(tput setaf 9)
PRETTY_GREEN=$(tput setaf 10)
PRETTY_YELLOW=$(tput setaf 11)
PRETTY_BLUE=$(tput setaf 14)

PRETTY_BOLD=$(tput bold)
PRETTY_REVERSE=$(tput smso)
PRETTY_UNDERLINE=$(tput smul)

# ----

###
# Global variables
###
PKGS_FILE="./tools.json"

HELP_MSG="$AUTHORS
$LAST_MODIF_DATE
$VERSION
${PRETTY_RESET}
This script is made to search tools based on their categories.

Usage:

$0 [options] <filters>

Where 'options' may be one of the following:
	-f
	--file
		File in JSON format with the tools information.
	-h
	--help
		Show this message and exits.
	-v
	--verbose
		Increases verbosity level.
"

###
# Options
###
verbosity=0
filters=""

####
# Parses options
####
parse_args ()
{
	SHORT_OPTS=f:hv
	LONG_OPTS=file:,help,verbose

	# Checks that getopt can be used
	getopt --test > /dev/null
	if [ $? -ne 4 ]
	then
		log_error "$0: Error -> args can't be parsed, as 'getopt' can't be used."

		exit 1
	fi

	# Guarda el resultado para manejar correctamente los errores
	opts=$(getopt --options $SHORT_OPTS --longoptions $LONG_OPTS \
		 --name "$0" -- "$@") || exit 1

	eval set -- "$opts"

	# Loop to evaluate the available options
	while true
	do
		case "$1" in
			-f | --file)
				PKGS_FILE="$2"
				shift 2;;
			-h | --help)
				# Shows the help message and exits
				log_info "$HELP_MSG"
				exit 0;;
			-v | --verbose )
				verbosity=$((verbosity + 1))
				shift ;;
			--)
				# Ends the loop
				shift
				break;;
			*)
				log_error "$0: Unknown Error while parsing options - $1"
				exit 1;;
		esac
	done

	# Gets the positional arguments
	filters="$@"
}


###
# Functions to log, depending on the message level
#

log_info ()
{
	printf "${PRETTY_BLUE}$@${PRETTY_RESET}"
}

log_error ()
{
	printf "${PRETTY_RED}$@${PRETTY_RESET}"
}

log_success ()
{
	printf "${PRETTY_GREEN}$@${PRETTY_RESET}"
}

###
# Other custom functions
#
show_pkg_info ()
{
	key="$(echo "$1" | tr -d \")"

	# Returns if the key is an empty string
	[ -z "$key" ] && return 1

	categ="$(jq -c ".$key.categories" "$PKGS_FILE" | \
		tr -d "[]\"" | sed -e "s/,/ \/\/ /g")"

	descr="$(jq ".$key.description" "$PKGS_FILE" | \
		tr -d \")"

	pkg="$(jq ".$key.package" "$PKGS_FILE" | \
		tr -d \")"


	log_info "\n********************************\n"

	log_info "=> Tool name: '%s'" \
		"${PRETTY_BOLD}${PRETTY_RED}$key"


	if [ "$verbosity" -ge 1 ]
	then
		log_info "\n\t -> %sDescription: %s"	\
			${PRETTY_GREEN}			\
			"${PRETTY_BLUE}$descr"
	fi

	if [ "$verbosity" -ge 2 ]
	then
		log_info "\n\t -> %sCategories: %s"	\
			${PRETTY_GREEN}			\
			"${PRETTY_BLUE}$categ"
	fi

	if [ "$verbosity" -ge 3 ]
	then
		log_info "\n\t -> %sPackage name: %s"	\
			${PRETTY_GREEN}			\
			"${PRETTY_BLUE}$pkg"
	fi

	log_info "\n----------------\n"
	return 0
}


# _-_-_-_-_-_-_-_-_-_-_-_-_




parse_args "$@"

results=""
for f in $filters
do
	results="$results $(jq '. as $arr
		| to_entries
		| .[] as $idx
		| $idx.value.categories
		| if contains (["'"$f"'"])
		  then
			$idx.key
		  else
			null
		  end
		| select (. != null)' "$PKGS_FILE" \
		| tr -d "\n" \
		| sed -e 's/"\([^"]*\)"/ \1 /g'
	)"
done

# Shows the results
for res in $results
do
	show_pkg_info "$res"
done
