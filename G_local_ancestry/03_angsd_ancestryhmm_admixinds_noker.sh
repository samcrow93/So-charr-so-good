#!/bin/bash
#SBATCH --time=
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --mem=
#SBATCH --out=
#SBATCH --job-name=angsd_ancestryhmm_admixinds_noker

# This script is to generate read counts of major and minor alleles for admixed individuals to be used in ancestry_hmm runs
# Polarize against the reference genome, just as in when determining AIMs using ref pops
# NOTE: this means that data generated from these runs is NOT comparable to original run with all data (since major minor were inferred from frequencies there)
# $win is the variable for window size to which AIMs were pruned (i.e. 100kb or 50kb)
# This is for the ref panel and dataset made with the no-Ker, no dup, no lowdepth, no neg dataset

cd /home/samcrow/projects/def-ibradbur/samcrow/realigned_bams

bamfile=/home/samcrow/scratch/charr/scripts/bamlists_noker_nodup/$bamlist
REF=/home/samcrow/scratch/charr/genome/Arthur_CHR_polished.fasta
sites=/home/samcrow/scratch/charr/ahmm/noker/refs/sites/aims_sites/$win/$chrom.aims.$win.sites

module load StdEnv/2023 angsd/0.940

echo "Running angsd to generate allele counts for pop $pop on $chrom, for $win AIM sites"
angsd \
  -nThreads 8 \
  -bam $bamfile -ref $REF \
  -out /home/samcrow/scratch/charr/ahmm/noker/samples/$pop/ahmm.$pop.$chrom.$win.samples \
  -docounts 1 -dumpCounts 4 \
  -minMapQ 30 -minQ 30 \
  -uniqueOnly 1 \
  -remove_bads 1 \
  -only_proper_pairs 1 \
  -r $chrom \
  -sites $sites
