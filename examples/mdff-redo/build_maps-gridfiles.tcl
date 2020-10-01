#!/usr/bin/env tclsh

### Tcl script to prepare input files for ReMDFF
# @author: John Vant
# @email: jvant@asu.edu
####
# Usage:  vmd -dispdev text -e < build_maps-gridfiles.tcl -args -psf <psffile> -pdb <pdbfile> -res <res> ??options??
#      -nummaps <int> ; number of maps you wish to create
#      -dres <int> ; the difference in resolution between maps
###

# Argument parser
proc named {args defaults} {
    upvar 1 "" ""
    array set "" $defaults
    foreach {key value} $args {
	if (![info exists ($key)]) {
	    error "bad option '$key', should be one of: [lsort [array names {}]]"
	}
	set ($key) $value
    }
}

# Set default arguments
named $argv {-psf 4hjo-implicit.psf -pdb 4hjo-implicit.pdb -res 4 -nummaps "" -dres 1 -ligname MOL}


# load mdff package
package require mdff

set mol_name [file rootname $(-psf)]

puts "my psf is $(-psf) my pdb is $(-pdb)"

mol new $(-psf)
mol addfile $(-pdb)

# Make atomselections
set selall [atomselect top all]
set selnoh [atomselect top noh]
set selbb [atomselect top backbone]
set selligand [atomselect top "resname MOL"]

if {$(-nummaps) != ""} {
    for {set i 0} {$i < $(-nummaps)} {incr i} {
	puts "its working!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	set res [expr $(-res) + $i]
	mdff sim ${selnoh} -res $res -o ${mol_name}_$res.dx
	mdff griddx -i ${mol_name}_$res.dx -o ${mol_name}_$res\_grid.dx
    }
} else {
    puts "its working!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    mdff sim ${selnoh} -res $(-res) -o ${mol_name}_$(-res).dx
    mdff griddx -i ${mol_name}_$(-res).dx -o ${mol_name}_$(-res)\_grid.dx    
}
puts "its working!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
# Create gridpdbs
# noh w/o ligand
set ligand_segname $(-ligname)
puts $ligand_segname
puts "#####################"
mdff gridpdb -psf $(-psf) -pdb $(-pdb) -o ${mol_name}_noh-nolig.pdb
# noh w/ ligand
mdff gridpdb -psf $(-psf) -pdb $(-pdb) -o ${mol_name}_noh-lig.pdb -seltext "(noh and protein) or (noh and segname $ligand_segname)"
# bb w/o lig
mdff gridpdb -psf $(-psf) -pdb $(-pdb) -o ${mol_name}_bb-nolig.pdb -seltext "backbone and protein"
# bb w/ lig
mdff gridpdb -psf $(-psf) -pdb $(-pdb) -o ${mol_name}_bb-lig.pdb -seltext "(backbone and protein) or (noh and segname $ligand_segname)"

exit
