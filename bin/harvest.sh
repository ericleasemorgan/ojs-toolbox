#!/usr/bin/env bash

# harvest.sh - given a root and a key, cache issues from an OJS instance

# https://ejournals.bc.edu/index.php/ital
# "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.IlwiOGIxZjkxMzgzMWIxZmFlOTJmODc0YjBmODVjYjY4NzY1Y2NmMDhlM1wiIg.QHN4gRUqW5Di0M4A3Z3NB1FIa9p5P56-iSOJBbbt-Ag
# ital

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# October 20, 2019 - first cut; at the cabin; brain-dead
# October 25, 2019 - started adding additional command-line inputs


# configure
COUNT=20
OFFSET=0

# sanity check
if [[ -z $1 || -z $2 || -z $3 ]]; then

	echo "Usage: $0 <url> <token> <directory>" >&2
	exit

fi

# get input
ROOT="$1"
TOKEN="$2"
DIRECTORY="$3"

# configure
URL="$ROOT/api/v1/issues?apiToken=$TOKEN"
ISSUE="$ROOT/api/v1/issues"

# initialize
ISSUES=$( curl -s "$URL" )
LENGTH=$( echo $ISSUES | jq '.items | length' )
INDEX=0

# make sane
mkdir -p $DIRECTORY

# process each issue
while [ $INDEX -lt $LENGTH ]; do

	# parse
	ID=$( echo $ISSUES | jq ".items[$INDEX].id" )
	DATE=$( echo $ISSUES | jq ".items[$INDEX].datePublished" )
	
	# normalize
	DATE="${DATE:1}"
	DATE="${DATE%?}"
	DATE=$( echo $DATE | cut -d ' ' -f1 )

	# build url and file
	URL="$ISSUE/$ID?&apiToken=$TOKEN"
	FILE="$DIRECTORY/$DATE-$( printf '%04d' $ID ).json"
	
	# debug
	echo "    id: $ID"   >&2
	echo "  date: $DATE" >&2
	echo "  file: $FILE" >&2
	echo "   URL: $URL"  >&2
	echo                 >&2

	# harvest, conditionally
	if [[ ! -e $FILE ]]; then curl -s "$URL" | jq . > $FILE; fi
	
	# increment
	let INDEX=INDEX+1 
		
# fini
done

exit
