#!/bin/bash
#SBATCH --time=
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --mem=
#SBATCH --job-name=

cd /home/samcrow/scratch/charr/noker/angsd_outs/windows/$chrom/win_pcangsd/

module purge
module load gcc/12.3 r/4.5.0
export R_LIBS=~/.local/R/$EBVERSIONR/

Rscript /home/samcrow/scratch/charr/scripts/lostruct_winpcangsd.R "$chrom"
