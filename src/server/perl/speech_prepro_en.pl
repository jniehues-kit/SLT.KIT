#!/usr/bin/perl 

use utf8; use strict;

binmode(STDIN,":utf8");
binmode(STDOUT,":utf8");

my @single = ("zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "forteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"); 
my %sing = (); my $ind = 0; 
foreach my $s (@single){ 
   $sing{$s} = $ind; 
   $ind++; 
} 

my @singledates = ("first", "second", "third", "fourth", "fifth", "sixth", "seventh", "eighth", "ninth", "tenth", "eleventh", "twelfth", "thirteenth", "fourteenth", "fifteenth", "sixteenth", "seventeenth", "eighteenth", "nineteenth"); 
my %singdat = (); my $ind = 1; 
foreach my $s (@singledates) {
   if ($ind == 1) { 
       $singdat{$s} = $ind."st"; 
   } elsif ($ind == 2){ 
       $singdat{$s} = $ind."nd"; 
   } elsif ($ind == 3) {
       $singdat{$s} = $ind."rd";
   } else { 
       $singdat{$s} = $ind."th"; 
   } 
   $ind++; 
} 

my @decimal = ("twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"); 
my %dec = (); my $ind = 20; 
foreach my $d(@decimal){ 
   $dec{$d} = $ind; 
   $ind = $ind+10; 
} 

my @decimaldates = ("twentieth", "thirtieth", "fortieth", "fiftieth", "seventieth", "eightieth", "ninetieth"); 
my %decdat = (); my $ind = 20; 
foreach my $d (@decimaldates){ 
   $decdat{$d} = $ind."th"; 
   $ind = $ind+10; 
} 

my %others= (); 
$others{"hundred"} = 100; 
$others{"thousand"} = 1000; 

my %greek = (); 
$greek{'alpha'} = 'α'; 
$greek{'beta'} = 'β'; 
$greek{'gamma'} = 'γ'; 
$greek{'delta'} = 'δ'; 
$greek{'epsilon'} = 'ε'; 
$greek{'zeta'} = 'ζ'; 
$greek{'eta'} = 'η'; 
$greek{'theta'} = 'θ'; 
$greek{'iota'} = 'ι'; 
$greek{'kappa'} = 'κ'; 
$greek{'lambda'} = 'λ'; 
$greek{'mu'} = 'μ'; 
$greek{'nu'} = 'ν'; 
$greek{'xi'} = 'ξ'; 
$greek{'omicron'} = 'ο'; 
$greek{'pi'} = 'π'; 
$greek{'rho'} = 'ρ'; 
$greek{'sigma'} = 'σ'; 
$greek{'tau'} = 'τ'; 
$greek{'upsilon'} = 'υ'; 
$greek{'phi'} = 'φ'; 
$greek{'chi'} = 'χ'; 
$greek{'psi'} = 'ψ'; 
$greek{'omega'} = 'ω'; 

my @monthsandweekdays= ("january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"); 
my %monthday= (); my $ind = 1; 
foreach my $m (@monthsandweekdays){ 
   $monthday{$m} = $ind; 
   $ind ++; 
} 

sub single_dates { 
   my ($outs_ref, $n, $w, $i, $words_ref ) = @_;
   my @outs = @{ $outs_ref };  my @words = @{ $words_ref };      # dereferencing and copying each array
   if ( (scalar(@outs) > 0) && $monthday{$outs[-1]}) {
       push (@outs, $n); 
   } elsif ((scalar(@outs) > 1) && $monthday{$outs[-2]} && ($outs[-1] =~ /^the$/) ){
       push (@outs, $n);
   } elsif ( ($i<scalar(@words) -1 ) && $monthday{lc($words[$i+1])}) { 
       push (@outs, $n); 
   } elsif ( (scalar(@words) -1 > 0 ) && ($outs[-1] =~ /^\p{N}+$/))  {
       my $cpn = $n;
       $cpn =~ s/(st|nd|rd|th)$//g; 
       if (length($cpn) < length($outs[-1]) ){ 
 	   my $tempn = $outs[-1] + $cpn;
           if ($tempn =~ /1$/) {
	       $tempn .= "st"; 
           } elsif ($tempn =~ /2$/){ 
	       $tempn .= "nd"; 
           } elsif ($tempn =~ /3$/){
               $tempn .= "rd"; 
           } else { 
	       $tempn .= "th"; 
           } 
           pop @outs; 
           push (@outs, $tempn); 
       } else { 
       	   push (@outs, $n); 
       } 
       
   } else { 
       if ($n =~ /^(1st|2nd|3rd)$/){ 
           push (@outs, $w); 
       } else { 
	   push (@outs, $n); 
       }
   } 
   return @outs; 
}

sub deci_dates { 
   my ($outs_ref, $n, $w, $i, $words_ref ) = @_;
   my @outs = @{ $outs_ref };  my @words = @{ $words_ref };      # dereferencing and copying each array
   my $cpn = $n; 
   $cpn =~ s/th$//g;  
   if ( ($cpn <= 30) && (scalar(@outs) > 0) && $monthday{$outs[-1]}) {
       push (@outs, $n);
   } elsif ( ($cpn <= 30) && (scalar(@outs) > 1) && $monthday{$outs[-2]} && ($outs[-1] =~ /^the$/) ){
       push (@outs, $n);
   } elsif ( ($cpn <= 30) && ($i<scalar(@words) -1 ) && $monthday{lc($words[$i+1])}) {
       push (@outs, $n);
   } elsif ( (scalar(@words) -1 > 0 ) && ($outs[-1] =~ /^\p{N}+$/))  {
       if (length($cpn) < length($outs[-1]) ){
          my $tempn = $outs[-1] + $cpn; 
          $tempn .= "th"; 
          pop @outs;
          push (@outs, $tempn);
       } else { 
	  push (@outs, $n); 
       }
   } else { 
       push (@outs, $n); 
   }  
   return @outs; 
} 

sub single_digit { 
   my ($outs_ref, $n, $w, $i, $words_ref ) = @_;
   my @outs = @{ $outs_ref };  my @words = @{ $words_ref };      # dereferencing and copying each array
   if ($n == 0) {
      push(@outs, '0');  
   } elsif (($n >= 1) && ($n <= 15)){                            # numbers between 1 and 15 
      if ( (scalar(@outs) > 0) && ($outs[-1] =~ /^\p{N}+$/)){    # followed by another number 
         if ($outs[-1]=~ /^0$/) {                                  
            push(@outs, $n); 
         } elsif (($outs[-1] =~ /^20$/) or ($outs[-1] =~ /^19$/)){   # in case of 20- 19- years: just put them next to each other 
	    if ($n >= 10) { 
	       my $tempn = $outs[-1].$n; 
               pop @outs; 
               push(@outs, $tempn); 
            } elsif ( $outs[-1] =~ /^20$/) { 
               my $tempn = $outs[-1]+$n;
               pop @outs;
               push(@outs, $tempn);
            } else { 
               push(@outs, $n); 
            } 
         } elsif (($outs[-1] < 100) && ($outs[-1] %10 ==0) && ($n < 10) ) {  # when previous number was 20, 30, ..90 and current is < 10, add them 
	    my $tempn = $outs[-1] + $n; 
            pop @outs; 
            push (@outs, $tempn); 
         } elsif ($outs[-1] >= 100){                                     # if previous number is bigger than 100, add 
            if (($i < scalar(@words)-1) && $others{lc($words[$i+1])}) {  # if followed by another big numbers (hundred/thousand) 
		push(@outs, $n); 
            } else { 
            	my $tempn = $outs[-1] + $n;
            	pop @outs;
            	push(@outs, $tempn);  
            } 
         } else {                                                # otherwise just serial of numbers.. 
            push(@outs, $n); 
         } 
      } elsif ( (scalar(@outs) > 1) && ($outs[-1] =~ /^and$/) && ($outs[-2] =~ /^\p{N}+$/) && ($outs[-2] >= 100))  {  # if numbers are written next to each other by "and" 
         if (( $i < scalar(@words) -1 ) && $others{lc($words[$i+1])}) { 
	    push (@outs, $n); 
         } else { 
            my $tempn = $outs[-2]+$n;
            pop @outs; pop @outs; 
            push(@outs, $tempn);  
         }
      } else { 
         push (@outs, $w);
      }
   } else { 
      if ( (scalar(@outs) > 0) && ($outs[-1] =~ /^\p{N}+$/)){
         if ($outs[-1]=~ /^0$/) {
            push(@outs, $n); 
         } elsif (($outs[-1] =~ /^20$/) or ($outs[-1] =~ /^19$/)){
            my $tempn = $outs[-1].$n;
            pop @outs;
            push(@outs, $tempn); 
         } elsif ($outs[-1] >= 100) {
            my $tempn = $outs[-1] + $n;
            pop @outs;
            push(@outs, $tempn);
         } else { 
	    push(@outs, $n); 
         } 
      } elsif ( (scalar(@outs) > 1) && ($outs[-1] =~ /^and$/) && ($outs[-2] =~ /^\p{N}+$/) && ($outs[-2] >= 100))  {
         my $tempn = $outs[-2]+$n;
         pop @outs; pop @outs;
         push(@outs, $tempn);
      }  else { 
	 push(@outs, $n); 
      } 
   } 
   return @outs;  
} 

sub decimal_digit{ 
   my ($outs_ref, $n, $w, $i, $words_ref) = @_; 
   my @outs = @{ $outs_ref };  my @words = @{ $words_ref }; 
   if ( (scalar(@outs) > 0) && ($outs[-1] =~ /^\p{N}+$/)) { 
      if ($outs[-1]=~ /^0$/) {
          push(@outs, $n);
      } elsif (($outs[-1] =~ /^20$/) or ($outs[-1] =~ /^19$/)){
          my $tempn = $outs[-1].$n;
          pop @outs;
          push(@outs, $tempn);
      } elsif ($outs[-1] >= 100) {
          if (($i < scalar(@words)-1) && $others{lc($words[$i+1])}) {  # if followed by another big numbers (hundred/thousand) 
             push(@outs, $n);
          } else { 
             my $tempn = $outs[-1] + $n; 
             pop @outs;
             push(@outs, $tempn);
          } 
      } else { 
          push(@outs, $n); 
      } 
   } elsif ( (scalar(@outs) > 1) && ($outs[-1] =~ /^and$/) && ($outs[-2] =~ /^\p{N}+$/) && ($outs[-2] >= 100))  {
      my $tempn = $outs[-2]+$n;
      pop @outs; pop @outs;
      push(@outs, $tempn);
   } else { 
      push (@outs, $n); 
   } 
   return @outs; 
} 

sub hund_thous_digit{ 
   my ($outs_ref, $n, $w, $i, $words_ref) = @_;
   my @outs = @{ $outs_ref }; my @words = @{ $words_ref }; 
   if ( (scalar(@outs) > 0) && ($outs[-1] =~ /^\p{N}+$/)) {
      if ($outs[-1]=~ /^0$/) {
          push(@outs, $n); 
      } elsif ($outs[-1] < $n) { 
          my $tempn = $outs[-1]*$n;
          if (scalar(@outs) > 1) {
	     if ((length($tempn) %4 == 0) &&  (length($outs[-2]) - length($tempn) <= 1)) { 
	        pop @outs; 
                push(@outs, $tempn); 
             } elsif ( length($outs[-2]) > length($tempn) ) { 
	        my $newtempn = $outs[-2] + $tempn;
                pop @outs; pop @outs;
                push (@outs, $newtempn) ;
             } else { 
	        pop @outs;
                push(@outs, $tempn);
             } 
          } else { 
             pop @outs;
             push(@outs, $tempn);
          }
      } else {
          push(@outs, $n);
      }
   } elsif ( (scalar(@outs) > 0) && $sing{lc($outs[-1])} ) { 
      my $tempn = $sing{lc($outs[-1])} * $n; 
      if ((scalar(@outs) > 1) && ($outs[-2] =~ /^\p{N}+$/) && (length($outs[-2]) > length($tempn))) { 
	 my $newtempn = $outs[-2] + $tempn; 
         pop @outs; pop @outs; 
         push (@outs, $newtempn);
      } else { 
         pop @outs; 
         push (@outs, $tempn); 
      }
   } elsif ( ( scalar(@outs) > 1) && ($outs[-1] =~ /^and$/) && $sing{lc($outs[-2])} ) { 
      my $tempn = $sing{lc($outs[-2])} * $n; 
      pop @outs; pop @outs; 
      push(@outs, $tempn); 
   }  else {
      push (@outs, $n);
   }
   return @outs; 
} 

sub hund_dates { 
   my ($outs_ref, $w, $i, $words_ref) = @_;
   my @outs = @{ $outs_ref }; my @words = @{ $words_ref };
   my $n = 100;
   if ($w =~ /^thousand/){ $n = $n * 10; }
   if ( (scalar(@outs) > 0) && ($outs[-1] =~ /^\p{N}+$/)){
       if (length ($outs[-1]) < length($n) ) {
	  my $tempn = $outs[-1] * $n; 
          pop (@outs); 
          push (@outs, $tempn."th"); 
       } else { 
	  push (@outs, $n."th"); 
       } 
   } elsif ( (scalar(@outs) > 0) && $sing{lc($outs[-1])} ) {
      my $tempn = $sing{lc($outs[-1])} * $n;
      if ((scalar(@outs) > 1) &&  ($outs[-1] =~ /^and$/) && (length($outs[-2]) > length($tempn))) {
         my $newtempn = $outs[-2] + $tempn;
         pop @outs; pop @outs;
         push (@outs, $newtempn."th") ;
      } else {
         pop @outs;
         push (@outs, $tempn."th");
      }
   } else {
       if ($w =~ /^hundredth$/) { push (@outs, "100th"); } 
       elsif ($w =~ /^thousandth$/) {push (@outs, "1000th"); } 
   } 
   return @outs; 
} 

while (my $line = <>){ 
   chomp($line);
   $line =~ s/(twenty|thirty|forty|fifty|sixty|seventy|eighty|ninety)\-(one|two|three|four|five|six|seven|eight|nine)/$1 $2/g; 
   my @words = split(/\s\s*/, $line); 
   my @outs = (); 
   my $i = 0; 
   while ($i < scalar(@words)){ 
      my $word = $words[$i];
      if ($sing{lc($word)}) {  
          @outs = single_digit(\@outs, $sing{lc($word)}, $word, $i, \@words); 
      } elsif ($dec{lc($word)}) {
          @outs = decimal_digit(\@outs, $dec{lc($word)}, $word, $i, \@words);      
      } elsif ($others{lc($word)}) { 
          @outs = hund_thous_digit(\@outs, $others{lc($word)}, $word, $i, \@words);  
      } elsif ($singdat{lc($word)}){ 
          @outs = single_dates(\@outs, $singdat{lc($word)}, $word, $i, \@words); 
      } elsif ($decdat{lc($word)}) {
          @outs = deci_dates(\@outs, $decdat{lc($word)}, $word, $i, \@words); 
      } elsif ($word =~ /^(hundredth|thousandth)$/) { 
          @outs = hund_dates(\@outs, $word, $i, \@words); 
      } else {
	  push (@outs, $word); 
      } 
      $i++; 
   }
   my $str = "";   

   my $i = 0; 
   while ($i < scalar(@outs)){
      if ($greek{lc($outs[$i])}) {
          if ( ($i < scalar(@outs) - 1) && ( $outs[$i+1] =~ /^\p{N}$/)) {
              $str .= $greek{lc($outs[$i])}."<sub>".$outs[$i+1]."</sub> ";  
              $i++;
          } else { 
  	      $str .= $greek{lc($outs[$i])}." "; 
          }
      } elsif ($outs[$i] =~ /^\p{N}+$/){  
          $str .= $outs[$i]." "; 
      } elsif ($outs[$i] =~ /^\p{N}+(th|nd|rd|st)$/) { 
          $str .= $outs[$i]." "; 
      } else { 
	  $str .= $outs[$i]. " "; 
      } 
      $i++; 
   } 
   $|++; 
   print $str, "\n"; 
}  
