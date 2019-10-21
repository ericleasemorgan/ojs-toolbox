#!/usr/bin/env bash

# harvest-issues.sh - given a root and a key, cache issues from an OJS instance

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# October 20, 2019 - first cut; at the cabin; brain-dead


# sanity check
if [[ -z $1 ]]; then

	echo "Usage: $0 <token>" >&2
	exit

fi

# get input
TOKEN=$1

# configure
URL="https://ejournals.bc.edu/index.php/ital/api/v1/issues?count=100&apiToken=$TOKEN"
ISSUE='https://ejournals.bc.edu/index.php/ital/api/v1/issues'
DIRECTORY='./cache'

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
