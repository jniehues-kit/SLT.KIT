#!/usr/bin/perl
# remove lines in source and target texts if there are less than n words in a line
# each line
use strict;
use utf8;
open INPUT, "<$ARGV[0]"; 
binmode INPUT, ":utf8"; 
binmode STDOUT, ":utf8"; 
binmode STDERR, ":utf8"; 

my @words;

my $range = 10; 
my $offset = 20;
my $rand; 
my $text = "" ; 


$rand = int(rand($range)) + $offset;

while (my $line = <INPUT>){
   chomp($line);
   my @words = split(/\s\s*/,$line); 
   foreach my $word(@words){
       if($rand <= 0 && $word !~ /\p{P}/) {
	   print "\n";
	   $rand = int(rand($range)) + $offset;
       }
       chomp($word); 
       print $word;
       print " ";
       $rand--
   } 
}
 
