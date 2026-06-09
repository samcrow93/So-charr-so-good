#!/bin/bash
#SBATCH --time=
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --mem=
#SBATCH --out=
#SBATCH --job-name=clustal_charr

cd /home/samcrow/scratch/charr/mitogenomes/aligned_acad

module load StdEnv/2020 gcc/9.3.0 clustal-omega/1.2.4

clustalo --infile=combined_acadref_withfontandacad.fasta --out=combo_acadref_withfontandacad_multiseqalign.fa
