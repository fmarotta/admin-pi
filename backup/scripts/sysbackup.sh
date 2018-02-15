#!/bin/bash

# Performs a snapshot backup of the specified directory using rsync. It can
# also backup databases using mysqldump. It can be run either as a "one-shot
# backup" or periodically. Useful to restore the system after a bad problem.
# For the periodical case I also provide a systemd unit (with a timer
# associated).

# For a better experience, here it is a tutorial.
#   1. The destination should be of the following format:
#	  /backup/freq/day/source
#	  that is, in the dir containing the backups, there should be a directory
#	  specifying the frequency of the backups (e.g. "weekly"); one directory
#	  specifying the directory that is backed up (e.g. "home"); and one
#	  specifying the day of the backup. The script automatically creates the
#	  last two directories, so you should only specify dest as /backup/freq.
#	  If the source is "/", in the dest it is called "system". If the source
#	  is a database, in the dest it is called "database".
#   2. If you make periodical backups, create a systemd unit. Some templates
#	  are provided. IMPORTANT: in the systemd timer, set freely the
#	  OnCalendar option, but be sure you call sysbackup with the options you
#	  really want for that period! In order to use the unit, create a service
#	  file and a timer file, and link them to /etc/systemd/system/.
#   3. You can perform an incremental backup by using the option -l. (This does
#	  not work for databases.)
#   4. You can compress the backup by using the option -c. Databases are
#	  compressed using gzip.
#   5. You can choose, with the option -p, for how many backups you will store
#	  an old backup. For example, if you execute the script every week and
#	  set -p 4, exactly four backups will be conserved. If not specified, no
#	  old backup is deleted.

# TODO: let the script take care of "freq dir" in dest.

# TODO: multiple sources at once. Read more than one -s and use a for loop.

# TODO: check memory status of $DEST.

# Define the functions.
function usage {
	cat << END
Usage: sysbackup [-l] [-c] [-p per] [--db] [-s source] -d dest
  * -l hard-links the files that did not change from the last backup.
  * -c compresses the backup.
  * per is the number of times for which a backup is conserved.
  * --db backups also the databases.
  * source is the directory to copy.
  * dest is the directory in which to store the backup.

Performs a system (and databases) bakcup using rsync (and mysqldump).
For a better experience, be sure that dest ends with a dir indicating freq.
The backups are stored in directories named as the day of the backup.
There are default options, but they are not completely satisfactory.
Note: per, source and dest have to be separated from their flags by a space.
Configuration files:
  $EXCLUDE_FILE
  (the files not to be backed up, one per line, following rsync rules.)
  $DB_NAMES_FILE
  (the names of the database to be backed up, one per line.)
Log file:
  $LOG_FILE
END
}

function get_args {
	while [ "$1" != "" ]; do
		case $1 in
			-c | --compress )
				COMPRESS=true
				;;
			-l | --link-dest )
				LINK_DEST=true
				;;
			-p | --period )
				shift
				PER=$1
				;;
			--db )
				DB=true
				;;
			-s | --source )
				shift
				SOURCE=$1
				;;
			-d | --dest )
				shift
				BASE_DEST=$1
				;;
			-h | --help )
				usage
				exit
				;;
			* )
				echo "Error: unsupported flag." > /dev/stderr
				usage
				exit 1
				;;
		esac
		shift
	done
}

# Declare default variables.
# Time params.
DAY=$(date "+%F")
PER=""
# Config and log.
BASE_DIR="/home/fmarotta/admin-pi/backup"
CONFIG_DIR="${BASE_DIR}/config"
EXCLUDE_FILE="${CONFIG_DIR}/rsyncignore"
DB_NAMES_FILE="${CONFIG_DIR}/db_names"
LOG_FILE="${BASE_DIR}/log/sysbackup.log"
# rsync params.
OPTIONS="-aAXHq --delete --exclude-from=$EXCLUDE_FILE" 
COMPRESS=false
LINK_DEST=false
SOURCE="/"
BASE_DEST=""
# mysqldump params.
DB=false

# Parse command line arguments.
get_args $@

if [ "$BASE_DEST" == "" ]; then
	echo "Error: you must specify a destination directory." > /dev/stderr
	usage
	exit 1
fi

case $SOURCE in
	"/" )
		SRC_DEST="system"
		;;
	* )
		#SRC_DEST=`echo $SOURCE | awk '{n=split($0, a, "/"); print a[n]}'`
		# For directories other than /, the directory itself is copied.
		SRC_DEST=""
		;;
esac

if $COMPRESS; then
	OPTIONS+=" -zz"
fi

if $LINK_DEST; then
	LINK_DAY=`ls -1 $BASE_DEST | sort -t "-" -g -r | head -n 1`
   	LINK_DEST="${BASE_DEST}/${LINK_DAY}/${SRC_DEST}"
   	OPTIONS+=" --link-dest=$LINK_DEST"
fi

DEST="${BASE_DEST}/${DAY}/${SRC_DEST}"

# Create the backup dest if it does not exixst. It can exist if one backs up
# more than one directory.
if [ ! -d $DEST ]; then
	mkdir -p $DEST
fi

# Backup the system.
rsync $OPTIONS $SOURCE $DEST >> $LOG_FILE 2>&1 ||
	(echo "$0: error while backing up the system." >> $LOG_FILE && exit 1)

# Delete old dests.
# FIXME: wrap this in a function.
if [ "$PER" != "" ]; then
	COUNT=0
	for OLD_DAY in `ls -1 $BASE_DEST | sort -t "-" -g -r | tr "\n" " "`; do
		((COUNT++))
		if [ $COUNT -gt $PER ]; then
			rm -rf ${BASE_DEST}/${OLD_DAY}
		fi
	done
fi

# Backup the databases.
# NOTE: in order not to enter the password, I created the file /root/.my.cnf
# containing the username and password to connect to the databases. See
# http://stackoverflow.com/questions/9293042/how-to-perform-a-mysqldump-without-a-password-prompt

if $DB; then
	DB_DEST="${BASE_DEST}/${DAY}/databases"

	if [ ! -d $DB_DEST ]; then
		mkdir -p $DB_DEST
	fi

	# Backup the databases.
	for DATABASE in `cat $DB_NAMES_FILE | tr "\n" " "`; do
		mysqldump --defaults-file=/root/.my.cnf $DATABASE \
			> ${DB_DEST}/${DATABASE}.sql 2>> $LOG_FILE ||
				(echo "$0: error while backing up db $DB." >> $LOG_FILE && exit 1)
		if $COMPRESS; then
			gzip ${DB_DEST}/${DATABASE}.sql ||
				(echo "$0: error while compressing db $DB." >> $LOG_FILE && exit 1)
		fi
	done

	# Delete old dests.
	if [ "$PER" != "" ]; then
		COUNT=0
		for OLD_DAY in `ls -1 $BASE_DEST | sort -t "-" -g -r | tr "\n" " "`; do
			((COUNT++))
			if [ $COUNT -gt $PER ]; then
				rm -rf ${BASE_DEST}/${OLD_DAY}
			fi
		done
	fi
fi

exit

