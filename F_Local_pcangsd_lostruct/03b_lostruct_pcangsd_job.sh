#!/bin/bash
#SBATCH --time=1:00:00
#SBATCH --account=def-ibradbur
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samantha.crowley@dal.ca
#SBATCH --mem=12G
#SBATCH --job-name=lostruct_pcangsd_job

cd /home/samcrow/scratch/charr/noker/angsd_outs/windows/$chrom/win_pcangsd/

module purge
module load gcc/12.3 r/4.5.0
export R_LIBS=~/.local/R/$EBVERSIONR/

Rscript /home/samcrow/scratch/charr/scripts/lostruct_winpcangsd.R "$chrom"
