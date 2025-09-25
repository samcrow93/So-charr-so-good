#!/bin/bash
#SBATCH --time=
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --ntasks=
#SBATCH --cpus-per-task=
#SBATCH --job-name=get_depthcoverage_from_bams

cd /home/samcrow/scratch/charr_wgs/align

module load StdEnv/2023 gcc/12.3 samtools/1.20

cat /home/samcrow/scratch/charr_wgs/all_charr/scripts/bamlist.tsv | parallel -j 32 'samtools coverage {} -o depth_files/{}.txt'
