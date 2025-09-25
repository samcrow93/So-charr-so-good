#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --account=def-ibradbur
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samantha.crowley@dal.ca
#SBATCH --mem=0
#SBATCH --cpus-per-task=32
#SBATCH --nodes=1
#SBATCH --job-name=charr_fastp


# If running job from scripts/ directory:

source ../charr_WGS_params.txt

cd $projdir

#export to make parallel happy
export fastp
export projdir

ls *_R1.fastq.gz | sed 's/\_R1.fastq.gz//' | sort | uniq > samples

#run in parallel
cat $projdir/samples | \
  parallel -j 8 \
  '$fastp -i {}_R1.fastq.gz \
  -I {}_R2.fastq.gz \
  -o $projdir/trim/{}_R1.trimmed.fastq.gz \
  -O $projdir/trim/{}_R2.trimmed.fastq.gz \
  --thread 4 '
