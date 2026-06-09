#!/bin/bash
#SBATCH --time=
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --mem=
#SBATCH --out=
#SBATCH --job-name=angsd_ancestryhmm_ref_maf_counts_noker

# This script is to generate allele counts for 50 individuals comprising two "pure" groups (putatively Arctic and Atlantic, respectively) used for Fst
# These will be used to make reference panels of Ancestry Informative Markers (AIMs) for input to Ancestry_HMM
# GROUP is group1 (Arctic) or group2 (Atlantic)
# Do not use maf filter here
# Start by finding variant sites across the two reference groups (this script; part A), THEN calculate group-specific allele frequencies (different script; part B)
# Run this using the list of paralog-pruned sites for which there are GLs as a starting point

module load angsd/0.940

cd /home/samcrow/projects/def-ibradbur/samcrow/realigned_bams

bamfile1=/home/samcrow/scratch/charr/Fst/noker/sample_lists/refsamples_ahmm_tog_noker.txt
REF=/home/samcrow/scratch/charr/genome/Arthur_CHR_polished.fasta
sites1=/home/samcrow/scratch/charr/noker/angsd_outs/mpileup/ngsparalog_out/goodsites/goodsites_ahmm/$chrom.goodsites.ahmm.txt

angsd \
  -nThreads 8 \
  -bam $bamfile1 -ref $REF \
  -out /home/samcrow/scratch/charr/ahmm/noker/refs/$chrom.bothrefs \
  -gl 1 -domajorminor 4 \
  -domaf 1 -docounts 1 \
  -minMapQ 30 -minQ 30 \
  -minInd 80 \
  -setMinDepth 200 \
  -uniqueOnly 1 \
  -remove_bads 1 \
  -only_proper_pairs 1 \
  -r $chrom \
  -sites $sites1
