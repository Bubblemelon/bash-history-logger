# Using script to log terminal output

set -euf -o pipefail

# get the directory where it was called
# so that it can return to that same directory
CURDIR=$(pwd)

# e.g. Jul_18
FOLDER_NAME=`date '+%b_%Y'`
# e.g. Jul-24-18
TODAY=`date '+%b-%d-%y'`

LOG_NAME="$TODAY.log"

DIR=/home/cherylfong/.bash_output_history/
temp_dir=temp

# default 0
CASE_NUM=0

# If FOLDER_NAME doesn't exist as a file, then create a directory wtith that name
if [[ ! -e "$DIR$FOLDER_NAME" ]] 
then
	echo "[INFO] '$FOLDER_NAME' does not exist in '$DIR'"
	echo "[INFO] mkdir -p -v '$DIR$FOLDER_NAME'"
	mkdir -p -v $DIR$FOLDER_NAME
	echo "[INFO] '$LOG_NAME' will be stored in '$FOLDER_NAME'"
	CASE_NUM=0
elif [[ ! -d "$DIR$FOLDER_NAME" ]] 
then
	echo "[WARN] $FOLDER_NAME exists but is not a directory"

	while [[ $ans == '' ]]
	do
		read -r -p "[Q] Store '$LOG_NAME' in '$DIR$temp_dir' ? [y/N] " ans
	done

	if [[ "$ans" =~ ^([yY][eE][sS])|[yY]+$ ]]
	then
		echo "mkdir -p -v $DIR$temp_dir"
		mkdir -p -v "$DIR$temp_dir"
		echo "[INFO] '$LOG_NAME' will be stored in '$DIR$temp_dir'"
		CASE_NUM=1
	else
		while [[ $userdir == '' ]]
		do
			read -r -p "[Q] Name the directory to save '$LOG_NAME' in '$DIR' ? " userdir
		done
		echo "mkdir -p -v $DIR$userdir"
		mkdir -p -v $DIR$userdir
		echo "[INFO] '$LOG_NAME' will be stored in '$userdir'"
		CASE_NUM=2
	fi
fi

# creates a symlink to the latest log in the parent directory i.e.
# .bash_ouput_history
latest_log_link() {

	# subshell command
	# https://stackoverflow.com/questions/10566532/how-can-bash-execute-a-command-in-a-different-directory-context
	(cd $DIR; ln -sf $1 latest.log)
}

# checks if $LOG_NAME exists in each directory case
log_existance() {
	
	exit_code="$(cd $1; echo $?)"
	
	if [[ "$exit_code" == 1 ]]
	then
		echo "[ERROR] cd $1 failed ! aborting"
		exit
	fi

	cd $1
	if [[ ! -e $LOG_NAME ]]
	then	
		echo "[INFO] Writing to empty $LOG_NAME"
		date +%X
		cd $CURDIR
		script $1/$LOG_NAME
	else
		echo "[INFO] Appending to $LOG_NAME"
		date +%X
		cd $CURDIR
		script -a $1/$LOG_NAME	
	fi

	$(latest_log_link $1/$LOG_NAME ) 
}

# start script ass $LOG_NAME in the specifed directory location
case $CASE_NUM in
	0)
		log_existance "$DIR$FOLDER_NAME"
		;;
	1)
		log_existance "$DIR$temp_dir"
		;;
	2)
		log_existance "$DIR$userdir"
		;;
	*)
		echo "[WARN] Something un-usual happened "
		echo "[ERROR] script has not started !!"
esac