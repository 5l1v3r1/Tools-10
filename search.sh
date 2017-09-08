#!/bin/sh

AUTHORS="Foo-Manroot"
LAST_MODIF_DATE="2017-08-09"
VERSION="v1.0"

#####
# Searcher for the tools contained on 'tools.json'
#
# Requires:
#	jq
####


###
# Global variables
###
PKGS_FILE="./tools.json"

HELP_MSG="$AUTHORS
$LAST_MODIF_DATE
$VERSION

This script is made to search tools based on their categories. Every new word on the
filter is inclusive.
That means that, when executing '$0 a b c', the results will be the union of the sets
(all tools with category 'a' PLUS all tools with category 'b' AND all tools with
category 'c'), not their intersection (all tools with category 'a', 'b' and 'c').

Usage:

$0 [options] <filters>

Where 'options' may be one of the following:
	-f
	--file
		 File in JSON format with the tools information.
		Defaults to '$PKGS_FILE'.
	-h
	--help
		Show this message and exits.
	-k
	--keys
		Outputs only the found keys, one per line
	-v
	--verbose
		Increases verbosity level.
"

###
# Colours and formats to prettify the output
#
PRETTY_RESET=$(tput sgr0)

PRETTY_RED=$(tput setaf 9)
PRETTY_GREEN=$(tput setaf 10)
PRETTY_YELLOW=$(tput setaf 11)
PRETTY_BLUE=$(tput setaf 14)

PRETTY_BOLD=$(tput bold)

# ----

###
# Options
###
verbosity=0
filters=""
keys_only=false

####
# Parses options
####
parse_args ()
{
	SHORT_OPTS=f:hkv
	LONG_OPTS=file:,help,keys,verbose

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
			-k | --keys)
				keys_only=true
				shift ;;
			-v | --verbose )
				verbosity=$((verbosity + 1))
				shift ;;
			--)
				# Ends the loop
				shift
				break;;
			*)
				log_error "Unknown Error while parsing options - $1"
				exit 1;;
		esac
	done

	# Gets the positional arguments
	filters=$*
}


###
# Functions to log, depending on the message level
#

log_info ()
{
	printf "%b" "$*${PRETTY_RESET}"
}

log_error ()
{
	printf "%b" "${PRETTY_RED}Error: $*${PRETTY_RESET}"
}

log_success ()
{
	printf "%b" "${PRETTY_GREEN}$*${PRETTY_RESET}"
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
		tr -d "[]\"" | sed -e "s/,/ \\/\\/ /g")"

	descr="$(jq ".$key.description" "$PKGS_FILE" | \
		tr -d \")"

	pkg="$(jq ".$key.package" "$PKGS_FILE" | \
		tr -d \")"


	log_info "\\n********************************\\n"

	log_info "=> Tool name: '${PRETTY_BOLD}${PRETTY_RED}$key'"


	if [ "$verbosity" -ge 1 ]
	then
		log_info "\\n\\t -> ${PRETTY_GREEN}Description: ${PRETTY_BLUE}$descr"
	fi

	if [ "$verbosity" -ge 2 ]
	then
		log_info "\\n\\t -> ${PRETTY_GREEN}Categories: ${PRETTY_BLUE}$categ"
	fi

	if [ "$verbosity" -ge 3 ]
	then
		log_info "\\n\\t -> ${PRETTY_GREEN}Package name: ${PRETTY_BLUE}$pkg"
	fi

	log_info "${PRETTY_RESET}\\n----------------\\n"
	return 0
}


# _-_-_-_-_-_-_-_-_-_-_-_-_


parse_args "$@"

results=""
for f in $filters
do
	results="$(jq '. as $arr
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
		| tr -d "\\n" \
		| sed -e 's/"\([^"]*\)"/ \1 /g'
	)"



	if ! "$keys_only"
	then
		test "$verbosity" -ge 1 && \
			log_info "\\n-> Showing packages under category: " \
				"'${PRETTY_YELLOW}$f${PRETTY_RESET}'\\n"
	fi

	# Shows the results
	for res in $results
	do
		if "$keys_only"
		then
			printf "%s\\n" "$res"
		else
			show_pkg_info "$res"
		fi
	done
done
