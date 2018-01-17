#!/usr/bin/perl

# Concatenating words of the file 

use utf8; 
use Encode;
use strict;

open FILE, "<$ARGV[0]"; 
binmode FILE, ":utf8"; 
binmode STDOUT, ":utf8"; 
binmode STDERR, ":utf8"; 

my $limit = $ARGV[1]; 

if($#ARGV + 1 != 2)
	{
		print STDERR "Usage: ./ConCat10.pl file limit\n";
 		exit(0);
	}

#open files

my @words;
while (my $src = <FILE>){
  chomp($src);
  my @newW = split(/\s\s*/,$src);
  @words = (@words,@newW);
  
  while(scalar @words >= $limit) {
    for(my $i = 0; $i < $limit; $i++) {
      print $words[$i]," ";
    }
    print "\n";
    shift(@words);
  }
}

while(scalar @words > 0) {
  for(my $i = 0; $i < $limit ; $i++) {
    print $words[$i]," ";
  }
  print "\n";
  shift(@words);
}

