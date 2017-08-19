#!/bin/sh

AUTHORS="Foo-Manroot"
LAST_MODIF_DATE="2017-08-09"
VERSION="v1.0"

#####
# Installer for the tools contained on 'tools.json'
#
# Requires:
#	jq
####


###
# Global variables
###
PKGS_FILE="./tools.json"
INSTALLERS_DIR="./aux_installers"
UNINSTALLERS_DIR="./aux_uninstallers"

HELP_MSG="$AUTHORS
$LAST_MODIF_DATE
$VERSION
${PRETTY_RESET}
This script is made to help to install the tools present on the file.

Usage:

$0 [options]

Where 'options' may be one of the following:
	-d
	--dir
		 Directory to search for custom installers.
		Defaults to '$INSTALLERS_DIR'.
	-f
	--file
		 File in JSON format with the tools information.
		Defaults to '$PKGS_FILE'.
	-h
	--help
		Show this message and exits.
	-u
	--uninstall
		Uninstalls the packages, instead of installing them.
"

UNINSTALL=false

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

####
# Parses options
####
parse_args ()
{
	SHORT_OPTS=d:f:hu
	LONG_OPTS=dir:,file:,help,uninstall

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
			-d | --dir )
				if [ -d "$2" ]
				then
					INSTALLERS_DIR="$2"
					log_info "Using '$2' as custom installers dir\n"
					shift 2
				else
					log_error "'$2' is not a directory\n"
					exit 1
				fi
				;;
			-f | --file)
				if [ -f "$2" ]
				then
					PKGS_FILE="$2"
					log_info "Using '$2' as custom JSON file\n"
					shift 2
				else
					log_error "'$2' is not a file\n"
					exit 1
				fi
				;;
			-h | --help)
				# Shows the help message and exits
				log_info "$HELP_MSG"
				exit 0
				;;
			-u | --uninstall)
				UNINSTALL=true
				shift
				;;
			--)
				# Ends the loop
				shift
				break;;
			*)
				log_error "Unknown Error while parsing options - '$1'\n"
				exit 1;;
		esac
	done
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
	printf "${PRETTY_RED}$0 Error: $@${PRETTY_RESET}"
}

log_success ()
{
	printf "${PRETTY_GREEN}$@${PRETTY_RESET}"
}

# ------------------------------

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

	log_info "=> Info of tool '%s'" \
		"${PRETTY_BOLD}${PRETTY_RED}$key"

	log_info "\n\t -> %sCategories: %s"	\
		${PRETTY_GREEN}			\
		"${PRETTY_BLUE}$categ"

	log_info "\n\t -> %sDescription: %s"	\
		${PRETTY_GREEN}			\
		"${PRETTY_BLUE}$descr"

	log_info "\n\t -> %sPackage name: %s"	\
		${PRETTY_GREEN}			\
		"${PRETTY_BLUE}$pkg"

	log_info "\n----------------\n"
	return 0
}


uninstall ()
{
	tool="$(echo "$1" | tr -d \")"
	pkg="$(jq -c ".$tool.package" "$PKGS_FILE" | tr -d \")"

	log_info "\n\n$PRETTY_BOLD +++++++++++++++++++++++++ \n"

	# Checks if the tool is already available
	command -v "$tool" > /dev/null 2>&1
	if [ $? -ne 0 ]
	then
		log_success " %sTool not installed: %s" \
				$PRETTY_UNDERLINE	\
				${PRETTY_YELLOW}"$tool"${PRETTY_GREEN}
		log_info "\n$PRETTY_BOLD +++++++++++++++++++++++++ \n"

		return
	fi


	# Tools that can't be located using aptitude will use an URL
	res="$(expr "$pkg" : "[a-zA-Z]://")"
	apt="$(apt-cache policy "$pkg" | grep -Pi "installed: .*" | grep -Piv "(none)")"

	# Only uninstalls it if there is an available package
	if [ -z "$pkg" ]
	then
		log_error " No available package for %s"	\
			  "'${PRETTY_YELLOW}$pkg${PRETTY_RED}'"

	# Uses the custom uninstallers when needed
	elif [ $res -ne 0 ] \
		|| [ -z "$apt" ]
	then
		log_info "The tool can't be uninstalled with aptitude: %s\n" \
			"${PRETTY_YELLOW}$tool${PRETTY_BLUE}"

		# Searches a script to install it under INSTALLERS_DIR
		if [ "$(find "$UNINSTALLERS_DIR" -name "$pkg" | wc -l)" -eq 1 ]
		then
			file="$(find "$UNINSTALLERS_DIR" -name "$pkg")"

			log_info "Using uninstaller %s\n" \
				"${PRETTY_YELLOW}$file"

			sh "$file"
			if [ $? -ne 0 ]
			then
				log_error "\n ==> The package couldn't be removed: %s"\
					 "${PRETTY_UNDERLINE}$pkg"

			else
				log_success "\n ==> Package uninstalled: %s" \
					 "${PRETTY_YELLOW}$pkg"
			fi
		else
			log_error "\n ==> No available method to uninstall package %s" \
					 "${PRETTY_UNDERLINE}$pkg"
		fi
	# Uses aptitude
	else
		log_info " --> Uninstalling package %s\n"	\
			"'${PRETTY_YELLOW}$pkg${PRETTY_BLUE}'..."

		sudo apt-get remove --yes --show-progress "$pkg" # --simulate
		if [ $? -ne 0 ]
		then
			log_error "\n ==> The package couldn't be uninstalled: %s"\
				 "${PRETTY_UNDERLINE}$pkg"

		else
			log_success "\n ==> Package uninstalled: %s" \
				 "${PRETTY_YELLOW}$pkg"
		fi
	fi

	log_info "\n$PRETTY_BOLD +++++++++++++++++++++++++ \n"
}


