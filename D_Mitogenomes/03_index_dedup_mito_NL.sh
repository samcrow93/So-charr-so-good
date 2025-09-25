#!/bin/bash
#SBATCH --time=6:00:00
#SBATCH --account=def-ibradbur
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samantha.crowley@dal.ca
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --out=slurm.%x.%j.out
#SBATCH --job-name=index_dedup_charr_mito_NL

cd /home/samcrow/scratch/charr_wgs/

module load samtools

export projdir=/home/samcrow/scratch/charr_wgs

cat $projdir/scripts/mt_align_sets/NL_dedup_index/$set | \
   parallel --jobs 32  'samtools index $projdir/mitogenomes/aligned_swedish/{}.mito_swedish_deDup.bam '
