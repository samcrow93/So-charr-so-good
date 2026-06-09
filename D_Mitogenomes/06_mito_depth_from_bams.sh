#!/bin/bash
#SBATCH --time=12:00:00
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --out=slurm.%x.%j.out
#SBATCH --job-name=depthcoverage_from_bams_mito

cd /home/samcrow/scratch/charr_wgs/mitogenomes/aligned_acad

module load StdEnv/2023 samtools/1.18

ls *realigned.bam > bams

cat bams | parallel -j 16 'samtools coverage {} -o ./depth_files/{}.txt'

