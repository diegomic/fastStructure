import numpy as np
cimport numpy as np
import sys

def load(file):
    handle = open(file+'.str','r')
    tl = []
    for line in handle:
        print(line.strip().split()[6:])
        tl.append(line.strip().split()[6:])
        sys.getsizeof(tl)
    loci = np.array([line.strip().split()[6:] for line in handle])
    handle.close()
    N = loci.shape[0]/2
    L = loci.shape[1]

    genotype = np.zeros((N,L),dtype=np.uint8)

    for l,locus in enumerate(loci.T):
        alleles = list(np.unique(locus))

        # assumes that missing alleles are coded as -9
        if '-9' in alleles:
            print("Removing missing alleles...")
            alleles.remove('-9')

        # selecting major and minor alleles
        major = alleles[0]
        try:
            minor = alleles[1]
        except IndexError:
            minor = ''

        # maps structure represntation of genotypes to an unsigned integer
        genomap = { minor+minor : 2,
                    minor+major : 1,
                    major+minor : 1,
                    major+major : 0
                  }

        # convert genotypes to fastStructure representation
        for n in range(N):
            try:
                geno = genomap[''.join(locus[2*n:2*(n+1)])]
                genotype[n,l] = geno
            except KeyError:
                # missing values are coded by `3`.
                genotype[n,l] = 3

    return genotype
