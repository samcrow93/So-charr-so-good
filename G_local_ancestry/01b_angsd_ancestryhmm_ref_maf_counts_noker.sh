#!/bin/bash
#SBATCH --time=
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --mem=
#SBATCH --out=
#SBATCH --job-name=angsd_ancestryhmm_ref_maf_counts_noker

# This script is to generate allele counts for 50 individuals comprising two main groups (putatively Arctic and Atlantic, respectively) used for Fst
# These will be used to make reference panels of Ancestry Informative Markers (AIMs) for input to Ancestry_HMM
# GROUP is group1 (Arctic) or group2 (Atlantic)
# Do not use maf filter here
# This script (part B) picks up after part A, where sites that were variant across both groups were identified
# This script now serves to calculate allele counts and mafs at these sites for each group separately

module load angsd/0.940

bamfile2=/home/samcrow/scratch/charr/Fst/noker/sample_lists/k3_top50_"$GROUP"_forFst.txt
REF=/home/samcrow/scratch/charr/genome/Arthur_CHR_polished.fasta
sites2=/home/samcrow/scratch/charr/ahmm/noker/refs/sites/$chrom.bothrefs.sites.txt

# To start off, need to generate list of sites that make up sites2 variable (i.e. those identified as variant across both groups in part A):
# Cut first two columns and remove header from maf files to generate sites files for each chrom:
cd /home/samcrow/scratch/charr/ahmm_noker/refs/
for chrom in sal01 sal02 sal03 sal04 sal05 sal06 sal07 sal08 sal09 sal10 sal11 sal12 sal13 sal14 sal15 sal16 sal17 sal18 sal19 sal20 \
sal21 sal22 sal23 sal24 sal25 sal26 sal27 sal28 sal29 sal30 sal31 sal32 sal33 sal34 sal35 sal36 sal37 sal38 sal39
do
zcat $chrom.bothrefs.mafs.gz | tail -n +2 | cut -f1,2 > sites/$chrom.bothrefs.sites.txt;
done
# Use ANGSD to index these sites files:
for chrom in sal01 sal02 sal03 sal04 sal05 sal06 sal07 sal08 sal09 sal10 sal11 sal12 sal13 sal14 sal15 sal16 sal17 sal18 sal19 sal20 \
sal21 sal22 sal23 sal24 sal25 sal26 sal27 sal28 sal29 sal30 sal31 sal32 sal33 sal34 sal35 sal36 sal37 sal38 sal39
do
angsd sites index sites/$chrom.bothrefs.sites.txt;
done

# Now ready to run angsd separately on both groups to generate counts and mafs:

cd /home/samcrow/projects/def-ibradbur/samcrow/realigned_bams

angsd \
  -nThreads 8 \
  -bam $bamfile2 -ref $REF \
  -out /home/samcrow/scratch/charr/ahmm/noker/refs/$chrom.$GROUP.AIMref \
  -gl 1 -domajorminor 4 -domaf 1 \
  -docounts 1 -dumpCounts 3 \
  -minMapQ 30 -minQ 30 \
  -minInd 40 \
  -setMinDepth 100 \
  -uniqueOnly 1 \
  -remove_bads 1 \
  -only_proper_pairs 1 \
  -r $chrom \
  -sites $sites2
