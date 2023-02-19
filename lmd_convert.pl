#!/usr/bin/perl

# Filter to make leanpub features pandoc compliant
# V: 20210302

use strict;
use UTF8;

my $firstheading = 0;
my $centre_block = 0;
my $table_block = 0;
my $quote_block = 0;
my $line = 0;

my $processoroff = 0;

my $markua = 0;
if (@ARGV) {
	$markua=1 if $ARGV[0] eq 'm';
}

while(<STDIN>) {
	$line++;
	my $print = 1;

# Stuff to just skip
#

	if (m/^%% PREVIEWOFF/) {
		print "\nXXX EDITORS NOTE: SECTION REMOVED BY PREPROCESSOR\nXXX\n\n";
		$processoroff = 1;
		next;
	}
	if (m/^%% ENDPREVIEWOFF/) {
		$processoroff = 0;
		next;
	}

	next if $processoroff; # Ignore lines

	next if m/^%%/;	# pandoc can have trouble with comments

	next if m/{width=/;
	next if m/{mainmatter}/;
	next if m/{frontmatter}/;
	next if m/{i:/;
	next if m/\{:: encoding/;
	next if m/{backmatter}/;
	next if m/{section:/;
	next if m/hanging-paragraphs}/;
	if (m/{pagebreak}/) {
		print "\\pagebreak\n\n";
		next;
	}
	next if m/{sample:/;
	next if m/{type:/;
	
	if (m/{title=\"(.*)\"}/) {
		# Table title	
		print "\\begin{center}\n";
		print "\\textit{$1}\n";
		print "\\end{center}\n";
		next;
	}

	if ($markua) {
		# Rewrite URLs relative to resources
		# 
		my $li = $_;
		if ( my (@sp) = $li =~ m/^(\!\[.*\])\((.*)\)/ ) {
			
			if ($sp[1] =~ m/^tables/) {
				# Specific hack for me - sorry
				#
				open T, "resources/$sp[1]" or next;
				print "\\begin{center}\n\\begin{tabular} {";
				my $l = 0;
				while(<T>) {
					s/ѣ/XBX/g;
					s/ѵ/XVX/g; # These russian letters don't render
					s/\*\*//g; # Bold doesn't render in tables
					s/^\|//g;
					s/\|\s*$//g;
					my @r = split '\|';
					unless ($l) {
						
						  # First line
							for (my $i = 0; $i < (@r); $i++) {
								
								print "c ";
							}
							print "}\n";
							$l++;
					}
					for (my $i = 0; $i < (@r); $i++) {
						print " & " if $i > 0;
						print "$r[$i]";
					}
					print "\\\\";
					print "\n";
				}

				close T;
				print "\\end{tabular}\n\\end{center}\n";
			} else {
					print "$sp[0]"."("."resources/".$sp[1].")\n";
				}
			next;
		}

	}


	if (m/^~~~~~~~~/) {
		if ($quote_block == 0) {
			$quote_block = 1;
		} else {
			$quote_block = 0;
		}
	}	
	# Centred text
	#
	if (m/^C\> (.*)$/) {
		print "\\begin{center}\n" unless $centre_block;
		$centre_block = 1;
		print "$1\n\n";
		$print = 0;
	} else {
		print "\\end{center}\n" if $centre_block;
		$centre_block = 0;
	}
	
	# Fix up superscripts:
	#
	s/\^(\S+)\^/\^$1/g;
	
	# Tables
	#
	if (m/^\|/) {
		chomp;
		s/\|\s*$//; # Trim ending
		s/^\|//g; # Trim begin
		s/\*\*//g; # Bold doesn't render in tables
		$print = 0;
		my @l = split '\|';
		my $this_number = scalar(@l);
		unless ($table_block) {
			# First row of the table
			#
			print "\\begin{center}\n\\begin{tabular} {";
			for (my $c = 0; $c < $this_number; $c++) {
				print " l";
			}
			print "}\n";
			$table_block = $this_number;
		} else {
			# Body of the table
			warn "Mismatched table columns at line $line - is $this_number, should be $table_block\n$_\n"
				if ($table_block != $this_number);
		}
		my $str = "";
		for (my $i = 0; $i < $table_block; $i++) {
			print " & " unless $i == 0;
			print "$l[$i]";
		}
		print "\\\\\n";
	} else {
		print "\\end{tabular}\n\\end{center}\n" if ($table_block);
		$table_block = 0;
	}
	

	unless ($quote_block) {	
		# Hashes mean something different in quote blocks
		if (m/^# /) {
			# Section heading
			#
			print "\n\\pagebreak\n" if $firstheading;
			$firstheading++;
		}
	}

	my $li = $_;


	$li =~ s/ѣ/XBX/g;
	$li =~ s/ѵ/XVX/g;


#	if (m/\^(\d+)\^/) {
#		warn "Superscript removed: $1\n";
#		($li) = $li =~ s/\^(\d+)\^//g;
#	}
	print $li if $print;
	
}
