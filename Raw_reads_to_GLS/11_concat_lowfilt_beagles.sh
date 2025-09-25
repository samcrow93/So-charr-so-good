#!/bin/bash
#SBATCH --time=1:00:00
#SBATCH --account=def-ibradbur
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samantha.crowley@dal.ca
#SBATCH --mem=1G
#SBATCH --output=slurm.%x.%j.out
#SBATCH --job-name=concat_charr_lowfilt

cd /home/samcrow/scratch/charr_wgs/redo_angsd/angsd_filt_outs/lowfilts/

# Add header to new concatenated file from chrom 1 file:
zcat lowfilt.sal01.beagle.gz | head -n 1 | gzip > charr_concat_lowfilt.beagle.gz

# Next, loop through chromosome beagle files and add to concatenated file, without their headers:
for file in lowfilt*beagle.gz
do
echo "Concatenating $file"
zcat $file | tail -n +2 | gzip >> charr_concat_lowfilt.beagle.gz
done
