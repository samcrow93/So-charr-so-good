#!/bin/bash
#SBATCH --time=
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --mem=
#SBATCH --output=
#SBATCH --job-name=

# This script is to generate an mpileup file for each population, at sites for which ANGSD generated genotype likelihoods

# Get number of inds to generate min_ind variable (80% of inds in a given POP):
bamfile=/home/samcrow/scratch/charr/scripts/bamlists_noker_nodup/bams.$POP.txt
# Get total number of inds in pop:
n_inds=$(cat $bamfile | wc -l)
# Get 80% of total inds for min_ind flag:
min_ind=$(echo "$n_inds * 0.8" | bc)

cd /home/samcrow/scratch/charr/noker/angsd_outs/mpileup

echo "Beginning ngsParalog on pop $POP"

/home/samcrow/programs/ngsParalog/ngsParalog calcLR -infile /home/samcrow/scratch/charr/noker/angsd_outs/mpileup/$POP.mpileup -outfile \
/home/samcrow/scratch/charr/noker/angsd_outs/mpileup/ngsparalog_out/$POP.lr \
-minQ 30 -minind $min_ind -mincov 1

echo "Finished ngsParalog on pop $POP"
