#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --account=def-ibradbur
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=samantha.crowley@dal.ca
#SBATCH --mem=1G
#SBATCH --output=slurm.%x.%j.out
#SBATCH --job-name=mpileup_noker_nodup

module load StdEnv/2020 gcc/9.3.0
module load samtools

genome=/home/samcrow/scratch/charr/genome/Arthur_CHR_polished.fasta
bamfile=/home/samcrow/scratch/charr/scripts/bamlists_noker_nodup/bams.$POP.txt

# Use this to generate an mpileup file to use in ngsparalog
# samtools mpileup is deprecated now, BUT ngsParalog requires samtools format mpileup file as input :/
# Only consider sites for which ANGSD calculated genotype likelihoods already
# This particular iteration is to generate mpileup files for SNP lists generated from the no Ker, no dup, no neg, no lowdepth samples (n=1827)
# This is for the 13278563 sites with genotype likelihoods as generated through ANGSD

# Mapping/read quality is not parameterized for samtools mpileup because ngsParalog needs to see all the reads regardless of quality as per documen>
cd /home/samcrow/projects/def-ibradbur/samcrow/realigned_bams/

echo "Running mpileup on pop $POP"

basedir=/home/samcrow/scratch/charr/noker/angsd_outs

samtools mpileup -f $genome -b $bamfile \
 -q 0 -Q 0 -l $basedir/concat_noker_sites.txt > $basedir/mpileup/$POP.long.mpileup

echo "Finished mpileup on pop $POP"
