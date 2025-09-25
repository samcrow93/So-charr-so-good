#!/bin/bash
#SBATCH --time=36:00:00
#SBATCH --account=def-ibradbur
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=samantha.crowley@dal.ca
#SBATCH --mem=0
#SBATCH --cpus-per-task=32
#SBATCH --job-name=charr_NL_bwamem_align

# This script will align reads from 1407 samplesto the charr genome

cd /home/samcrow/scratch/charr_wgs/all_charr
#load variables
source $paramfile

## Load software modules
module load StdEnv/2023 gcc/12.3 samtools/1.20
module load bwa-mem2/2.2.1

#change directory and align all reads
cd $projdir/trim

while read outfile;
  do echo $outfile\.bam;
  RGID=$(echo $outfile);
  SMID=$(echo $outfile | sed 's/NS.*i5.//');
  LBID=$(echo $outfile | sed 's/.UDP.*//');
  bwa-mem2 mem \
  -t 32 \
  -R "@RG\tID:$RGID\tSM:$SMID\tLB:$LBID" \
  $genome \
  $outfile\_R1.trimmed.fastq.gz  $outfile\_R2.trimmed.fastq.gz\
  | samtools sort -o $projdir/align/$outfile\_QUICKER.sorted.bam -T $outfile -@ 32 -m 3G ;
  done < $projdir/sets/NL_sets_extralong/$set
