#!/bin/bash
#SBATCH --time=24:00:00
#SBATCH --account=def-ibradbur
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samantha.crowley@dal.ca
#SBATCH --mem=5G
#SBATCH --out=slurm.%x.%j.out
#SBATCH --job-name=clustal_charr

cd /home/samcrow/scratch/charr/mitogenomes/aligned_acad

module load StdEnv/2020 gcc/9.3.0 clustal-omega/1.2.4

#clustalo --infile=combined.fasta --out=charr_multiseqalign.fa

clustalo --infile=combined_acadref_withfontandacad.fasta --out=combo_acadref_withfontandacad_multiseqalign.fa
