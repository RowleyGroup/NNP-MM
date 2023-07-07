# VMD script to create a PDB to designate the atoms in the NNP region

# the output is a PDB file (nnp.pdb) where the occupancy column of the NNP atoms is set to 1
# in this example, these are the atoms of the ligand

# vmd -e set_nnp.tcl -dispdev text -eofexit 

package require pbctools
package require topotools

mol new ionized.psf
mol addfile ionized.pdb

# the element column should be defined for all atoms

topo guessatom element mass

set all [atomselect top "all"]
set ligand [atomselect top  "resname LIG"]

$all set occupancy 0
$ligand set occupancy 1

$all writepdb nnp.pdb

quit
