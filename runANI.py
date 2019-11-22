#!/usr/bin/python3

import socket

from __future__ import print_function
#from ase.lattice.cubic import Diamond
from ase.md.langevin import Langevin
from ase.optimize import BFGS
from ase import units
from ase import Atoms
import torchani
import torch
from ase.io.trajectory import Trajectory
import ase.io

from sys import argv as sargv
from sys import exit 
from os.path import dirname
import subprocess as sp

HOST = '127.0.0.1'  # Standard loopback interface address (localhost)
PORT = 65432        # Port to listen on (non-privileged ports are > 1023)

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))
    s.listen()
    conn, addr = s.accept()
    with conn:
        print('Connected by', addr)
        while True:
            data = conn.recv(1024)
            if not data:
                break
            conn.sendall(data)

directory = dirname(inputFilename)

# Prepares the name of the point charge file based on full path to data file provided by NAMD
#%pointcharges "/dev/shm/NAMD_test/0/qmmm_0.input.pntchrg"
#pcFileName = orcaInFileName
#pcFileName += ".pntchrg"

#orcaConfigLines2 += pcFileName + "\"\n"


# Prepares the name of the output file based on full path to data file provided by NAMD.
# This is where we will direct all ORCA output, so that we can grab the atom charge
# information to pass back to NAMD.
aniOutFileName = inputFilename + '.TmpOutput'


# Prepares the name of the gradient file based on full path to data file provided by NAMD.
# This is where ORCA will write the gradient information on QM atoms.
aniGradFileName = inputFilename
aniGradFileName += ".engrad"

# Prepares the file name for the file which will be read by NAMD
finalResFileName = inputFilename
finalResFileName += ".result"

#print("orcaInFileName:",orcaInFileName)
#print("pcFileName:",pcFileName)
#print("orcaOutFileName:",orcaOutFileName)
#print("orcaGradFileName:",orcaGradFileName)
#print("finalResFileName:",finalResFileName)

################## Reading and parsing NAMD's data ; Writing ORCA's Input

# Reads NAMD data
infile = open(inputFilename,"r")

#headerLine=infile.readline()
line = infile.readline()

# Gets number of atoms in the Quantum Chemistry region (= QM atoms + Link atoms)
numQMatms = int(line.split()[0])
numMMatms=int(line.split()[1])

# Gets number of point charges
numPntChr = int(line.split()[1].replace("\n",""))

#print("numQMatms:",numQMatms,"; numPntChr",numPntChr)

# stores all lines written to ORCA's input file
outLinesQM = []

# stores all lines written to ORCA's point charge file
outLinesPC = []

# The first line in the point charge file is composed only of the total number
# of point charges in the file.
outLinesPC.append(str(numPntChr) + "\n")

# Identation
ident = "  "

lineIndx = 1
elements=[]
crd=[]
charges=[]

for line in infile:
    
    if lineIndx <= numQMatms:
        
        # ORCA's format requires the fileds to be ordered begining with the
        # atom's element symbol, and followed by the XYZ coordinates.
        fields=line.split()
        
        elements.append(fields[3])
        crd.append([float(fields[0]), float(fields[1]), float(fields[2])])
    else:
        
        # ORCA's format requires the fileds to be ordered begining with the
        # charge, and followed by the XYZ coordinates.
        charges.append(0)
#        charges.append(line.split()[3])
    
    lineIndx += 1
   

infile.close()

###
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
#print(crd)
coordinates = torch.tensor([crd], requires_grad=True, device=device).cuda()
coordinates=coordinates.to(device)

model=torchani.models.ANI1ccx()
model=model.to(device)
species = model.species_to_tensor("".join(elements)).to(device).unsqueeze(0)

def main():
    while True:
        sleep(1)

daemon = Daemonize(app="test_app", pid=pid, action=main, keep_fds=keep_fds)
daemon.start()

# Skips to the line with number of atoms
#for i in range(3):
#    gradFile.readline()

#aniNumQMAtms = int(gradFile.readline().replace("\n",""))


_, energy = model((species, coordinates))
derivative = torch.autograd.grad(energy.sum(), coordinates)[0]
force = derivative[0]


# XXX fix

qmCharges=[0.0]*len(elements)

# Writes the final output file that will be read by NAMD.

finFile = open(finalResFileName, "w")

# The first line contrains the energy
finFile.write(str(energy.item()*627.509469) + "\n")
d=derivative.squeeze()

# And all following lines contain gradients and partial charges
for i in range(numQMatms):
    finFile.write(str(-627.509469*d[i][0].item()) + " " + str(-627.509469*d[i][1].item())  + ' ' + str(str(-627.509469*d[i][2].item()) ) + " " + str(qmCharges[i]) + "\n")


#finFile.close()

#engradFile = open(aniGradFileName, "w")

#for i in range(numMMatms):
#    finFile.write("0.0 0.0 0.0\n")

#engradFile.close()
finFile.close()

exit(0)
