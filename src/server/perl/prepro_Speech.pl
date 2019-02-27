#!/usr/bin/perl -w

use utf8;
use Encode;
use strict;
use warnings;
use Getopt::Long; 

my $lang;

GetOptions ("lang=s" => \$lang) 
or die ("Error in arguments\n"); 

binmode(STDIN,":utf8");
binmode(STDOUT,":utf8");


# inspired by /project/lectureTranslation/DE/systems_2012/online-systems/SEG2/textSeg.tcl 

sub createNumber { 
  my ($word, $val) = (@_);
  #print "Enter createNumber: ", $word, " , ", $val, "\n"; 
  my $newWord; 
  my @numlist = ("null", "eins", "zwei", "drei", "vier", "fünf", "sechs", "sieben", "acht", "neun", "zehn", "elf", "zwölf", "zwanzig", "hundert", "tausend", "ein", "sech", "sieb");
  my @bignumlist = ("komma", "Komma", "und", "zehn", "elf", "zwölf", "dreizehn", "vierzehn", "fünfzehn", "sechzen", "siebzehn", "achtzehn", "neunzehn", "zwanzig", "dreißig", "vierzig", "fünfzig", "sechzig", "siebzig", "achtzig", "neunzig", "hundert", "tausend", "million", "millionen", "milliarde", "milliarden", "billion", "billiarde", "billiarden", "billionen", "null", "eins", "zwei", "drei", "vier", "fünf", "sechs", "sieben", "acht", "neun");
  my @numvalue = (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 20, 100, 1000, 1, 6, 7);
  my @tenlist = ("zwanzig", "dreißig", "vierzig", "fünfzig", "sechzig", "siebzig", "achtzig", "neunzig");


  foreach my $num (@numlist){
    if (($word =~ /(^$num)/) and (not ($word =~ /^ein$/))) {
       my $match = $1; 
  #     print "In ForLoop, matching: ", $match, "\n";
       my ($index) = grep { $numlist[$_] eq $match } 0..$#numlist; 
       my $value = $numvalue[$index]; 
  #     print "Which is: ", $value, "\n";  

       $word =~ s/$match//g; 
  #     print "Matching removed - updated word: ", $word, "\n";

       if ( ($value eq "10") or ($value eq "11") or ($value eq "12") or ($value eq "20")) {
  #        print "# case 10/11/12/20\n"; 
          # many numbers in one word 
          if (($val > 9 ) and ($val < 100)) { 
             $newWord = createNumber ($word, $value); 
             return "$val, $newWord";  
          }
          return createNumber($word, $val+$value); 
       } elsif ($value eq 100){ 
  #        print "# case 100\n"; 
          if (($val > 19 ) and ($val < 1000)) { 
             $newWord = createNumber($word, $value); 
             return "$val, $newWord"; 
          } 
          if ($val eq 0){ $val = 1; } 
          if ($val > $value){ 
             return createNumber($word, $val+$value); 
          } else {
             return createNumber($word, $val*$value); 
          }
       } elsif ($value eq 1000){ 
  #        print "# case 1000\n"; 
          if ($val > 999){ 
             $newWord = createNumber($word, $value); 
             return "$val, $newWord"; 
          }
          if ($val eq 0){ $val = 1; } 
          if ($val > $value){
             return createNumber($word, $val+$value);
          } else {
             return createNumber($word, $val*$value);
          }
       } elsif ($word =~ /^und/){ 
  #        print "# case und\n"; 
          $word =~ s/^und//g; 
          if (not ( grep {$_ eq $word} @tenlist) ) { 
             $newWord = createNumber($word, 0); 
             return "$value und $newWord"; 
          } 
          return createNumber($word, $val+$value); 
       } elsif ($word =~ /^zehn/){
  #        print "# case zehn\n"; 
          $word =~ s/^zehn//g; 
          if (($val > 9) and ($val < 100)) {
             $newWord = createNumber($word, $value+10); 
             return "$val, $newWord"; 
          }  
          return createNumber ($word, $val+$value+10); 
       } elsif ($word =~ /^zig/){ 
  #        print "# case zig\n"; 
          $word =~ s/^zig//g; 
          if (($val > 9) and ($val < 100))  { 
             $newWord = createNumber($word, $value*10); 
             return "$val, $newWord" 
          }
          return createNumber($word, $val+$value*10); 
       } elsif ($word =~ /^ßig/){ 
  #        print "# case ßig\n"; 
          $word =~ s/^ßig//g; 
          if (($val > 9) and ($val < 100)) { 
             $newWord = createNumber($word, $value*10); 
             return "$val, $newWord"; 
          }
          return createNumber($word, $val+$value*10); 
       } elsif ($word =~ /^hundert/){ 
  #        print "# case hundert\n"; 
          $word =~ s/^hundert//g; 
          if (($val > 19 ) and ($val < 1000)) { 
             $newWord = createNumber($word, $value*100); 
             return "$val, $newWord"; 
          }
          return createNumber($word, $val+$value*100); 
       } elsif ($word =~ /^tausend/){ 
  #        print "# case tausend\n"; 
          $word =~ s/^tausend//g; 
          if (($val > 999) and ($val < 1000000)){ 
             $newWord = createNumber($word, $value*1000); 
             return "$val, $newWord"; 
          } 
          return createNumber ($word, ($val+$value)*1000); 
       } elsif (length($word) eq 0) {
  #        print "# case length zero\n";  
          return ($val+$value); 
       } else {
          return "NaN"; 
       }
    }
    if (length($word) eq 0) { #print "# outofForLoop: case length zero\n"; 
       return $val; 
    } 
       
    # many numbers in one word: remaining word begins with a number from the list
#    foreach my $num (@numlist){
#       if (($word =~ /^$num/) and (not ($word =~ /^ein$/))) {
#          $newWord = createNumber($word, 0);
#          return "$val, $newWord"; 
#       }
#    }
    
    # many numbers in one word: remaining word begins with "und"

    if (($word =~ /^und/) and (not ($word =~ /^und$/)))  { 
  #     print "# outofForLoop: und \n"; 
       $word =~ s/und//g; 
       if (  (not($val eq 0)) and (  (($val%1000) eq 0) or (($val%100) eq 0))) { 
          return createNumber($word, $val); 
       }
       $newWord = createNumber($word, 0); 
       return "$val und $newWord"; 
    }
  }
  return "NaN"; 
}

