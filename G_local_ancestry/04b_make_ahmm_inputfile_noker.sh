#!/bin/bash
#SBATCH --time=
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --job-name=make_ahmm_inputfile_noker

cd /home/samcrow/scratch/charr/ahmm/noker/

module load r/4.4.0

Rscript /home/samcrow/scratch/charr/scripts/make_ahmm_inputfile_noker.R "$POP" "$WIN" "$AF"
