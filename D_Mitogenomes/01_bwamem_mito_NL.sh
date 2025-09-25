#!/bin/bash
#SBATCH --time=36:00:00
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --mem=40G
#SBATCH --output=slurm.%x.%j.out
#SBATCH --job-name=charr_mito_align_NL


## Load software modules
module load StdEnv/2023 gcc/12.3 samtools/1.20
module load bwa-mem2/2.2.1

#change directory and align all reads for our samples:
cd /home/samcrow/scratch/charr_wgs/mitogenomes/trimmed_NL

genome=/home/samcrow/scratch/charr_wgs/mitogenomes/refs/swedish_ref_mito.fasta
refname="swedish"

while read file;
  do echo $file\.bam;
  RGID=$(echo $file);
  SMID=$(echo $file | sed 's/NS.*i5.//');
  LBID=$(echo $file | sed 's/.UDP.*//');
  bwa-mem2 mem \
  -t 10 \
  -R "@RG\tID:$RGID\tSM:$SMID\tLB:$LBID" \
  $genome \
  $file\_R1.trimmed.fastq.gz  $file\_R2.trimmed.fastq.gz\
  | samtools sort -o /home/samcrow/scratch/charr_wgs/mitogenomes/aligned_"$refname"/$file\_mito_"$refname".sorted.bam \
  -T $file -@ 10 -m 3G ;
  echo "Done aligning $file";
  done < /home/samcrow/scratch/charr_wgs/scripts/mt_align_sets/NL_sets/even_longer/$set
