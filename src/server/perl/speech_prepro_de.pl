#!/usr/bin/perl 

use utf8; use strict;

binmode(STDIN,":utf8");
binmode(STDOUT,":utf8");

my @single = ("null", "ein", "zwei", "drei", "vier", "fünf", "sechs", "sieben", "acht", "neun", "zehn", "elf", "zwölf", "dreizehn", "vierzehn", "fünfzehn", "sechzen", "siebzehn", "achtzehn", "neunzehn");
my %sing = (); my $ind = 0;
foreach my $s (@single){
   $sing{$s} = $ind;
   $ind++;
}
$sing{"eins"} = 1; 

my @decimal = ("zwanzig", "dreißig", "vierzig", "fünfzig", "sechzig", "siebzig", "achtzig", "neunzig"); 
my %dec = (); my $ind = 20; 
foreach my $d(@decimal){ 
   $dec{$d} = $ind; 
   $ind = $ind+10; 
} 

my %others= (); 
$others{"hundert"} = 100; 
$others{"tausend"} = 1000; 

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
$greek{'my'} = 'μ';
$greek{'ny'} = 'ν';
$greek{'xi'} = 'ξ';
$greek{'omikron'} = 'ο';
$greek{'pi'} = 'π';
$greek{'rho'} = 'ρ';
$greek{'sigma'} = 'σ';
$greek{'tau'} = 'τ';
$greek{'ypsilon'} = 'υ';
$greek{'phi'} = 'φ';
$greek{'chi'} = 'χ';
$greek{'psi'} = 'ψ';
$greek{'omega'} = 'ω';

my @alphabets = ('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'); 
my %alpha = (); my $ind = 1; 
foreach my $a (@alphabets) {
   $alpha{$a} = $ind; 
   $ind++; 
}

my $vars='a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z'; 
my $greeks='alpha|beta|gamma|delta|epsilon|zeta|eta|theta|iota|kappa|lambda|my|ny|xi|omikron|pi|rho|sigma|tau|ypsilon|phi|chi|psi|omega'; 
my $num_sings='null|eins|zwei|drei|vier|fünf|sechs|sieben|acht|neun|zehn|elf|zwölf|dreizehn|vierzehn|fünfzehn'; 
  
sub single_digit {
   my ($outs_ref, $n, $w, $i, $words_ref ) = @_;
   my @outs = @{ $outs_ref };  my @words = @{ $words_ref };      # dereferencing and copying each array
   if ($n == 0) {
      push(@outs, '0');
   } elsif (($n >= 1) && ($n <= 15)){
      if ((scalar(@outs) > 0)  && ($outs[-1] =~ /^\p{N}+$/)){  # if the number is followed by another number 
         if ($outs[-1]=~ /^0$/) {                                  
             push(@outs, $n); 
         } elsif (($outs[-1] =~ /^20$/) or ($outs[-1] =~ /^19$/)){  # years. twenty nineteen etc. 
             if (($i < scalar(@words)-1) && $others{lc($words[$i+1])}){  # but if it is followed by other big numbers 
               push (@outs, $w); 
             } else { 
	       if ($n >= 10) {                                        # if it is 2014, just add it 
                  my $tempn = $outs[-1].$n; 
                  pop @outs; 
                  push(@outs, $tempn); 
               } else {                                                # if it is 2008, put zero before 
                  my $tempn = $outs[-1]."0".$n;
                  pop @outs;  
                  push(@outs, $tempn); 
               }
             }              
         } elsif ($outs[-1] >= 100){                                     # if previous number is bigger than 100, add 
            if (($i < scalar(@words)-1) && $others{lc($words[$i+1])}) {  # if followed by another big numbers (hundred/thousand) 
                push(@outs, $n); 
            } else { 
                my $tempn = $outs[-1] + $n;
                pop @outs;
                push(@outs, $tempn);  
            } 
         } else {  # otherwise leave them in numbers 
	     push (@outs, $w); 
         } 
      } else { 
	 push (@outs, $w);                                      # keep the word anyway 
      } 
   } else {               # numbers between 16-19 
      if ((scalar(@outs) > 0)  && ($outs[-1] =~ /^\p{N}+$/)){ 
         if ($outs[-1]=~ /^0$/) {
             push(@outs, $n);
         } elsif (($outs[-1] =~ /^20$/) or ($outs[-1] =~ /^19$/)){  # years. twenty nineteen etc. 
             if (($i < scalar(@words)-1) && $others{lc($words[$i+1])}){  # but if it is followed by other big numbers 
               push (@outs, $n);
             } else {
               my $tempn = $outs[-1].$n;
               pop @outs;
               push(@outs, $tempn);
            } 
         } elsif (length($outs[-1]) >= 3) { # if the number is followed by bigger numbers. eg. ein hundert drei. 
             my $tempn = $outs[-1] + $n;
             pop @outs;
             push (@outs, $tempn);
         } else {
             push (@outs, $n);
         }         
      } else { 
         push (@outs, $n); 
      } 
   } 
   return @outs;
}

