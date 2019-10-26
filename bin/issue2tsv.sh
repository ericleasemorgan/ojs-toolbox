#!/usr/bin/env bash

# issue2tsv.sh - given and OJS JSON issue file, output a rudimentary bibliographic TSV stream

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# October 20, 2019 - first cut; at the cabin
# October 26, 2019 - added bits of documentation


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
	
	# parse and munge; this value ought to be given for free
	URL=$( echo $ARTICLE | jq '.galleys[0].urlPublished' | sed 's/view/download/' )

	# unescape; there is probably a better way
	AUTHOR="${AUTHOR:1}"
	AUTHOR="${AUTHOR%?}"
	TITLE="${TITLE:1}"
	TITLE="${TITLE%?}"
	DATE="${DATE:1}"
	DATE="${DATE%?}"
	URL="${URL:1}"
	URL="${URL%?}"

	# trim the date; get rid of the time value
	DATE=$( echo $DATE | cut -d ' ' -f1 )
	
	# output
	printf "$AUTHOR\t$TITLE\t$DATE\t$URL\n"

	# increment
	let INDEX=INDEX+1 

# fini
done
exit

