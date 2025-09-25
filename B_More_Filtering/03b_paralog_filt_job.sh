#!/bin/bash
#SBATCH --time=6:00:00
#SBATCH --account=def-ibradbur
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samantha.crowley@dal.ca
#SBATCH --mem=50G
#SBATCH --job-name=paralog_filt

cd /home/samcrow/scratch/charr_wgs/mpileup/ngsparalog_out

module load StdEnv/2023 r/4.4.0

Rscript /home/samcrow/scratch/charr_wgs/scripts/mpileup_scripts/paralog_filt.R
