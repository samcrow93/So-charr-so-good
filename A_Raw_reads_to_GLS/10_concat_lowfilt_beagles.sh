#!/bin/bash
#SBATCH --time=
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --mem=
#SBATCH --output=
#SBATCH --job-name=concat_charr_lowfilt

cd /home/samcrow/scratch/charr_wgs/redo_angsd/angsd_filt_outs/lowfilts/

# Add header to new concatenated file from chrom 1 file:
zcat lowfilt.sal01.beagle.gz | head -n 1 | gzip > lowfilt_charr_concat.beagle.gz

# Next, loop through chromosome beagle files and add to concatenated file, without their headers:
for file in lowfilt*beagle.gz
do
echo "Concatenating $file"
zcat $file | tail -n +2 | gzip >> lowfilt_charr_concat.beagle.gz
done
