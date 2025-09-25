#!/bin/bash
#SBATCH --time=
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --mem-per-cpu=
#SBATCH --cpus-per-task=
#SBATCH --job-name=angsd_chromos

#load variables
source $paramfile
source $angsdparam

cd $projdir/align

module load StdEnv/2023 angsd/0.940


angsd \
  -nThreads 8 \
  -bam $bamfile \
  -out $projdir/align/nuc_angsd_out/$runname.$chromsnuc \
  -dobcf 1 \
  -gl 1 \
  -dopost 1 \
  -doGlf 2 \
  -domajorminor 1 \
  -domaf 1 \
  -docounts 1 \
  -dumpCounts 2 \
  -doQsDist 1 \
  -minMapQ 20 \
  -minQ 20 \
  -minInd $minInd \
  -SNP_pval 2e-6 \
  -uniqueOnly 1 \
  -minMaf 0.05 \
  -setMinDepth $minDepth \
  -r $chromsnuc \
  -remove_bads 1 \
  -only_proper_pairs 1
