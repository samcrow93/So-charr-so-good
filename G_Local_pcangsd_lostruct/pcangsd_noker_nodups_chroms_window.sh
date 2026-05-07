#!/bin/bash
#SBATCH --time=24:00:00
#SBATCH --account=def-ibradbur
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=samantha.crowley@dal.ca
#SBATCH --mem=5G
#SBATCH --output=slurm.%x.%j.out
#SBATCH --job-name=pcangsd_chroms_window

module load StdEnv/2020 python/3.10.2
module load scipy-stack/2023b
source /home/samcrow/python_env/bin/activate

cd /home/samcrow/scratch/charr/noker/angsd_outs/windows/$chrom

# Generate window file to pass to parallel:
ls $chrom.win*.beagle.gz | sed "s/^${chrom}\.win\.//; s/\.beagle.gz$//" > windows

cd /home/samcrow/programs/pcangsd

echo "Running windowed PCAs on chrom $chrom"
# Bump up iterations to 1000 to try and make sure each window converges (still need to check)
cat /home/samcrow/scratch/charr/noker/angsd_outs/windows/$chrom/windows | parallel -j 30 'pcangsd --beagle /home/samcrow/scratch/charr/noker/angsd_outs/windows/$chrom/$chrom.win.{}.beagle.gz --threads 5 --iter=1000 -o /home/samcrow/scratch/charr/noker/angsd_outs/windows/$chrom/win_pcangsd/$chrom.win.{} --sites_save --snp_weights'

deactivate



