#!/usr/bin/perl 

use utf8; use strict; 

open FILE, "<$ARGV[0]"; 
binmode FILE, ":utf8"; 

binmode STDOUT, ":utf8"; 

while (my $line = <FILE>){
  my @words = split(/\s\s*/, $line); 
  foreach my $word(@words){ 
    if ($word =~ /(\.|\,|\!|\?|\")$/){ 
      my @chars = split(//, $word); 
      my $fix = ""; 
      my $i = -1; 
      while ($chars[$i] =~ /(\.|\,|\!|\?|\")/){ 
        $fix = $chars[$i].$fix; 
        $i--; 
      }
      if ($word =~ /[A-Z]/){ 
	print "U".$fix," "; 
      } else { 
	print "L".$fix, " "; 
      }
    } else { 
      if ($word =~ /[A-Z]/){
        print "U", " ";
      } else {
        print "L", " ";
      }
    } 
  }  
  print "\n"; 
} 

