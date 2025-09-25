#!/bin/bash
#SBATCH --time=12:00:00
#SBATCH --account=def-ibradbur
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samantha.crowley@dal.ca
#SBATCH --ntasks=32
#SBATCH --cpus-per-task=1
#SBATCH --job-name=get_depthcoverage_from_bams

cd /home/samcrow/scratch/charr_wgs/align

module load StdEnv/2023 gcc/12.3 samtools/1.20

cat /home/samcrow/scratch/charr_wgs/all_charr/scripts/bamlist.tsv | parallel -j 32 'samtools coverage {} -o depth_files/{}.txt'
