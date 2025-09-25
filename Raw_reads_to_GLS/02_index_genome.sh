#!/bin/bash
#SBATCH --time=12:00:00
#SBATCH --account=def-ibradbur
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samantha.crowley@dal.ca
#SBATCH --mem=0
#SBATCH --cpus-per-task=32
#SBATCH --nodes=1
#SBATCH --job-name=charr_index_genome

#change directory and align all reads
cd /home/samcrow/genome

# Load software modules
module load StdEnv/2023 gcc/12.3 samtools/1.20
module load bwa-mem2/2.2.1

bwa-mem2 index Arthur_CHR_polished.fasta
samtools faidx Arthur_CHR_polished.fasta
