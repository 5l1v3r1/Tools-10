#!/bin/sh

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




install ()
{
	tool="$(echo "$1" | tr -d \")"
	pkg="$(jq -c ".$tool.package" "$PKGS_FILE" | tr -d \")"

	log_info "\n\n$PRETTY_BOLD +++++++++++++++++++++++++ \n"

	# Checks if the tool is already available
	which "$tool" > /dev/null
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
		if [ "$(find "$INSTALLERS_DIR" -name "$pkg.sh" | wc -l)" -eq 1 ]
		then
			file="$(find "$INSTALLERS_DIR" -name "$pkg.sh")"

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

errors=0

##
# Checks requirements
##
log_info "\n --> Checking requirements...\n"

for req in	\
	jq
do
	which "$req" > /dev/null

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
keys=$(jq "keys" tools.json -M -S -c | tr -d "[]" | sed -e "s/,/ /g")

all=0
quit=0
msg="Do you wish to install this program? [Yy]es [Nn]o [Aa]ll [Qq]uit -> "

for k in $keys
do
	show_pkg_info "$k"
	[ $? -ne 0 ] && continue

	if [ $all -ne 1 ]
	then
		while true; do
			read -p "$msg" answer
			case $answer in
				[Yy]* ) install "$k"; break;;
				[Nn]* ) break;;
				[Aa]* ) install "$k"; all=1; break;;
				[Qq]* ) quit=1; break;;
				* ) echo "Please answer one of the accepted answers.";;
			esac
		done
	else
		install "$k"
	fi

	[ $quit -eq 1 ] && break;
done

