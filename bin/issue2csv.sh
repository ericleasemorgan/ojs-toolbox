#!/usr/bin/env bash

# issues2csv.sh - given OJS JSON file, output a rudimentary bibliographic CSV file
# sample usage: find ./cache -name '*.json' -exec ./bin/issue2csv.sh {} > ./ojs.tsv \;

# Eric Lease Morgan <emorgan@nd.edu>
# October 20, 2019 - first cut; at the cabin


# sanity check
if [[ -z $1 ]]; then
	echo "Usage: $0 <file>" >&2
	exit
fi

# initialize
JSON=$1
ARTICLES=$( cat $JSON | jq '.articles' )
LENGTH=$( echo $ARTICLES | jq 'length' )
INDEX=0

# process each article
while [ $INDEX -lt $LENGTH ]; do

	# re-initialize
	ARTICLE=$( echo $ARTICLES | jq ".[$INDEX]" )
	
	# parse
	AUTHOR=$( echo $ARTICLE | jq '.shortAuthorString' )
	TITLE=$( echo $ARTICLE | jq '.fullTitle.en_US' )
	DATE=$( echo $ARTICLE | jq '.datePublished' )
	URL=$( echo $ARTICLE | jq '.galleys[0].urlPublished' | sed 's/view/download/' )

	# unescape
	AUTHOR="${AUTHOR:1}"
	AUTHOR="${AUTHOR%?}"
	TITLE="${TITLE:1}"
	TITLE="${TITLE%?}"
	DATE="${DATE:1}"
	DATE="${DATE%?}"
	URL="${URL:1}"
	URL="${URL%?}"

	# trim the date
	DATE=$( echo $DATE | cut -d ' ' -f1 )
	
	# output
	printf "$AUTHOR\t$TITLE\t$DATE\t$URL\n"

	# increment
	let INDEX=INDEX+1 

# fini
done
exit