install ()
{
	tool="$(echo "$1" | tr -d \")"
	pkg="$(jq -c ".$tool.package" "$PKGS_FILE" | tr -d \")"

	log_info "\n\n$PRETTY_BOLD +++++++++++++++++++++++++ \n"

	# Checks if the tool is already available
	command -v "$tool" > /dev/null 2>&1
	if [ $? -eq 0 ]
	then
		log_success " %sTool already installed: %s" \
				$PRETTY_UNDERLINE	\
				${PRETTY_YELLOW}"$tool"${PRETTY_GREEN}
		log_info "\n$PRETTY_BOLD +++++++++++++++++++++++++ \n"

		return
	fi


	# Tools that can't be located using aptitude will use an URL
	res="$(expr "$pkg" : "[a-zA-Z]://")"
	apt="$(apt-cache policy "$pkg" | grep -Pi "installed: .*" | grep -Pio "(none)")"

	# Only installs it if there is an available package
	if [ -z "$pkg" ]
	then
		log_error " No available package for %s"	\
			"'${PRETTY_YELLOW}$pkg${PRETTY_RED}'"

	# Uses the custom installers when needed
	elif [ $res -ne 0 ] \
		|| [ -z "$apt" ]
	then
		log_info "The tool can't be installed with aptitude: %s\n" \
			"${PRETTY_YELLOW}$tool${PRETTY_BLUE}"

		# Searches a script to install it under INSTALLERS_DIR
		if [ "$(find "$INSTALLERS_DIR" -name "$pkg" | wc -l)" -eq 1 ]
		then
			file="$(find "$INSTALLERS_DIR" -name "$pkg")"

			log_info "Using installer %s\n" \
				"${PRETTY_YELLOW}$file"

			sh "$file"
			if [ $? -ne 0 ]
			then
				log_error "\n ==> The package couldn't be installed: %s"\
					 "${PRETTY_UNDERLINE}$pkg"

			else
				log_success "\n ==> Package installed: %s" \
					 "${PRETTY_YELLOW}$pkg"
			fi
		else
			log_error "\n ==> No available method to install package %s" \
					 "${PRETTY_UNDERLINE}$pkg"
		fi
	# Uses aptitude
	else
		log_info " --> Installing package %s\n"	\
			"'${PRETTY_YELLOW}$pkg${PRETTY_BLUE}'..."

		sudo apt-get install --yes --show-progress "$pkg" #--simulate
		if [ $? -ne 0 ]
		then
			log_error "\n ==> The package couldn't be installed: %s"\
				 "${PRETTY_UNDERLINE}$pkg"

		else
			log_success "\n ==> Package installed: %s" \
				 "${PRETTY_YELLOW}$pkg"
		fi
	fi

	log_info "\n$PRETTY_BOLD +++++++++++++++++++++++++ \n"
}



# _-_-_-_-_-_-_-_-_-_-_-_-_

parse_args "$@"
errors=0

##
# Checks requirements
##
log_info "\n --> Checking requirements...\n"

for req in	\
	jq
do
	command -v "$req" > /dev/null 2>&1
	if [ $? -ne 0 ]
	then
		log_error	\
			"Error: %sThe tool %s%s%s is needed to run this script %s\n"	\
			${PRETTY_YELLOW}			\
			${PRETTY_BLUE}${PRETTY_UNDERLINE}	\
			"$req"					\
			${PRETTY_RESET}${PRETTY_YELLOW}		\
			${PRETTY_RESET}

		errors=$((errors + 1))
	fi
done

if [ $errors -ne 0 ]
then
	exit $errors
fi

log_success "All requirements available \n\n"

# --------


###
# Parses the file with the packages
##
items="$(jq ". | length" "$PKGS_FILE")"

log_info "There are %s%i items%s in '%s'\n"	\
	${PRETTY_YELLOW}	\
	"$items"		\
	${PRETTY_BLUE}		\
	"$PKGS_FILE"

# Gets the keys on a string, using ' ' as a delimiter between values
keys=$(jq "keys" "$PKGS_FILE" -M -S -c | tr -d "[]" | sed -e "s/,/ /g")

all=false
quit=false

if ! $UNINSTALL
then
	msg="Do you wish to install this program? [Yy]es [Nn]o [Aa]ll [Qq]uit -> "
else
	msg="Do you wish to uninstall this program? [Yy]es [Nn]o [Aa]ll [Qq]uit -> "
fi

for k in $keys
do
	show_pkg_info "$k"
	[ $? -ne 0 ] && continue

	if ! $all
	then
		while true; do
			read -p "$msg" answer
			case $answer in
				[Yy]* )
					if ! $UNINSTALL
					then
						install "$k"
					else
						uninstall "$k"
					fi
					break
					;;
				[Nn]* ) break;;
				[Aa]* )
					if ! $UNINSTALL
					then
						install "$k"
					else
						uninstall "$k"
					fi

					all=true

					break
					;;
				[Qq]* ) quit=true; break;;
				* ) echo "Please answer one of the accepted answers.";;
			esac
		done
	else
		if ! $UNINSTALL
		then
			install "$k"
		else
			uninstall "$k"
		fi
	fi

	$quit && break;
done

