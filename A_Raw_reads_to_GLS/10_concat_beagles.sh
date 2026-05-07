#!/bin/bash
#SBATCH --time=
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --mem=
#SBATCH --output=
#SBATCH --job-name=concat_charr

cd /path_to_beagles/

# Add header to new concatenated file from chrom 1 file:
zcat sal01.beagle.gz | head -n 1 | gzip > charr_concat.beagle.gz

# Next, loop through chromosome beagle files and add to concatenated file, without their headers:
for file in sal*beagle.gz
do
echo "Concatenating $file"
zcat $file | tail -n +2 | gzip >> charr_concat.beagle.gz
done
