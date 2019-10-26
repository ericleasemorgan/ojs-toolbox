#!/usr/bin/env bash

# harvest.sh - given a root URL and a token, cache all the issue metdata of an OJS title

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# October 20, 2019 - first cut; at the cabin; brain-dead
# October 25, 2019 - started adding additional command-line inputs


# configure
COUNT=100
ENDPOINT='api/v1/issues'

# sanity check
if [[ -z $1 || -z $2 || -z $3 ]]; then

	echo "Usage: $0 <root url> <token> <directory>" >&2
	exit

fi

# get input
ROOT="$1"
TOKEN="$2"
DIRECTORY="$3"

# initialize
ITEMS=$( curl -s "$ROOT/$ENDPOINT?apiToken=$TOKEN&count=1" | jq .itemsMax )
OFFSET=0
ITEM=0

# make sane
mkdir -p $DIRECTORY

# process all possible issues
while [ $OFFSET -lt $ITEMS ]; do

	# re-initialize
	URL="$ROOT/$ENDPOINT?count=$COUNT&offset=$OFFSET&apiToken=$TOKEN"
	JSON=$( curl -s "$URL" )
	LENGTH=$( echo $JSON | jq '.items | length' )
	INDEX=0

	# process each issue
	while [ $INDEX -lt $LENGTH ]; do

		# parse
		ID=$( echo $JSON | jq ".items[$INDEX].id" )
		DATE=$( echo $JSON | jq ".items[$INDEX].datePublished" )
	
		# normalize
		DATE="${DATE:1}"
		DATE="${DATE%?}"
		DATE=$( echo $DATE | cut -d ' ' -f1 )

		# build url and file
		URL="$ROOT/$ENDPOINT/$ID?&apiToken=$TOKEN"
		FILE="$DIRECTORY/$DATE-$( printf '%04d' $ID ).json"
	
		# increment
		let ITEM=ITEM+1 
		
		# debug
		echo "  item: $ITEM of $ITEMS" >&2
		echo "    id: $ID"             >&2
		echo "  date: $DATE"           >&2
		echo "  file: $FILE"           >&2
		echo "   URL: $URL"            >&2
		echo                           >&2

		# harvest, conditionally
		if [[ ! -e $FILE ]]; then curl -s "$URL" | jq . > $FILE; fi

		# increment again
		let INDEX=INDEX+1 
		
	# fini
	done

	# increment yet again
	let OFFSET=OFFSET+COUNT
	
done

