# standard VMD script to place the complex into a water box and add ions to solution
# vmd -e solvate.tcl -dispdev text -eofexit 

package require solvate
package require autoionize

solvate protein-ligand-complex.psf  protein-ligand-complex.pdb -t 12 -o protein-ligand-complex-solvate
autoionize -psf protein-ligand-complex-solvate.psf -pdb protein-ligand-complex-solvate.pdb -sc 0.15 -cation POT