sub createFormula {   
  my ($line) = (@_); 
#  print "Formula received:", $line, "\n"; 

  $line =~ s/\,/ ,/g; 
  $line =~ s/\./ ./g; 

  # big numbers
  $line =~ s/ millionen / Millionen /g; 
  $line =~ s/ milliarden / Milliarden /g; 
  $line =~ s/\s\s*/ /g;  

  # numbers

  my $i = 0;
  my @words = split(/\s\s*/, $line);
  my @copywords = @words; 

  my $newString = "";  
  while ($i < scalar(@words)){
    my $number = createNumber ($words[$i], 0);    
#    print "Got number: $number\n"; 
#    print "i-th word : $i\n"; 

    if (not ($number eq "NaN")){ 
       my $newline = ""; 
       my $k = 0; 
       while ($k < scalar(@words)){
         if (not ($k eq $i)){ $newline .= $words[$k]. " "; } 
         $k++;  
       }

       my @numberarr = split(/\s\s*/, $number); 
       my @newwords = split(/\s\s*/, $newline); 

       my $j = 0; 
       while ($j < scalar(@numberarr)){
          splice @newwords, $i+$j, 0, $numberarr[$j]; 
          $j++;
       }

       $i = $i+$j-1; 

       $line = ""; 
       foreach my $newword(@newwords){
          $line .= $newword. " "; 
       }
       $copywords[$i] = $number; 
    } 
 
    $i++; 
  }

  foreach my $c (@copywords){
    $newString .= $c. " ";
  } 

  $line = $newString; 
#  print "= check: ", $line, "\n"; 

  # comma
  $i = 1;
  @words = (); 
  @words = split(/\s\s*/, $line); 
  while ($i < scalar(@words) - 1){
    if ( ($words[$i-1] =~ /\p{N}+/) and ($words[$i+1] =~ /\p{N}+/) and ($words[$i] =~ /komma|Komma/) ) { 
       my $leftnum = $words[$i-1]; 
       my $rightnum = $words[$i+1]; 

       my $end = 0; 
       if ($rightnum > 9) { $end = 1; } 

       my $k = 0; 
       while (($words[$i+$k+2] =~ /^\p{N}\,?$/) and ($end eq 0)) { 
          if ($k eq 0){ 
             $rightnum =~ s/\,//g; 
          }
          my $tmpnum = $words[$i+$k+2]; 
          $tmpnum =~ s/\,//g; 
          $rightnum = $rightnum.$tmpnum; 
          $k++;  
       }
#       print "DEBUG1: ", $line, "#", $leftnum, "#", $rightnum, "#", $i, "#", $k, "\n"; 
       splice @words, $i-1, $k+3, $leftnum." &#44; ".$rightnum; 
       $line = ""; 
       foreach my $w(@words){
          $line .= $w." "; 
       }
#       print "DEBUG2: ", $line, "#", $leftnum, "#", $rightnum, "#", $i, "#", $k, "\n"; 
    }
    $i++; 
  } 

  # no math expression
  if ( not (  ($line =~ / \p{L} /) or ($line =~ /^\P{L} /) or ($line =~ / \p{L}\,?\.?$/) or ($line =~ /^\p{L}\,?].?$/) or ($line =~ /\p{L}/)) ) { 
     $line =~ s/ \,/,/g; 
     $line =~ s/ \././g; 
 
     return $line." "; 
  }

  my $mathBegin = "<math xmlns:m=\"http://www.w3.org/1998/Math/MathML\">"; 
  my $mathEnd = "</math>"; 
  my $miBegin = "<mi>"; 
  my $miEnd = "</mi>"; 
  my $conjuBegin = "<mover><mrow>"; 
  my $conjuEnd = "</mrow><mo>\\&#xaf;</mo></mover>";
  
  # conjugation
 
  if ($line =~ /(\p{L}01 quer)/) { 
     my $match = $1; 
     my @matches = split(/\s\s*/, $match); 
     my $var = $matches[0]; 
     $line =~ s/\p{L}01 quer/$mathBegin$conjuBegin$miBegin$var$miEnd$conjuEnd$mathEnd/g; 
  } 
  $line =~ s/ \,/,/g; 
  $line =~ s/ \././g; 

  return $line." ";    

}


