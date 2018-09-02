#! /bin/bash

function title(){
  echo -e "\033[32m============================================================"
  echo -e "$*"
  echo -e "============================================================\033[0m"
}
function notice(){
  echo -e "\033[35m$*\033[0m"
}
# Warn will echo the first argument to stderr
function warn() {
    echo -e "\033[31m$1\033[0m" >&2
}

# Die will warn the first argument and then exit
function die() {
    warn "$1"
    exit 1
}

function commit_delta(){

  local BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
  if [[ -n $BRANCH ]]; then
  
    # Colours: Define Colours and platform specific escape codes
    local ESC_CODE="\e"
    [[ $OSTYPE == darwin* ]] && ESC_CODE="\033"

    local RED="$ESC_CODE[31m"
    local GREEN="$ESC_CODE[32m"
    local YELLOW="$ESC_CODE[33m"
    local BLUE="$ESC_CODE[34m"
    local PURPLE="$ESC_CODE[36m"
    local NORM="$ESC_CODE[0m"

    local REMOTE_STATUS=""
    for r in `git remote 2> /dev/null`; do
      local UP=`git cherry $r/$BRANCH $BRANCH 2> /dev/null | wc -l | tr -d '[:space:]'`
      local DOWN=`git cherry $BRANCH $r/$BRANCH 2> /dev/null | wc -l | tr -d '[:space:]'`
      # if [ $UP -gt  0 ] || [ $DOWN -gt 0 ];then
        REMOTE_STATUS="$REMOTE_STATUS ${PURPLE}${r}|${BLUE}↑${UP}${PURPLE}/${GREEN}↓${DOWN}$PURPLE|$NORM"
      # fi
    done
    echo -e "$REMOTE_STATUS"
  fi
}

# Default list file
REPO_LIST_FILE="repo.list"
# If exists, load contents and check that it is non empty
[[ -f $REPO_LIST_FILE ]] && REPOLIST=`cat $REPO_LIST_FILE`
[[ -z $REPOLIST ]] &&  die "ERROR: Must have a non empty '$REPO_LIST_FILE' file to use this script"

USERNAME=
GIT_HOST=
# LOAD THESE CREDENTIALS EXTERNALLY
source .env
[[ -z $USERNAME ]] &&  die "ERROR: Must export USERNAME in .env to use this script"
[[ -z $GIT_HOST ]] &&  die "ERROR: Must export GIT_HOST in .env to use this script"


function repo_status() {
	REFLIST="
	master..origin/master
	"

  notice "Push/Pull:"
  commit_delta

	for ref in $REFLIST; do
		notice "Changelog: ${ref}"
		git log "${ref}"  --pretty=format:"%C(bold blue)%h%x09%C(bold green)[%ad] %C(auto)%d%n%C(dim white)%an - %C(reset)%x20%s" --date=relative -n 10
	done

	# if [ -f package.json ]; then
		# npm install
		# npm outdated
		# eslint *.js
		# npm test
	# fi
}

for repo in $REPOLIST; do

	title "$repo"
	if [ ! -d "$repo/.git" ]; then 
		notice "Cloning $repo ..."
		git clone $GIT_HOST/$repo

		cd $repo
			repo_status 
		cd ..

	else
		cd "$repo"
		# notice "Fetching $repo ..."
		git fetch --all --prune --quiet
		# notice "Fetching $repo tags..."
		git fetch --all --tags --prune --quiet
	
		repo_status 
		cd ..
	fi
done
