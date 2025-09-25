#!/bin/bash
#SBATCH --time=
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --ntasks=
#SBATCH --cpus-per-task=
#SBATCH --job-name=index_dedup_charr

cd /home/samcrow/scratch/charr_wgs/all_charr/
#load variables
source $paramfile

module load samtools

##export to keep parallel happy
export projdir

cat $projdir/sets/NL_sets_extralong/$set | \
   parallel --jobs 32  'samtools index $projdir/align/{}.deDup.bam '
