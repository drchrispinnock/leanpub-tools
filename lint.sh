#!/bin/sh

# Linter
#
# Works with Leanpub-flavoured Markdown
#
# 20210306

tooldir=`dirname $0`

if [ -d manuscript/resources ]; then
# Markua
	IMAGELIST=`find manuscript/resources -print | grep -v '.DS_Store' | sed -e 's/^manuscript\/resources\///g'`
	ROOT="manuscript/resources"
else 
	IMAGELIST=`find manuscript/images -print | grep -v '.DS_Store' | sed -e 's/^manuscript\///g'`
	ROOT="manuscript"
fi

# Check all files are present
#
echo "Checking Book.txt files"
echo "================================================================"

find manuscript -print | grep -v 'manuscript/images' | grep -v 'manuscript/resources' | grep -v 'Book.txt$' | sed -e 's/^manuscript\///g' | perl $tooldir/orf_files.pl

# Check all images are present
#
echo "Checking Referenced Images"
echo "================================================================"
REFERENCEDIMAGES=`grep -r "^!\[" --include '*.md' manuscript | awk -F"[()]" '{print $2}'`

for i in ${REFERENCEDIMAGES}; do
	[ ! -f "$ROOT/$i" ] && echo "$i not found"
done

# Find orphaned images
#
echo "Checking Orphaned Images"
echo "================================================================"
for i in ${IMAGELIST}; do
	match="0"
	if [ -f "manuscript/$i" ]; then
		for j in ${REFERENCEDIMAGES}; do
			[ "$i" = "$j" ] && match="1";
		done
		[ "$i" = "images/title_page.jpg" ] && match="1" # Not referenced
		[ "$match" = "0" ] && echo "$i is orphaned"
	fi
done

