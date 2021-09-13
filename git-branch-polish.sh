#!/usr/bin/env bash
#              ^^^^- NOT /bin/sh; also, do not run with "sh scriptname"
####################################################################
#                                                                  #
#   Script to automate removing of unused git branches		   #
#                                                                  #
#   VER 1.2                                                        #
#                                                                  #
#                                                                  #
####################################################################


set -e

help=false
mode=local
path=
threshold_date=
positional=()
program_name=$0
git_scan_branches_cmd=
git_remove_action_cmd="git branch -D"
git_remote_repo_alias_regex="^origin\/" #ex. '^origin\/'

prompt_delete()
{
	mode=$1
	line=$2
	branch_date=$(git merge-base $line develop | xargs git show -s --format=%ci)
	if [ -z "$threshold_date" ]
	then
		read -r -p "Do you want to delete $mode branch $line [$branch_date] <y/N>? " response
	else
		branch_norm_date=$(date -jf "%Y-%m-%d %H:%M:%S %z" "$branch_date" "+%Y%m%d")
		thresh_norm_date=$(date -jf "%Y-%m-%d" "$threshold_date" "+%Y%m%d")
		if [ $thresh_norm_date -ge $branch_norm_date ] 
		then
			echo "deleting $mode branch $line [$branch_date] because is equal or older than input date: $threshold_date"
			response="y" 
		else
			echo "skipping $mode branch $line [$branch_date] because is newer than input date: $threshold_date"
			response="n"
		fi
	fi
		
}

show_help()
{
	echo "usage: $program_name [project_directory] [--mode local]"
	echo ""
    echo "  -m,  --mode"
	echo "		<local|remote>work with local* or remote git branches"
	echo "  -d,  --date"
	echo "		<date fmt %Y-%m-%d> automatically delete branches before input date" 
    echo "  -h,  --help"
	echo "		display command help"
}

delete_branch()
{
	if [ $mode == 'local' ] 		
	then
		$git_remove_action_cmd $line
	else
		remote_line=`echo $line | sed -e "s/$git_remote_repo_alias_regex//g"`		
		$git_remove_action_cmd $remote_line
	fi
}

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -m|--mode)
    mode="$2"
    shift # past argument
    shift # past value
    ;;
	-d|--date)
	threshold_date="$2"
    shift # past argument
    shift # past value
    ;;
	-h|--help)
    help=true
    shift # past argument
    ;;
    *)    # unknown option
    positional+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done


if [[ $help = true ]]
then
	show_help
	exit 0
fi

############# PARSING GIT PROJECT PATH #############

set -- "${positional[@]}" # restore positional parameters

if [ "${#positional[@]}" -gt 1 ] # check number of arguments
then
	echo "Error: too many arguments!"
	show_help
	exit 1
elif [ -n "${positional[0]}" ]
then
	path="${positional[0]}"	
	if ! [ -d "$path" ] # check if directory exists
	then      
		echo "directory $path does not exist"
		exit 1
	fi	
	cd "$path"
fi


############# PARSING MODE #############

if ! { [ $mode == 'local' ] || [ $mode == 'remote' ]; }; then
	echo "wrong argument: $mode"
	echo "type --help for supported parameters"
	exit 1
else
	if [ $mode == 'local' ] 
	then
		git_scan_branches_cmd='git branch'
	else
		git_scan_branches_cmd='git branch -r'
		echo "****************************************"
		echo "Warning! running with remote branch mode !!!"				
		read -p "Are you sure (y/N)? " -n 1 -r
		echo    # (optional) move to a new line
		if [[ ! $REPLY =~ ^[Yy]$ ]] #$REPLY is automatically set if no variable name is supplied
		then			
			echo "coward but wise.. exiting right now"
			exit 1			
		else
			git_remove_action_cmd="git push origin --delete"		
		fi		
	fi
fi

echo ""
echo "scanning branches in project path: $(pwd)"
echo ""

############# FETCHING GIT BRANCHES #############

while read -r line <&3; do  
  #line=${line#remotes/origin/}  # trim remotes/origin/ w/o needing sed
  #echo $line | sed -e "s/^$git_remote_repo_alias_regex//g"
  case $line in
    *develop*|*master|*release/*|*hotfix*) continue ;;
    *) prompt_delete $mode $line
	case "$response" in
        [yY][eE][sS]|[yY])             
			delete_branch
            ;;
        *)
            echo "skipped"
            ;;
    esac
       
  esac
done 3< <($git_scan_branches_cmd)

echo ""
echo "DONE"
