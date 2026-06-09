#!/bin/bash
#SBATCH --time=
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --mem=
#SBATCH --out=
#SBATCH --job-name=winsfs_k3_angsd_noker


cd /home/samcrow/scratch/charr/Fst/noker/k3/saf

# The -vv flag specifies verbose (instead of running in quiet mode)

echo "Target group is $TARGET and ref group is $GROUP for SFS on $chrom for K=3"
/home/samcrow/.cargo/bin/winsfs ./$chrom.$GROUP.saf.idx ./$chrom.$TARGET.saf.idx -vv -t 12 > SFS/winsfs.$chrom.$GROUP.$TARGET.sfs
