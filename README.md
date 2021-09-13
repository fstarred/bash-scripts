# bash-scripts
A collection of bash scripts for general purposes

## git-branch-polish

Automate git branches deletion

### Usage

`./git-branch-polish.sh <git-project>`

Prompt for delete local branches

`./git-branch-polish.sh -m remote <git-project>`

Prompt for delete remote branches

`./git-branch-polish.sh -m remote -d 2020-12-31 <git-project>`

Automatically delete remote branches created before or at 2020 December 31
