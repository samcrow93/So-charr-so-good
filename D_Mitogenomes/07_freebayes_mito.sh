#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --mem=35G
#SBATCH --out=slurm.%x.%j.out
#SBATCH --job-name=mito_freebayes_charr

module load StdEnv/2023 freebayes/1.3.7

cd /home/samcrow/scratch/charr_wgs/mitogenomes/aligned_swedish

bamfiles=/home/samcrow/scratch/charr_wgs/scripts/mt_inds_freebayes.txt

freebayes -f /home/samcrow/scratch/charr_wgs/mitogenomes/refs/swedish_ref_mito.fasta -L $bamfiles --ploidy 1 --min-alternate-count 3 \
 --min-base-quality 30 --min-mapping-quality 30 --vcf ./charr_mito_freebayes.vcf
