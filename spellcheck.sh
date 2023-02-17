#!/bin/sh
#
# Spell check a leanpub book

which aspell >/dev/null
if [ "$?" != "0" ]; then 
	echo "Cannot find aspell"
	exit 1;
fi

# Can run at the top or in manuscript
#
dir="manuscript"
[ -f "Book.txt" ] && dir="."

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

	sed -e 's/{.*}//g' < $dir/$file > $aspellfile

	cp $aspellfile $aspellnew
	aspell check --add-filter="pagebreak" --mode=markdown --lang=en $aspellnew

	diff -u $aspellfile $aspellnew >> $diff
	if [ $? != "0" ]; then
		echo "$file" 
		cat $diff 
		echo "" 
		echo "================="
	fi
	rm $aspellfile $aspellnew

done

rm $diff

