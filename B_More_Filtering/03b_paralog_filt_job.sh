#!/bin/bash
#SBATCH --time=
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --mem=
#SBATCH --job-name=

cd /home/samcrow/scratch/charr_wgs/mpileup/ngsparalog_out

module load StdEnv/2023 r/4.4.0

Rscript /home/samcrow/scratch/charr_wgs/scripts/mpileup_scripts/paralog_filt.R
