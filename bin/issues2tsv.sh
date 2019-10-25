#!/usr/bin/env bash

# issues2tsv.sh - given a directory of OJS JSON issue files, output rudimentary bibliographic TSV file

# Eric Lease Morgan <emorgan@nd.edu>
# October 25, 2019 - first cut; taking a rest from writing


# sanity check
if [[ -z $1 ]]; then
	echo "Usage: $0 <directory>" >&2
	exit
fi

# get input
DIRECTORY=$1

# output a header
printf "author\ttitle\tdate\turl\n"

# to the work
find $DIRECTORY -name '*.json' | parallel ./bin/issue2tsv.sh {}

# done
exit
