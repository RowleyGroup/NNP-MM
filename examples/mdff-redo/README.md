These scripts show how the ANI neural network potential can be used to represent the ligand in
a MDFF cryo-EM structure fitting simulation. In this case, the cryo-EM data is simulated from 
the experimental crystalogrpahic PDB file.

1. Generate restraints on peptide chirality and cis/trans isomerization: vmd -e gen_cistrans.tcl  
2. Generate secondary structure restraints: vmd -e gen_restraints.tcl
3. Generate PDB file indicating that the ligand (resname MOL) should be represented by the NNP: vmd -e set_qmmm.tcl
4. Build the simulated cyro-EM data from the PDB file and generate selections to indicate that the protein backbone and ligand atoms should be fit to the density file: vmd -e build_maps-gridfiles.tcl
5. Start the NNP on the computing node (nohup server.py >& server.out)
5. namd2 prot-step1.conf >& prot-step1.out

