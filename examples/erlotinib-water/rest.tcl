colvarsTrajFrequency 500

colvar {
    name solute1
    distance {
        group1 { atomnumbersrange  1-52  }
        group2 {
            dummyAtom ( 3.41, -21.8, 23.9 )
        }
    }
}

harmonic {
    name soluterest1
    colvars  solute1
    centers 0.0
    forceConstant { 1 }
}

