# Git Herder

Bash tooling to assist keeping large collections of Git repositories up to date.

# Configuration

You will need to populate two files which are explicitly NOT version controlled:

 - `.env`
 - `repo.list`

The script will complain anyhow if they do not exist or do not export the right
information required. See below for full details of what is required.

## Credentials

You will need to create a `.env` file with the following values exported:

```bash
USERNAME="neozenith"
GITHOST="github.com/$USERNAME"
```

## Repo List

You will also need to create a file `repo.list` which is a line delimited file
listing the names of the repositories you wish to keep in sync. eg

```
vim-dotfiles
arduino-bonsai
data-vis-101
```

These will wind up as parameters that fulfill the following command:

```bash
git clone $USERNAME@$GITHOST/$REPO
```

# Usage

Place in the root of where you want to manage your repos. 

A good place is `~/projects`. 

```bash
git clone https://github.com/neozenith/git-herder.git ~/projects
cd ~/projects
# Add execute property first time only if necessary.
chmod +x repos.sh
./repos.sh
```

I personally split up personal and work repos as they need different host parameters.

```bash
git clone https://github.com/neozenith/git-herder.git ~/projects/josh
git clone https://github.com/neozenith/git-herder.git ~/projects/work
```
