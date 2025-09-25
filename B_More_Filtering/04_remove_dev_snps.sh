#!/bin/bash
#SBATCH --time=1:00:00
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --mem=1G
#SBATCH --output=slurm.%x.%j.out
#SBATCH --job-name=remove_dev_snps_beagle

cd /home/samcrow/scratch/charr_wgs/redo_angsd/angsd_filt_outs/lowfilts
goodsites=/home/samcrow/scratch/charr_wgs/mpileup/ngsparalog_out/goodsites/$chrom.goodsites.txt

echo "Filtering beagle file for deviant SNPs (chromosome $chrom)"
# Filter to keep only good sites (non-deviant):
zcat lowfilt.$chrom.beagle.gz | grep -f $goodsites -Fw | gzip > parafilts/$chrom.para_filt.beagle.gz

echo "Finished filtering beagle file"











