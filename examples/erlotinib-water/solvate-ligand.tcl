package require solvate  
package require autoionize

solvate ligand_vmd.psf ligand_vmd.pdb -o  ligand_solv -x 12 +x 12 -y 12 +y 12 -z 12 +z 12
#-minmax { {16 16 16} {16 16 16}}
autoionize -psf ligand_solv.psf -pdb ligand_solv.pdb -sc 0.15 -o  ionized

quit
