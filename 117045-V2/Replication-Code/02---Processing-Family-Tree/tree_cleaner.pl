open(my $dates, '>', 'dates.csv')
    or die "Unable to open file, $!";

open(my $GEDCOM, '<', 'royal2014update.GED')
    or die "Unable to open file, $!";


#Produce a listing of ID,Birth Year, Death Year;

print $dates "Person ID, Birth Year, Death Year"; 

while ( $line=<$GEDCOM> ) {


if ( $line=~ /\@I(\d*)\@\sINDI/ ){

$ID = $1;

$birthyear = 0;

print $dates "\n";
print $dates $ID;
print $dates ",";  
}

if ( $prevline=~ /BIRT/ && $line =~ /.*(\d{4})/ ){

$birthyear = $1;

print $dates $birthyear;
print $dates ",";    
}

if ( $prevline=~ /DEAT/  && $line =~ /.*(\d{4})/ ){

if ( $birthyear == 0 ){
print $dates ",";
} 

$deathyear=$1;

print $dates $deathyear;
}


$prevline = $line;
}

close($dates);
close($GEDCOM);


#Produce a listing of Husband ID, Wife ID, Child IDs;
#Also produce listing of Husband ID, Wife ID, Marriage Year;


open(my $GEDCOM, '<', 'royal2014update.GED')
    or die "Unable to open file, $!";

open(my $family, '>', 'families.csv')
    or die "Unable to open file, $!";
open(my $marriages, '>', 'marriages.csv')
    or die "Unable to open file, $!";

print $family "Husband, Wife, Child 1, Child2, etc";
print $marriages "Husband, Wife, Marriage Year";  

while ( $line=<$GEDCOM> ) {


if ( $line=~ /\@F\d*\@\sFAM/ ){

$Husband = 0;
$Wife = 0;
$Children = 0;

print $family "\n";
print $marriages "\n";  
}

if ( $line=~ /HUSB\s\@I(\d*)\@/ ){

$Husband = $1;

print $family "$Husband";

print $marriages "$Husband";
   
}

if ( $line=~ /WIFE\s\@I(\d*)\@/ ){

$Wife = $1;

print $family ",";
print $family "$Wife";


print $marriages ",";
print $marriages "$Wife";
  
}

if ( $line=~ /CHIL\s\@I(\d*)\@/ ){

$Children = $Children + 1;

if ( $Wife == 0 && $Children == 1){
print $family ",";  
}

$Child = $1;

print $family ",";
print $family "$Child";
 
}

if ( $prevline=~ /1\sMARR/  && $line =~ /.*\s(\d{3,4})/ ){

$marriageyear = $1;

print $marriages ",";
print $marriages $marriageyear;
}


$prevline = $line;
}


close($family);
close($marriages);
close($GEDCOM);