if ($lang eq "de"){ 

## copy from /project/lectureTranslation/DE/systems_2012/LMs/puncLM/pp.pl 
our @greek = (
        [ 'alpha', 'α'],
        [ 'beta', 'β'],
        [ 'gamma', 'γ'],
        [ 'delta', 'δ'],
        [ 'epsilon', 'ε'],
        [ 'zeta', 'ζ'],
        [ 'eta', 'η'],
        [ 'theta', 'θ'],
        [ 'iota', 'ι'],
        [ 'kappa', 'κ'],
        [ 'lambda', 'λ'],
        [ 'my', 'μ'],
        [ 'ny', 'ν'],
        [ 'xi', 'ξ'],
        [ 'omikron', 'ο'],
        [ 'pi', 'π'],
        [ 'rho', 'ρ'],
        [ 'sigma', 'σ'],
        [ 'tau', 'τ'],
        [ 'ypsilon', 'υ'],
        [ 'phi', 'φ'],
        [ 'chi', 'χ'],
        [ 'psi', 'ψ'],
        [ 'omega', 'ω'],
        [ 'null', '0'],
        [ 'eins', '1'],
        [ 'zwei', '2'],
        [ 'drei', '3'],
        [ 'vier', '4'],
        [ 'fünf', '5'],
        [ 'sechs', '6'],
        [ 'sieben', '7'],
        [ 'acht', '8'],
        [ 'neun', '9'] );
        
        
        
$|++;

my $vars = '(?<!\w)\+?-?(?:[a-zA-Z]|alpha|beta|gamma|delta|epsilon|zeta|eta|theta|iota|kappa|lambda|my|ny|xi|omikron|pi|rho|sigma|tau|ypsilon|phi|chi|psi|omega)(?!\w)';
my $nums = '(?<!\w)(?:null|eins|zwei|drei|vier|fünf|sechs|sieben|acht|neun)(?!\w)';
my $bignums = '(?<!\w)(?:zehn|elf|zwölf|dreizehn|vierzehn|fünfzehn|sechzen|siebzehn|achtzehn|neunzehn|zwanzig|dreißig|vierzig|fünfzig|sechzig|siebzig|achtzig|neunzig|hundert|tausend|million|millionen|milliarde|milliarden|billion|billiarde|billiarden|billionen|null|eins|zwei|drei|vier|fünf|sechs|sieben|acht|neun)(?!\w)';

my $inumber = 0;

while (my $line = <>) {
  $line =~ s/\s\s*/ /g;
  $line =~ s/^\s+//g;  
  $line =~ s/\n//ig;
  if( $line =~  /^[ \t\n]*$/ ) {$|++;print ""; next;}

  my @ws = split(/ /, $line);

  $line =~ s/($bignums)/\<$1\>/ig;
#  print "Bignum :" ,$line, "\n"; 
  $line =~ s/\<([^ ]*)\> und <([^ ]*)\>/\<${1}und${2}\>/ig;
  $line =~ s/\<([^ ]*)\> <([^ ]*)\>/\<${1}${2}\>/ig;
  
  $line =~ s/\<([^ ]*)\> und <([^ ]*)\>/\<${1}und${2}\>/ig;
  $line =~ s/\<([^ ]*)\> <([^ ]*)\>/\<${1}${2}\>/ig;
  $line =~ s/\<([^ ]*)\> und <([^ ]*)\>/\<${1}und${2}\>/ig;
  $line =~ s/\<([^ ]*)\> <([^ ]*)\>/\<${1}${2}\>/ig;  

  $line =~ s/(?<!\w)K I T(?!\w)/K I T/ig;  

  $line =~ s/\<//ig;  
  $line =~ s/\>//ig;  
  
  $line =~ s/\+ +/\+/ig;
  $line =~ s/(?<=\+)(\p{l})/lc($1)/eg;
  $line =~ s/\+//ig;
  
  $line =~ s/($vars) ($nums)/$1<sub>$2<\/sub>/ig;
  $line =~ s/(?<!\w)plus (${vars}[^ ]*)/+$1/ig;
  $line =~ s/(?<!\w)minus (${vars}[^ ]*)/-$1/ig;
  
  $line =~ s/Ernst Moritz/Ernst-Moritz/i;

  $line =~ s/(${vars}[^ ]*) von (${vars}[^ ]*)/$1\($2\)/ig;

  for (0 .. $#greek)
  {
    $line =~ s/(?<!\w)$greek[$_][0](?!\w)/$greek[$_][1]/ig;
  }
  
  $|++;

  my $out = createFormula ($line);  
  print $out, "\n"; 
}

} elsif ($lang eq "en"){

## copy from /project/lectureTranslation/EN/online/punctuation/punct_script.pl 

 
#constants to determine the upper and lower bound for years which are spoken as two-digit numbers, meaning 20 35 => 2035
 use constant YEARS_LOWER_LIMIT    => 1000;
 use constant YEARS_UPPER_LIMIT    => 3000;

our @greek = (
	[ 'alpha',   'α' ],
	[ 'beta',    'β' ],
	[ 'gamma',   'γ' ],
	[ 'delta',   'δ' ],
	[ 'epsilon', 'ε' ],
	[ 'zeta',    'ζ' ],
	[ 'eta',     'η' ],
	[ 'theta',   'θ' ],
	[ 'iota',    'ι' ],
	[ 'kappa',   'κ' ],
	[ 'lambda',  'λ' ],
	[ 'mu',      'μ' ],
	[ 'nu',      'ν' ],
	[ 'xi',      'ξ' ],
	[ 'omicron', 'ο' ],
	[ 'pi',      'π' ],
	[ 'rho',     'ρ' ],
	[ 'sigma',   'σ' ],
	[ 'tau',     'τ' ],
	[ 'upsilon', 'υ' ],
	[ 'phi',     'φ' ],
	[ 'chi',     'χ' ],
	[ 'psi',     'ψ' ],
	[ 'omega',   'ω' ]
);

our %numbers = ();
$numbers{'zero'}      = 0;
$numbers{'one'}       = 1;
$numbers{'two'}       = 2;
$numbers{'three'}     = 3;
$numbers{'four'}      = 4;
$numbers{'five'}      = 5;
$numbers{'six'}       = 6;
$numbers{'seven'}     = 7;
$numbers{'eight'}     = 8;
$numbers{'nine'}      = 9;
$numbers{'ten'}       = 10;
$numbers{'eleven'}    = 11;
$numbers{'twelve'}    = 12;
$numbers{'thirteen'}  = 13;
$numbers{'fourteen'}  = 14;
$numbers{'fifteen'}   = 15;
$numbers{'sixteen'}   = 16;
$numbers{'seventeen'} = 17;
$numbers{'eighteen'}  = 18;
$numbers{'nineteen'}  = 19;
$numbers{'twenty'}    = 20;
$numbers{'thirty'}    = 30;
$numbers{'forty'}     = 40;
$numbers{'fifty'}     = 50;
$numbers{'sixty'}     = 60;
$numbers{'seventy'}   = 70;
$numbers{'eighty'}    = 80;
$numbers{'ninety'}    = 90;
$numbers{'hundred'}   = 100;
$numbers{'thousand'}  = 1000;

our %numerals = ();
$numerals{'first'} = 'one';
$numerals{'second'} = 'two';
$numerals{'third'} = 'three';
$numerals{'fourth'} = 'four';
$numerals{'fifth'} = 'five';
$numerals{'sixth'} = 'six';
$numerals{'seventh'} = 'seven';
$numerals{'eighth'} = 'eight';
$numerals{'ninth'} = 'nine';
$numerals{'tenth'} = 'ten';
$numerals{'eleventh'} = 'eleven';
$numerals{'twelfth'} = 'twelve';
$numerals{'thirteenth'} = 'thirteen';
$numerals{'fourteenth'} = 'fourteen';
$numerals{'fifteenth'} = 'fifteen';
$numerals{'sixteenth'} = 'sixteen';
$numerals{'seventeenth'} = 'seventeen';
$numerals{'eighteenth'} = 'eighteen';
$numerals{'nineteenth'} = 'nineteen';
$numerals{'twentieth'} = 'twenty';
$numerals{'thirtieth'} = 'thirty';
$numerals{'fortieth'} = 'forty';
$numerals{'fiftieth'} = 'fifty';
$numerals{'sixtieth'} = 'sixty';
$numerals{'seventieth'} = 'seventy';
$numerals{'eightieth'} = 'eighty';
$numerals{'ninetieth'} = 'ninety';
$numerals{'hundredth'} = 'hundred';
$numerals{'thousandth'} = 'thousand';
$|++;

my $greek_vars =
  '(?<!\w)\+?-?(?:[a-zA-Z]|alpha|beta|gamma|delta|upsilon|zeta|eta|theta|iota
|kappa|lambda|mu|nu|xi|omikron|pi|rho|sigma|tau|upsilon|phi|chi|psi|omega)(?!\w)';

my $one_digit = '(?:zero|one|two|three|four|five|six|seven|eight|nine)';
my $one_digit_without_zero = '(?:one|two|three|four|five|six|seven|eight|nine)';
my $one_digit_nums ='(?<!\w)(?:zero|one|two|three|four|five|six|seven|eight|nine)(?!\w)';
my $one_digit_ordinal = '(?:first|second|third|fourth|fifth|sixth|seventh|eighth|ninth)';

my $two_digit = '(?:ten|eleven|twelve|thirteen|fourteen|fifteen|sixteen|seventeen|eighteen|nineteen|twenty|thirty|forty|fifty|sixty|seventy|eighty|ninety)';
my $two_digit_ordinal ='(?:tenth|eleventh|twelfth|thirteenth|fourteenth|fifteenth|sixteenth|seventeenth|eighteenth|nineteenth|twentieth|thirtieth|fortieth|fiftieth|sixtieth|seventieth|eightieth|ninetieth|hundredth|thousandth)';
my $two_digit_compound = $two_digit.' '.$one_digit.'??';
my $two_digit_compound_ordinal = $two_digit.' '.$one_digit_ordinal.'??';
my $two_digit_nums_compound = '(?<!\w)(?:('.$two_digit.' '.$one_digit_without_zero.'??)|'.'('.$two_digit.'-'.$one_digit_without_zero.'??)|('.$two_digit.$one_digit_without_zero.'??))(?!\w)'; 
my $two_digit_nums_compound_oridnal = '(?<!\w)(?:('.$two_digit_ordinal.')|('.$two_digit.' '.$one_digit_ordinal.')|'.'('.$two_digit.'-'.$one_digit_ordinal.')|('.$two_digit.$one_digit_ordinal.'))(?!\w)'; 


my $three_digit = 'hundred';
my $three_digit_ordinal = 'hundredth';
my $three_digit_nums = '(?<!\w)(?:('.$two_digit.' '.$one_digit_without_zero.'?? )|'.'('.$two_digit.'-'.$one_digit_without_zero.'?? )|('.$two_digit.$one_digit_without_zero.'?? )|'.$one_digit_without_zero.' )??hundred(?!\w)';
my $three_digit_nums_compound1 = '(?<!\w)(?:('.$two_digit.' '.$one_digit_without_zero.'?? )|'.'('.$two_digit.'-'.$one_digit_without_zero.'?? )|('.$two_digit.$one_digit_without_zero.'?? )|'.$one_digit_without_zero.' )??hundred (and )??(?:('.$two_digit.' '.$one_digit_without_zero.'??)|'.'('.$two_digit.'-'.$one_digit_without_zero.'??)|('.$two_digit.$one_digit_without_zero.'??)|'.$one_digit_without_zero.')(?!\w)';
my $three_digit_nums_ordinal = '(?<!\w)(?:('.$two_digit.' '.$one_digit_without_zero.'?? )|'.'('.$two_digit.'-'.$one_digit_without_zero.'?? )|('.$two_digit.$one_digit_without_zero.'?? )|'.$one_digit_without_zero.' )??hundredth(?!\w)';
my $three_digit_nums_compound_ordinal = '(?<!\w)(?:('.$two_digit.' '.$one_digit_without_zero.'?? )|'.'('.$two_digit.'-'.$one_digit_without_zero.'?? )|('.$two_digit.$one_digit_without_zero.'?? )|'.$one_digit_without_zero.' )??hundred (and )??(?:('.$two_digit_ordinal.')|('.$two_digit.' '.$one_digit_ordinal.')|('.$two_digit.'-'.$one_digit_ordinal.')|('.$two_digit.$one_digit_ordinal.')|('.$one_digit_ordinal.'))(?!\w)';


my $four_digit = "thousand";
my $four_digit_ordinal = "thousandth";
my $four_digit_nums  = '(?<!\w)(?:('.$two_digit.' '.$one_digit_without_zero.'?? )|'.'('.$two_digit.'-'.$one_digit_without_zero.'?? )|('.$two_digit.$one_digit_without_zero.'?? )|'.$one_digit_without_zero.' )??thousand(?!\w)';
my $four_digit_nums_ordinal  = '(?<!\w)(?:('.$two_digit.' '.$one_digit_without_zero.'?? )|'.'('.$two_digit.'-'.$one_digit_without_zero.'?? )|('.$two_digit.$one_digit_without_zero.'?? )|'.$one_digit_without_zero.' )??thousandth(?!\w)';
my $four_digit_nums_compound1  = '(?<!\w)(?:('.$two_digit.' '.$one_digit_without_zero.'?? )|'.'('.$two_digit.'-'.$one_digit_without_zero.'?? )|('.$two_digit.$one_digit_without_zero.'?? )|'.$one_digit_without_zero.' )??thousand (and )??(('.$one_digit_without_zero.' )??hundred)??(?!\w)';
my $four_digit_nums_compound1_ordinal  = '(?<!\w)(?:('.$two_digit.' '.$one_digit_without_zero.'?? )|'.'('.$two_digit.'-'.$one_digit_without_zero.'?? )|('.$two_digit.$one_digit_without_zero.'?? )|'.$one_digit_without_zero.' )??thousand (and )??(('.$one_digit_without_zero.' )??hundredth)(?!\w)';
my $four_digit_nums_compound2 = '(?<!\w)(?:('.$two_digit.' '.$one_digit_without_zero.'?? )|'.'('.$two_digit.'-'.$one_digit_without_zero.'?? )|('.$two_digit.$one_digit_without_zero.'?? )|'.$one_digit_without_zero.' )??thousand (and )??(('.$one_digit_without_zero.') hundred (and )??(?:('.$two_digit.' '.$one_digit_without_zero.'??)|'.'('.$two_digit.'-'.$one_digit_without_zero.'??)|('.$two_digit.$one_digit_without_zero.'??)|'.$one_digit_without_zero.')??)(?!\w)';
my $four_digit_nums_compound2_ordinal = '(?<!\w)(?:('.$two_digit.' '.$one_digit_without_zero.'?? )|'.'('.$two_digit.'-'.$one_digit_without_zero.'?? )|('.$two_digit.$one_digit_without_zero.'?? )|'.$one_digit_without_zero.' )??thousand (and )??('.$one_digit_without_zero.' )??hundred (and )??(?:('.$two_digit_ordinal.')|('.$two_digit.' '.$one_digit_ordinal.')|('.$two_digit.'-'.$one_digit_ordinal.')|('.$two_digit.$one_digit_ordinal.')|('.$one_digit_ordinal.'))??(?!\w)';
my $four_digit_nums_compound3  = '(?<!\w)(?:('.$two_digit.' '.$one_digit_without_zero.'?? )|'.'('.$two_digit.'-'.$one_digit_without_zero.'?? )|('.$two_digit.$one_digit_without_zero.'?? )|'.$one_digit_without_zero.' )??thousand (and )??(?:('.$two_digit.' '.$one_digit_without_zero.'??)|'.'('.$two_digit.'-'.$one_digit_without_zero.'??)|('.$two_digit.$one_digit_without_zero.'??)|'.$one_digit_without_zero.')??(?!\w)';
my $four_digit_nums_compound3_ordinal  = '(?<!\w)(?:('.$two_digit.' '.$one_digit_without_zero.'?? )|'.'('.$two_digit.'-'.$one_digit_without_zero.'?? )|('.$two_digit.$one_digit_without_zero.'?? )|'.$one_digit_without_zero.' )??thousand (and )??(?:('.$two_digit_ordinal.')|('.$two_digit.' '.$one_digit_ordinal.')|('.$two_digit.'-'.$one_digit_ordinal.')|('.$two_digit.$one_digit_ordinal.')|('.$one_digit_ordinal.'))??(?!\w)';
my $four_digit_nums_compound3_ext  = '(?<!\w)(?:('.$two_digit.' '.$one_digit_without_zero.'?? )|'.'('.$two_digit.'-'.$one_digit_without_zero.'?? )|('.$two_digit.$one_digit_without_zero.'?? )|'.$one_digit_without_zero.' )??thousand ('.$one_digit_without_zero.')(?!\w)';
my $four_digit_nums_compound3_ordinal_ext  = '(?<!\w)(?:('.$two_digit.' '.$one_digit_without_zero.'?? )|'.'('.$two_digit.'-'.$one_digit_without_zero.'?? )|('.$two_digit.$one_digit_without_zero.'?? )|'.$one_digit_without_zero.' )??thousand ('.$one_digit_ordinal.')(?!\w)';

while ( my $line = <STDIN> ) {
        $line =~ s/\s\s*/ /g; 
        $line =~ s/^\s+//g; 
	$line =~ s/\n//ig;
        $line = lc($line); 
	if ( $line =~ /^[ \t\n]*$/ ) { $|++; print ""; next; }

	# -------------------    started:   removing all 4-digit-numbers   ----------------------------------#
	
	#removing all the ordinal numbers :)
	while( $line =~ m/($four_digit_nums_ordinal)/ig || $line =~ m/($four_digit_nums_compound1_ordinal)/ig || $line =~ m/($four_digit_nums_compound2_ordinal)/ig || $line =~ m/($four_digit_nums_compound3_ordinal)/ig )
	{
		
		my $substitute = $1;
		my $to_replace = $1;
		
		if($substitute =~ m/$four_digit_nums_compound3_ordinal_ext/ig)
		{
			$substitute =~ s/($one_digit_ordinal)$/and $1/ig;
		}
		
		$substitute =~ s/($four_digit_ordinal)/$four_digit/ig;
		$substitute =~ s/($three_digit_ordinal)/$three_digit/ig;
		$substitute =~ s/($two_digit_ordinal)/$numerals{$1}/ig;
		$substitute =~ s/($one_digit_ordinal)/$numerals{$1}/ig;
		$substitute =~ s/($two_digit)-/$1/ig;
		$substitute =~ s/($two_digit)/$1 /ig;
		
		$substitute =~ s/  / /ig;
		

		$substitute = Parsing_String_To_Digits($substitute);
		
		
		if($substitute%100 > 9 && $substitute%100 < 20 )
		{
			$substitute = $substitute.'th';
		}
		elsif($substitute%10 == 1)
		{
			$substitute = $substitute.'st';
		}
		elsif($substitute%10 == 2)
		{
			$substitute = $substitute.'nd';
		}
		elsif($substitute%10 == 3)
		{
			$substitute = $substitute.'rd';
		}
		else 
		{
			$substitute = $substitute.'th';
		}
		
		$line =~ s/($to_replace)/$substitute/ig;
	}
	
	while( $line =~ m/($four_digit_nums_compound2)/ig )
	{
		my $substitute = $1;
		my $to_replace = $1;
		
		$substitute =~ s/($two_digit)-/$1/ig;
		$substitute =~ s/($two_digit)/$1 /ig;
		$substitute =~ s/  / /ig;
		
		$substitute = Parsing_String_To_Digits($substitute);
		
		$line =~ s/($to_replace)/$substitute/ig;
	}
	
	while( $line =~ m/($four_digit_nums_compound1)/ig)
	{
		my $substitute = $1;
		my $to_replace = $1;
		
		$substitute =~ s/($two_digit)-/$1/ig;
		$substitute =~ s/($two_digit)/$1 /ig;
		$substitute =~ s/  / /ig;
		
		$substitute = Parsing_String_To_Digits($substitute);
		
		$line =~ s/($to_replace)/$substitute/ig;
	}
	
	while( $line =~ m/($four_digit_nums_compound3)/ig )
	{
		my $substitute = $1;
		my $to_replace = $1;
		
		$substitute =~ s/($two_digit)-/$1/ig;
		$substitute =~ s/($two_digit)/$1 /ig;
		$substitute =~ s/  / /ig;
		
		if($substitute =~ m/$four_digit_nums_compound3_ext/ig)
		{
			$substitute =~ s/($one_digit_without_zero)$/and $1/ig;
		}
		
		$substitute = Parsing_String_To_Digits($substitute);
		
		$line =~ s/($to_replace)/$substitute/ig;
	}
	
	
	while( $line =~ m/($four_digit_nums)/ig)
	{
		my $substitute = $1;
		my $to_replace = $1;
		
		$substitute =~ s/($two_digit)-/$1/ig;
		$substitute =~ s/($two_digit)/$1 /ig;
		$substitute =~ s/  / /ig;

		$substitute = Parsing_String_To_Digits($substitute);
		
		$line =~ s/($to_replace)/$substitute/ig;
	}
	
	# -------------------    finished:   removing all 4-digit-numbers   ----------------------------------#
	
	# -------------------    started:   removing all 3-digit-numbers   ----------------------------------#

	#removing all the ordinal 3-digit numbers
	while( $line =~ m/($three_digit_nums_compound_ordinal)/ig || $line =~ m/($three_digit_nums_ordinal)/ig )
	{
		
		my $substitute = $1;
		my $to_replace = $1;
		
		$substitute =~ s/($three_digit_ordinal)/$three_digit/ig;
		$substitute =~ s/($two_digit_ordinal)/$numerals{$1}/ig;
		$substitute =~ s/($one_digit_ordinal)/$numerals{$1}/ig;
		$substitute =~ s/($two_digit)-/$1/ig;
		$substitute =~ s/($two_digit)/$1 /ig;
		
		$substitute =~ s/  / /ig;

		$substitute = Parsing_String_To_Digits($substitute);
		
		
		if($substitute%100 > 9 && $substitute%100 < 20 )
		{
			$substitute = $substitute.'th';
		}
		elsif($substitute%10 == 1)
		{
			$substitute = $substitute.'st';
		}
		elsif($substitute%10 == 2)
		{
			$substitute = $substitute.'nd';
		}
		elsif($substitute%10 == 3)
		{
			$substitute = $substitute.'rd';
		}
		else 
		{
			$substitute = $substitute.'th';
		}
		
		$line =~ s/($to_replace)/$substitute/ig;
	}
	
	
	while( $line =~ m/($three_digit_nums_compound1)/ig)
	{
		my $substitute = $1;
		my $to_replace = $1;
		
		$substitute =~ s/($two_digit)-/$1/ig;
		$substitute =~ s/($two_digit)/$1 /ig;
		$substitute =~ s/  / /ig;

		$substitute = Parsing_String_To_Digits($substitute);
		
		$line =~ s/($to_replace)/$substitute/ig;
	}

	
	while( $line =~ m/($three_digit_nums)/ig)
	{
		my $substitute = $1;
		my $to_replace = $1;
		
		$substitute =~ s/($two_digit)-/$1/ig;
		$substitute =~ s/($two_digit)/$1 /ig;
		$substitute =~ s/  / /ig;
		
		$substitute = Parsing_String_To_Digits($substitute);
		
		$line =~ s/($to_replace)/$substitute/ig;
	}
	
	# -------------------    started:   removing all 3-digit-numbers   ----------------------------------#
	
	
	# -------------------    started:   removing all 2-digit-numbers   ----------------------------------#
	
	
	while( $line =~ m/($two_digit_nums_compound_oridnal)/ig)
	{
		
		my $substitute = $1;
		
		my $to_replace = $1;
		
		$substitute =~ s/($one_digit_ordinal)/$numerals{$1}/ig;
		$substitute =~ s/($two_digit_ordinal)/$numerals{$1}/ig;
		$substitute =~ s/($two_digit)-/$1/ig;
		$substitute =~ s/($two_digit)/$1 /ig;

		
		$substitute =~ s/  / /ig;
		

		$substitute = Parsing_String_To_Digits($substitute);
		
		if($substitute%100 > 9 && $substitute%100 < 20 )
		{
			$substitute = $substitute.'th';
		}
		elsif($substitute%10 == 1)
		{
			$substitute = $substitute.'st';
		}
		elsif($substitute%10 == 2)
		{
			$substitute = $substitute.'nd';
		}
		elsif($substitute%10 == 3)
		{
			$substitute = $substitute.'rd';
		}
		else 
		{
			$substitute = $substitute.'th';
		}
		
		$line =~ s/($to_replace)/$substitute/ig;
	}
	
	
	while( $line =~ m/($two_digit_nums_compound)/ig)
	{
		
		my $substitute = $1;
		my $to_replace = $1;
		
		$substitute =~ s/($two_digit)-/$1/ig;
		$substitute =~ s/($two_digit)/$1 /ig;
		$substitute =~ s/  / /ig;

		$substitute = Parsing_String_To_Digits($substitute);
		
		$line =~ s/($to_replace)/$substitute/ig;
		
		#$line =~ s/($1)/$numbers{$1}/ig;
		
	}
	
	#this is meant to remove all the 19 25 and transform them into a real year 1925	
	while($line =~ m/(?<!\w)(\d\d) (\d\d)(?!\w)/ig)
	{
		my $substitute = $1.$2;
		my $to_replace = $1.' '.$2;
		if($substitute > YEARS_LOWER_LIMIT && $substitute < YEARS_UPPER_LIMIT)
		{
			$line =~ s/($to_replace)/$substitute/ig;
		}
		else
		{
			#we need to adjust the offset in the regex in order to have it search all the possible accurences
			my $offset = pos($line);
			if(defined $offset)
			{
				pos($line) = $offset-2;
			}
		}		
	}
	
	# -------------------       finished: removing all 2-digit-numbers   ----------------------------------#
	
	
	
	
	# -------------------    started:   removing all 1-digit-numbers + oridnals => no since they need to be written out ----------------------------------#
	 	#finally removing one digit numbers which are leftover and not caugh before that
		#$line =~ s/($one_digit_nums)/$numbers{$1}/ig;
		
		#this code will remove all the ordinals!
		while($line=~ m/($one_digit_ordinal)/ig)
		{
			my $matching = $1;
			my $to_replace = $1;
			
			$matching = $numbers{$numerals{$1}};
			if($matching == 1)
			{
				$matching = $matching.'st';
			}
			elsif($matching == 2)
			{
				$matching = $matching.'nd';
			}
			elsif($matching == 3)
			{
				$matching = $matching.'rd';
			}
			else 
			{
				$matching = $matching.'th';
			}
			
			$line =~ s/($to_replace)/$matching/ig;
		}
	# -------------------    started:   removing all 1-digit-numbers   ----------------------------------#
	
	
	
	#artihmetic expressions
	$line =~ s/plus/+/ig;
	$line =~ s/minus/-/ig;

	#the greek characters, subscripts, and functions
	for ( 0 .. $#greek )
	{
		my $repl =$greek[$_][1];
		my $temp = -1;
		#the stuff with sub can happen with regex and numbers ^^
		while ( $line =~ m/(?<!\w)$greek[$_][0] from ([0-9]+|[a-z]+)(?!\w)/ig )
		{	
				my $to_replace = $1;
				if(length($to_replace) > 1)
				{
					$temp = $numbers{$1};
				}
				if((defined $temp) && ($temp > 0) )
				{
					$line =~ s/(?<!\w)$greek[$_][0] from $to_replace(?!\w)/$repl($temp)/ig;
				}
				else
				{
					$line =~ s/(?<!\w)$greek[$_][0] from $to_replace(?!\w)/$repl($to_replace)/ig;
				}
			
		}
		while ( $line =~ m/(?<!\w)$greek[$_][0] ([0-9]+|[a-z])(?!\w)/ig )
		{
			my $to_replace = $1;
			
			if(length($to_replace) > 1)
			{
				$temp = $numbers{$1};
			}
			
			if( (defined $temp) && ($temp > 0) )
			{
				$line =~ s/(?<!\w)$greek[$_][0] $to_replace(?!\w)/$repl<sub>$temp<\/sub>/ig;
			}
			else
			{
				$line =~ s/(?<!\w)$greek[$_][0] $to_replace(?!\w)/$repl<sub>$to_replace<\/sub>/ig;
			}
		}
	
		$line =~ s/(?<!\w)$greek[$_][0](?!\w)/$repl/ig;
	
	}
	

	#random things
	$line =~ s/Ernst Moritz/Ernst-Moritz/i;
	$line =~ s/(?<!\w)K I T(?!\w)/K I T/ig;

	$|++;

	print "$line\n";
}



#the function responsible to parsing spoken digits to numbers :)
sub Parsing_String_To_Digits{
	
	my $inputval = $_[0];
	
	
	my @inputWordArr;
    if (exists $numbers{$inputval}){
    	 return $numbers{$inputval};
    } 
    else
    {
    	@inputWordArr = split( / /, $inputval );
    }
        
   
    #Check the pathological case where hundred is at the end or thousand is at end
    if ($inputWordArr[-1] eq 'hundred')
    {
    	push (@inputWordArr, 'zero');
    	push (@inputWordArr, 'zero');
    }
    
    if ($inputWordArr[-1] eq 'thousand')
    {
    	push (@inputWordArr, 'zero');
    	push (@inputWordArr, 'zero');
    	push (@inputWordArr, 'zero');
    }
    
    if ($inputWordArr[0] eq 'hundred')
    {
    	unshift (@inputWordArr, 'one');
    }
    
      if ($inputWordArr[0] eq 'thousand')
    {
    	unshift (@inputWordArr, 'one');
    }
       
    
    my $currentPosition = 'unit';
    my $output = 0;
    
    my $number = 0;
    my @reversed_string = reverse(@inputWordArr);
    
    foreach (@reversed_string)
    {
    	$number = 0;
        if( $currentPosition eq 'unit')
        {
            $number = $numbers{$_};
            $output += $number;
            if($number > 9)
            {
            	 $currentPosition = 'hundred';
            }
            else
            {
            	$currentPosition = 'ten';
            }
                
        }
        elsif( $currentPosition eq 'ten')
        {
        	
            if(($_ ne 'hundred') && ($_ ne 'and'))
            {
            	$number = $numbers{$_};
                if($number < 10)
                {
                	$output += $number*10;
                } 
                else
                {
                	$output += $number;
                }  
            }
             $currentPosition = 'hundred';
            
            
        }
        elsif( $currentPosition eq 'hundred')
        {
     
            if(($_ ne 'hundred') && ($_ ne 'thousand') && ($_ ne 'and') ) 
            {
            	$number = $numbers{$_};
                $output += $number*100;
                $currentPosition = 'hundred';
            } 
            elsif($_ eq 'thousand')
            {
            	 $currentPosition = 'thousand';
            }  
            elsif($_ eq 'hundred')
            {
            	$currentPosition = 'hundred';
            }  
        }
        elsif($currentPosition eq 'thousand')
        {
            #assert word != 'hundred'
            if(($_ ne 'thousand') && ($_ ne 'and'))
            {
            	$number = $numbers{$_};
                $output += $number*1000
            }
        }
        else
        {
        	print "Not supposed to be here!";
        }
            
    }
	
	return $output;
}
} 

