#!/bin/bash
#SBATCH --time=72:00:00
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --mem=500G
#SBATCH --job-name=pcangsd_charr_concat

module load StdEnv/2020 python/3.10.2
module load scipy-stack/2023b
source /home/samcrow/python_env/bin/activate

cd /home/samcrow/programs/pcangsd

pcangsd \
  --beagle /home/samcrow/scratch/charr/angsd_filtered/lowfilts/lowfilt_charr_concat.beagle.gz \
  --threads 5 --iter=500 \
  -o /home/samcrow/scratch/charr/angsd_filtered/lowfilts/pcangsd/concat_charr.pcangsd.out \
  --sites_save \
  --snp_weights

deactivate
