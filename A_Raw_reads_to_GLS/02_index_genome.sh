#!/bin/bash
#SBATCH --time=
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --mem=
#SBATCH --cpus-per-task=
#SBATCH --nodes=
#SBATCH --job-name=charr_index_genome

#change directory and align all reads
cd /home/samcrow/genome

# Load software modules
module load StdEnv/2023 gcc/12.3 samtools/1.20
module load bwa-mem2/2.2.1

bwa-mem2 index Arthur_CHR_polished.fasta
samtools faidx Arthur_CHR_polished.fasta
