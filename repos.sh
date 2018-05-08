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

	for ref in $REFLIST; do
		notice "Changelog: ${ref}"
		git log "${ref}"  --pretty=format:"%C(bold blue)%h%x09%C(bold green)[%ad] %C(auto)%d%n%C(dim white)%an - %C(reset)%x20%s" --date=relative -n 10
	done
	if [ -f package.json ]; then
		npm install
		# npm outdated
		# eslint *.js
		# npm test
	fi
}

for repo in $REPOLIST; do

	title "$repo"
	if [ ! -d "$repo/.git" ]; then 
		notice "Cloning $repo ..."
		git clone $USERNAME@$GIT_HOST/$repo

		cd $repo
			repo_status 
		cd ..

	else
		cd "$repo"
		notice "Fetching $repo ..."
		git fetch --all --prune
		notice "Fetching $repo tags..."
		git fetch --all --tags --prune
	
		repo_status 
		cd ..
	fi
done
