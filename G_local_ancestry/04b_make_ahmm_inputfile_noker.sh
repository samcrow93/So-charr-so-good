#!/bin/bash
#SBATCH --time=0:10:00
#SBATCH --account=def-ibradbur
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samantha.crowley@dal.ca
#SBATCH --job-name=make_ahmm_inputfile_noker

cd /home/samcrow/scratch/charr/ahmm/noker/

module load r/4.4.0

Rscript /home/samcrow/scratch/charr/scripts/make_ahmm_inputfile_noker.R "$POP" "$WIN" "$AF"
