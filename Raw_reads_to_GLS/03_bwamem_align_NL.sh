#!/bin/bash
#SBATCH --time=
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --mem=
#SBATCH --cpus-per-task=
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
