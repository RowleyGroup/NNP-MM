# this script uses vmd 
package require pbctools
package require topotools

mol new 4hjo-implicit.pdb
mol addfile 4hjo-implicit.pdb

set sel [atomselect top "all"]

#topo guessatom $sel type mass
topo guessatom   element mass

set sel [atomselect top "all"]
set selmemb [atomselect top "resname MOL"]

$sel set occupancy 0.0
$selmemb set occupancy 1.0
$sel writepdb qmmm.pdb

quit
