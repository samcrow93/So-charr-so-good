#!/bin/bash
#SBATCH --time=
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --mem=1G
#SBATCH --output=slurm.%x.%j.out
#SBATCH --job-name=mpileup_pop103

module load StdEnv/2020 gcc/9.3.0
module load samtools

genome=/home/samcrow/genome/Arthur_CHR_polished.fasta
bamfile=/home/samcrow/scratch/charr_wgs/scripts/bams_103.txt

# Use this to generate an mpileup file to use in ngsparalog
# samtools mpileup is deprecated now, BUT ngsParalog requires samtools format mpileup file as input :/
# Only consider sites for which ANGSD calculated genotype likelihoods already


# bamlist is samples that pass the low-depth cutoff (i.e. have already removed very low-depth samples from this list)
# Mapping/read quality is not parameterized for samtools mpileup because ngsParalog needs to see all the reads regardless of quality as per documentation
cd /home/samcrow/scratch/charr_wgs/realigned_bams

echo "Running mpileup on pop 103"

samtools mpileup -f $genome -b $bamfile -q 0 -Q 0 -l /home/samcrow/scratch/charr_wgs/redo_angsd/angsd_filt_outs/sites/allsites.txt > /home/samcrow/scratch/charr_wgs/mpileup/pop103.mpileup

echo "Finished mpileup on pop 103"
