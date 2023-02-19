#!/usr/bin/perl

use strict;
my %ignore;
my @reg;
my %Book;

if ( -f ".lintignore" ) {
	open IN, ".lintignore";
	while(<IN>) {
		chomp;
		$ignore{$_} = 1;
		push @reg, $_;
	}
	close IN;
}

unless ( -f "manuscript/Book.txt" ) {
	die "Need a Book.txt file\n";
} else {
	open BK, "manuscript/Book.txt";
	while (<BK>) {
		next if /^#/;
		next if /^$/;
		chomp;
		$Book{$_} = 1;
	}
	close BK;
}

# Check Book files exist
#
foreach my $f (keys(%Book)) {
	next if $f eq 'Subset.txt';
	next if $f eq '.gitignore';
	
	print "$f is missing\n" unless ( -f "manuscript/$f" );
}

# Check Orphans
FILE: while(<>) {
	chomp;
	next unless ( -f "manuscript/$_" );
	foreach my $r (@reg) {
		if (m/$r/) {
#			print "$_ ignored\n";
			next FILE;
		}
	}
	print "$_ is orphaned\n" unless ( $Book{$_} );

}
