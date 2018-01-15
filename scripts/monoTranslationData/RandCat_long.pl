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

while (my $line = <INPUT>){
   chomp($line);
   my @words = split(/\s\s*/,$line); 
   foreach my $word(@words){
       chomp($word); 
       $text .= $word;
       $text .= " ";
   } 
}

my @words = split(/\s\s*/,$text); 
my $i = 0; 
my $j; 

my $out = ""; 

#print scalar @words, "\n"; 

while ($i < scalar @words){
     
    $rand = int(rand($range)) + $offset;
    #print $i, "#"; 

    for ($j = $i; $j < $rand + $i ; $j++){
        print $words[$j];
        print " ";
    }
    $i = $i + $rand;  
    
    #print $i, "#";
    while ($words[$i] =~ /\p{P}/){
	print $words[$i], " ";
	$i++;
    } 

    print "\n";
   
}
 
