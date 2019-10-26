#!/usr/bin/env bash

# issues2tsv.sh - given a directory of OJS JSON issue files, output rudimentary bibliographic TSV stream

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# October 25, 2019 - first cut; taking a rest from writing
# October 26, 2019 - abstracted, a very tiny bit


# configure
ISSUE2TSV='./bin/issue2tsv.sh'

# sanity check
if [[ -z $1 ]]; then
	echo "Usage: $0 <directory>" >&2
	exit
fi

# get input
DIRECTORY=$1

# output a header
printf "author\ttitle\tdate\turl\n"

# do the work and done
find $DIRECTORY -name '*.json' | parallel $ISSUE2TSV {}
exit
