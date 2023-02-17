#!/bin/sh
#
# Spell check a leanpub book git repository using aspell
#
# Filter out leanpub directives. Uses the book directory
# to store aspell dictionaries and configuration so that they
# can be done per book.
#
# (c) Chris Pinnock 2023
#
# Supplied under the Ming Vase license - if it breaks your stuff, you
# get to keep the pieces.

# Check we have aspell in the path
#
which aspell >/dev/null
if [ "$?" != "0" ]; then 
	echo "Cannot find aspell"
	exit 1;
fi

# Can run at the top or in manuscript, but always put the dictionaries
# above manuscript
#
dictdir=.
dir="manuscript"
[ -f "Book.txt" ] && dir="." && dictdir=".."

if [ ! -f "$dir/Book.txt" ]; then
	echo "Cannot locate Book.txt file"
	exit 1;
fi

diff=`mktemp /tmp/spellingdiff.XXXXXX`

for file in `grep -v '^#' $dir/Book.txt`; do

	aspellfile=`mktemp /tmp/aspell.orig.XXXXXX`
	aspellnew=`mktemp /tmp/aspell.new.XXXXXX`

	if [ ! -f "$dir/$file" ]; then
		echo "$file not found" 
		echo "" 
                echo "================="
		continue
	fi

	# Apply any filters to remove Leanpub directives
	#
	sed -e 's/{.*}//g' < $dir/$file > $aspellfile

	cp $aspellfile $aspellnew
	aspell check --home-dir=$dictdir --add-filter="pagebreak" --mode=markdown --lang=en $aspellnew

	diff -u $aspellfile $aspellnew > $diff
	if [ $? != "0" ]; then
		echo "$file" 
		cat $diff 
		echo "" 
		echo "================="
	fi
	rm $aspellfile $aspellnew

done

rm $diff

