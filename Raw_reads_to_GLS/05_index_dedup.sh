#!/bin/bash
#SBATCH --time=6:00:00
#SBATCH --account=def-ibradbur
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samantha.crowley@dal.ca
#SBATCH --ntasks=32
#SBATCH --cpus-per-task=1
#SBATCH --job-name=index_dedup_charr

cd /home/samcrow/scratch/charr_wgs/all_charr/
#load variables
source $paramfile

module load samtools

##export to keep parallel happy
export projdir

cat $projdir/sets/NL_sets_extralong/$set | \
   parallel --jobs 32  'samtools index $projdir/align/{}.deDup.bam '
