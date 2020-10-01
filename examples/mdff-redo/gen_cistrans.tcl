package require cispeptide.
package require chirality

mol new 4hjo-implicit.psf
mol addfile 4hjo-implicit.pdb
cispeptide restrain -o extrabonds-cispeptide.txt
chirality restrain -o extrabonds-chirality.txt
