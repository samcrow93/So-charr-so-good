#!/bin/bash
#SBATCH --time=4:00:00
#SBATCH --account=def-ibradbur
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samantha.crowley@dal.ca
#SBATCH --mem=30G
#SBATCH --output=slurm.%x.%j.out
#SBATCH --job-name=pcangsd_charr_lowfilt_chroms

module load StdEnv/2020 python/3.10.2
module load scipy-stack/2023b
source /home/samcrow/python_env/bin/activate

cd /home/samcrow/programs/pcangsd

pcangsd \
  --beagle /home/samcrow/scratch/charr/angsd_filtered/lowfilts/lowfilt.$chrom.beagle.gz \
  --threads 5 --iter=500 \
  -o /home/samcrow/scratch/charr/angsd_filtered/lowfilts/pcangsd/$chrom.pcangsd.out \
  --sites_save \
  --snp_weights

deactivate
