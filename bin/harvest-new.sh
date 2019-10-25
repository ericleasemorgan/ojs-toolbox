ROOT=https://ejournals.bc.edu/index.php/ital
TOKEN=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.IlwiOGIxZjkxMzgzMWIxZmFlOTJmODc0YjBmODVjYjY4NzY1Y2NmMDhlM1wiIg.QHN4gRUqW5Di0M4A3Z3NB1FIa9p5P56-iSOJBbbt-Ag
DIRECTORY='./ital'
COUNT=1
OFFSET=0

ITEMS=$( curl -s "$ROOT/api/v1/issues?apiToken=$TOKEN&amp;count=1" | jq .itemsMax )
mkdir -p $DIRECTORY

while [ $OFFSET -lt $ITEMS ]; do

	URL="$ROOT/api/v1/issues?count=$COUNT&offset=$OFFSET&apiToken=$TOKEN"
	
	JSON=$( curl -s "$URL" )
	
	# parse
	ID=$( echo $JSON | jq ".items[0].id" )
	DATE=$( echo $JSON | jq ".items[0].datePublished" )
	
	# normalize
	DATE="${DATE:1}"
	DATE="${DATE%?}"
	DATE=$( echo $DATE | cut -d ' ' -f1 )

	# build url and file
	URL="$ROOT/api/v1/issues/$ID?&apiToken=$TOKEN"
	FILE="$DIRECTORY/$DATE-$( printf '%04d' $ID ).json"
	
	# debug
	echo "  offset: $OFFSET of $ITEMS" >&2
	echo "      id: $ID"               >&2
	echo "    date: $DATE"             >&2
	echo "    file: $FILE"             >&2
	echo "     URL: $URL"              >&2
	echo                               >&2

	# harvest, conditionally
	if [[ ! -e $FILE ]]; then curl -s "$URL" | jq . > $FILE; fi

	# increment
	let OFFSET=OFFSET+1 
	
done

