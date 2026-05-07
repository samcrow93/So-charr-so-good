#!/bin/bash
#SBATCH --time=
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --mem=
#SBATCH --out=
#SBATCH --job-name=

# This script is to run ANGSD and generate genotype likelihoods for 1827 samples
# This excludes Kerguelen samples (n=47), the < 0.5X depth samples (n=24), and duplicated samples (n=8)
# minInd is 80% of individuals
# setMinDepth is 2x number of individuals

cd /home/samcrow/projects/def-ibradbur/samcrow/realigned_bams

bamfile=/home/samcrow/scratch/charr/scripts/bamlist.lowfilt.noker.nodup.txt
outdir=/home/samcrow/scratch/charr/noker/angsd_outs

module load StdEnv/2023 angsd/0.940

echo "Running ANGSD on chrom $chrom"
angsd \
  -bam $bamfile \
  -out $outdir/$chrom.220.long \
  -gl 1 \
  -doGlf 2 \
  -domajorminor 1 \
  -domaf 1 \
  -docounts 1 \
  -minMapQ 20 \
  -minQ 20 \
  -minInd 1462 \
  -SNP_pval 2e-6 \
  -uniqueOnly 1 \
  -minMaf 0.05 \
  -setMinDepth 3654 \
  -r $chrom \
  -remove_bads 1 \
  -only_proper_pairs 1
