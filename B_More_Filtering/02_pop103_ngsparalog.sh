#!/bin/bash
#SBATCH --time=30:00:00
#SBATCH --account=def-ibradbur
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samantha.crowley@dal.ca
#SBATCH --mem=1G
#SBATCH --output=slurm.%x.%j.out
#SBATCH --job-name=pop103_ngsparalog


cd /home/samcrow/scratch/charr_wgs/mpileup/

echo "Beginning ngsParalog on pop103"

/home/samcrow/programs/ngsParalog/ngsParalog calcLR -infile /home/samcrow/scratch/charr_wgs/mpileup/pop103.mpileup -outfile \
/home/samcrow/scratch/charr_wgs/mpileup/ngsparalog_out/pop103.lr \
-minQ 30 -minind 18 -mincov 1
# Total number of individuals is 20, use 90% (n=18) for minind

echo "Finished ngsParalog on pop103"
