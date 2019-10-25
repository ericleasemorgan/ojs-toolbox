#!/usr/bin/env bash

ROOT=https://ejournals.bc.edu/index.php/ital
TOKEN=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.IlwiOGIxZjkxMzgzMWIxZmFlOTJmODc0YjBmODVjYjY4NzY1Y2NmMDhlM1wiIg.QHN4gRUqW5Di0M4A3Z3NB1FIa9p5P56-iSOJBbbt-Ag
DIRECTORY='./ital'

# configure
COUNT=50
OFFSET=0
ENDPOINT='api/v1/issues'

# initialize
ITEMS=$( curl -s "$ROOT/$ENDPOINT?apiToken=$TOKEN&count=1" | jq .itemsMax )

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
	while [ $INDEX -lt $COUNT ]; do

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
	
		# debug
		echo "      id: $ID"   >&2
		echo "    date: $DATE" >&2
		echo "    file: $FILE" >&2
		echo "     URL: $URL"  >&2
		echo                   >&2

		# harvest, conditionally
		if [[ ! -e $FILE ]]; then curl -s "$URL" | jq . > $FILE; fi

		# increment
		let INDEX=INDEX+1 
		
	# fini
	done

	# increment
	let OFFSET=OFFSET+COUNT
	
done

