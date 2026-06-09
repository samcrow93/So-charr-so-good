#!/bin/bash
#SBATCH --time=6:00:00
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --out=slurm.%x.%j.out
#SBATCH --job-name=index_dedup_charr_mito_NL

cd /home/samcrow/scratch/charr_wgs/

module load samtools

export projdir=/home/samcrow/scratch/charr_wgs

cat $projdir/scripts/mt_align_sets/NL_dedup_index/$set | \
   parallel --jobs 32  'samtools index $projdir/mitogenomes/aligned_acad/{}.mito_acad_deDup.bam '
