# Using a Neural Network Potential Embedded in a MM Model using NAMD

*Shae-Lynn Lahey, Từ Nguyễn Thiên Phúc, and Christopher N. Rowley*

[www.rowleygroup.net](https://www.rowleygroup.net)

-------------------------------------------------------------------
NNP/MM embeds a Neural Network Potential into a conventional molecular mechanical (MM) model. We have implemented this using the Custom QM/MM features of NAMD 2.13, which interface NAMD with the [TorchANI NNP python library](https://aiqm.github.io/torchani/) developed by the [Roitberg](https://roitberg.chem.ufl.edu/) and [Isayev](http://olexandrisayev.com/) groups.

The server.py script must be executed and continue to run in the background before NAMD is executed. This server interfaces with the TorchANI library. The client.py script is executed by NAMD at each energy/gradient step, which communicates with the server.py. NAMD writes the atomic coordinates to disk. The client.py script polls the server.py. The socket communication is performed through a file handle (/tmp/ani_socket). 

The transfer of data (i.e., coordinates from NAMD to TorchANI and energies/forces from TorchANI to NAMD) uses temporary files written to the file system. To reduce the rate of these file operations, we use a local RAM to store these files, although, in practice, this does not change the speed of the simulations significantly.

## Installation

1. Install [TorchANI](https://aiqm.github.io/torchani/).
2. Install [NAMD](http://www.ks.uiuc.edu/Research/namd/). Version 2.13 or later is required. The single-node version (e.g., Linux-x86\_64-multicore) is fine for this because the ANI calculations will be slower than the MM component, so MPI parallelization is not a significant advantage.
3. Install client.py and server.py scripts into an accessible location.

## Execution

An example SLURM submission script for a NAMD/MM simulation
<pre><code>
export RUNDIR=/dev/shm/$SLURM_JOB_ID/
mkdir $RUNDIR

module load nixpkgs/16.09  intel/2016.4
module load namd-multicore/2.13

module load python/3.7.0
python3 server.py >& server.$SLURM_JOBID.log&

sleep 10 # wait to make sure server has initialized first

namd2  +p4 namd_input.conf > namd_output
</pre></code>

The custom QM features of NAMD have to be activated in the NAMD configuration file:
<pre><code>
set rundir $env(RUNDIR)
qmforces on
qmParamPDB qmmm.pdb
qmSoftware custom
qmexecpath client.py
qmBaseDir  $rundir
QMColumn occ
qmChargeMode none
qmElecEmbed off
</pre></code>

The occupancy column of the qmmm.pdb specifies which atoms should be treated using the NNP.

## Examples

The examples directory of the GitHub repository contains the input files an NNP/MM simulation of erlotinib in liquid water, where erlotinib is represented using the NNP and the water molecules are calculated using the TIP3P MM model.

## Practical Notes
### Applicable Systems
The ANI-1x/ANI-1ccX model should not be used for compounds with charged functional groups. Only molecules comprised of C, N, O, and H atoms are supported by the ANI-1x/ANI-1ccX models.
### Periodic Boundary Conditions
The atoms in the NNP region must not cross the boundary of the simulation cell. The simplest way to do this is to translate the NNP system to the origin (0, 0, 0). Alternatively, the CellOrigin NAMD keyword can be used to place the center of the simulation cell at the center of mass of the NNP region. In each case, it is advisable to restrain the NNP atoms with a harmonic potential so that they do not diffuse across the boundary during the simulation.

<pre><code>
cellbasisvector1 39.4435539101   0.0  0.0
cellbasisvector2 0.0 38.2819366381 0.0
cellbasisvector3 0.0 0.0 38.9952104018
cellorigin 21.31 0.50 52.4
</pre></code>

## Citing
Researchers using *this* code should cite the following paper:

Lahey S.-L. J., Rowley, C. N., Simulating Protein-Ligand Binding with Neural Network Potentials, *Chem. Sci.*, **2020**, doi: [10.1039/C9SC06017K](https://doi.org/10.1039/C9SC06017K)

Researchers should also cite the papers describing the NNP used:
1. ANI-1ccX potential: Smith, J.S., Nebgen, B.T., Zubatyuk, R. et al. Approaching coupled cluster accuracy with a general-purpose neural network potential through transfer learning. *Nat. Commun.*  **2019**, 10, 2903 doi: [10.1038/s41467-019-10827-4](https://doi.org/10.1038/s41467-019-10827-4)
2. ANI-1 potential: J. S. Smith, O. Isayev, and A. E. Roitberg. ANI-1: an extensible neural net-
work potential with DFT accuracy at force field computational cost. *Chem. Sci.*, **2017**
8 (4), 3192–3203, doi: [10.1039/C6SC05720A](https://doi.org/10.1039/C6SC05720A)
3. Justin S. Smith, Adrian E. Roitberg, and Olexandr Isayev *ACS Medicinal Chemistry Letters* **2018** 9 (11), 1065-1069
doi: [10.1021/acsmedchemlett.8b00437](https://pubs.acs.org/doi/10.1021/acsmedchemlett.8b00437)

Researchers should also NAMD and the NAMD QM/MM interface the papers describing the NNP used:
1. J. C. Phillips, R. Braun, W. Wang, J. Gumbart, E. Tajkhorshid, E. Villa, C. Chipot, R. D. Skeel, L. Kalé and K. Schulten, *J. Comput. Chem.*, **2005**, 26, 1781–1802.
2. M. C. R. Melo, R. C. Bernardi, T. Rudack, M. Scheurer, C. Riplinger, J. C. Phillips, J. D. C. Maia, G. B. Rocha, J. V.
Ribeiro, J. E. Stone and et al., *Nat. Methods*, **2018**, 15, 351–354
<pre><code>
@Article{NNP_MM_2020,
author = "Lahey, Shae-Lynn J and Rowley, Christopher N.",
title  =" Simulating Protein-Ligand Binding with Neural Network Potentials",
journal = "Chem. Sci.",
year  = "2020",
pages  ="-",
publisher = "The Royal Society of Chemistry",
doi = "10.1039/C9SC06017K",
url = "http://dx.doi.org/10.1039/C9SC06017K",
}

@article {namd,
author = {Phillips, James C. and Braun, Rosemary and Wang, Wei and Gumbart, James and Tajkhorshid, Emad and Villa, Elizabeth and Chipot, Christophe 
and Skeel, Robert D. and Kal\'{e}, Laxmikant and Schulten, Klaus},
Title = {Scalable Molecular Dynamics with NAMD},
journal = {J. Comput. Chem.},
journal-iso = {J. Comput. Chem.},
volume = {26},
number = {16},
publisher = {Wiley Subscription Services, Inc., A Wiley Company},
issn = {1096-987X},
url = {http://dx.doi.org/10.1002/jcc.20289},
doi = {10.1002/jcc.20289},
pages = {1781--1802},
keywords = {biomolecular simulation, molecular dynamics, parallel computing},
year = {2005},
}

@article{Melo2018, 
title={NAMD goes quantum: an integrative suite for hybrid simulations},
volume={15},
ISSN={1548-7091}, 
number={5}, 
journal={Nat. Methods}, 
author={Melo, Marcelo C. R. and Bernardi, Rafael C. and Rudack, Till and Scheurer, Maximilian and Riplinger, Christoph and Phillips, James C. and Maia, Julio D. C. and Rocha, Gerd B. and Ribeiro, João V. and Stone, John E. and et al.},
year={2018}, pages={351–354} 
}

@article{Smith_Isayev_Roitberg_2017,
title={ANI-1: an extensible neural network potential with DFT accuracy at force field computational cost}, volume={8}, ISSN={2041-6520}, 
number={4},
journal={Chem. Sci.},
author={Smith, J. S. and Isayev, O. and Roitberg, A. E.},
year={2017},
pages={3192–3203} 
}

@article{Smith2019,
title={Approaching coupled cluster accuracy with a general-purpose neural network potential through transfer learning}, volume={10},
ISSN={2041-1723},
number={1},
journal={Nat. Comm.},
author={Smith, Justin S. and Nebgen, Benjamin T. and Zubatyuk, Roman and Lubbers, Nicholas and Devereux, Christian and Barros, Kipton and Tretiak, Sergei and Isayev, Olexandr and Roitberg, Adrian E.},
year={2019},
pages={2903} 
}
</pre></code>