sub decimal_digit{ 
   my ($outs_ref, $n, $w, $i, $words_ref) = @_; 
   my @outs = @{ $outs_ref };  my @words = @{ $words_ref }; 
   if (( scalar(@outs) > 1) && ($outs[-1] =~ /^und$/) && ($sing{lc($outs[-2])})) {  # if number is followed by " (eins|zwei|drei...) und number"
      if ( $sing{lc($outs[-2])} < 10) { # if eins|zwei.. neun 
	 my $tempn = $sing{lc($outs[-2])} + $n; 
         pop @outs; pop @outs; 
         push (@outs, $tempn); 
      } else {                     # zehn und zwanzig ==> zehn und 20 
         push(@outs, $n);
      } 
   } elsif ( (scalar(@outs)> 0 ) && ($outs[-1] =~ /^(20|19)$/)){ # if it is one if zwanzig vierzig ==> 2040 
      my $tempn = $outs[-1].$n; 
      pop @outs; 
      push (@outs, $tempn); 
   } elsif ($outs[-1] >= 100) {
      if (($i < scalar(@words)-1) && $others{lc($words[$i+1])}) {  # if followed by another big numbers (hundred/thousand) 
         push(@outs, $n);
      } else {
         my $tempn = $outs[-1] + $n;
         pop @outs;
         push(@outs, $tempn);
      }
   }elsif ((scalar(@outs)> 1) && ($outs[-1] =~ /^und$/) &&  ($outs[-2] =~ /^\p{N}+$/) && ( length($outs[-2]) >= 3)) {  # 2003 und zwanzig -> 2023, 103 und zwanzig => 123 
      my $prevnum = $outs[-2];
      my @ns = split(//, $prevnum);
      if ($ns[-2] eq "0"){
	 my $tempn = $outs[-2] + $n; 
         pop @outs; pop @outs; 
         push (@outs, $tempn); 
      } else {   # if it is 110, don't add 
         push (@outs, $n); 
      } 
   } else { 
      push (@outs, $n); 
   } 
   return @outs; 
} 

sub hund_thous_digit{ 
   my ($outs_ref, $n, $w, $i, $words_ref) = @_;
   my @outs = @{ $outs_ref }; my @words = @{ $words_ref }; 
   if ( (scalar(@outs) > 0) && ($outs[-1] =~ /^\p{N}+$/)) {   # if previous is a number too 
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
   } elsif ( ( scalar(@outs) > 1) && ($outs[-1] =~ /^und$/) && $sing{lc($outs[-2])} ) { 
      my $tempn = $sing{lc($outs[-2])} * $n; 
      pop @outs; pop @outs; 
      push(@outs, $tempn); 
   }  else {
      push (@outs, $n);
   }
   return @outs; 
} 

sub getformula2 {
   my ($outs_ref) = @_;
   my @outs = @{ $outs_ref };
   my $str = ""; 
   foreach my $o (@outs){ 
      $str .= $o." "; 
   } 
   $str =~ s/(?<!\w)plus (${vars}|\p{N}+) /+$1 /ig;
   $str =~ s/(?<!\w)plus (${greeks}) /+$greek{$1} /ig; 
   $str =~ s/(?<!\w)plus (${num_sings}) /+$sing{lc($1)} /ig; 
   $str =~ s/(?<!\w)minus (${vars}|\p{N}+) /-$1 /ig;
   $str =~ s/(?<!\w)minus (${greeks}) /-$greek{$1} /ig;
   $str =~ s/(?<!\w)minus (${num_sings}) /-$sing{lc($1)} /ig; 
   $str =~ s/(?<!\w)(\p{N}+) (komma|Komma) (\p{N}+) /$1,$3 /g; 
   $str =~ s/(?<!\w)(\p{N}+) (komma|Komma) (${num_sings}) /$1,$sing{lc($3)} /g; 
   $str =~ s/(?<!\w)(${num_sings}) (komma|Komma) (${num_sings}) /$sing{lc($1)},$sing{lc($3)} /g; 
   $str =~ s/(?<!\w)(${num_sings}) (komma|Komma) (\p{N}+) /$sing{lc($1)},$3 /g; 
   $str =~ s/(?<!\w)(${vars}) von (${vars}|\p{N}+) /$1\($2\) /ig;  
   $str =~ s/(?<!\w)(${vars}) von (${greeks}) /$1\($greek{$2}\) /ig; 
   $str =~ s/(?<!\w)(${vars}) (${num_sings}) /$1<sub>$sing{lc($2)}<\/sub> /ig; 
   $str =~ s/(?<!\w)(${greeks}) (${num_sings}) /$greek{$1}<sub>$sing{lc($2)}<\/sub> /ig; 
   return $str; 
} 

while (my $line = <>){
   chomp($line);
   $line = lc($line); 
   $line =~ s/^(Ähm|Äh|äh|ähm|uh|uhm|mhm|hmm|ä|Ä) //g;  
   $line =~ s/ (Ähm|Äh|äh|ähm|uh|uhm|mhm|hmm|ä|Ä) / /g; 
   $line =~ s/ (Ähm|Äh|äh|ähm|uh|uhm|mhm|hmm|ä|Ä)\s*$//g; 
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
      } else { 
          push (@outs, $word); 
      }  
      $i++; 
   }
   my $str = getformula2(\@outs); 

   $|++;
   print $str, "\n";

} 
