# vmd -e build-complex.tcl -dispdev text -eofexit 

# this is a standard VMD script to build the protein ligand complex from the 
# PDF files of the protein, crystalographic waters, and ligand

package require psfgen

topology toppar/ligand.rtf
topology toppar/top_all36_cgenff.rtf
topology toppar/top_all36_prot.rtf
topology toppar/toppar_all36_prot_na_combined.str
topology toppar/top_all36_na.rtf
topology toppar/toppar_water_ions.rtf

pdbalias residue HIS HSD
pdbalias atom ILE CD1 CD

segment PROA {
first NTER; last CTER; auto angles dihedrals
pdb protein.pdb
}

coordpdb protein.pdb PROA
guesscoord

segment XW {
first none; last none; auto angles dihedrals
pdb xrd_water.pdb
}

coordpdb xrd_water.pdb XW
guesscoord

segment LIG {
first none
last none
residue 1 LIG
auto angles dihedrals
}
coordpdb ligand.pdb LIG

writepsf protein-ligand-complex.psf
writepdb protein-ligand-complex.pdb

quit

