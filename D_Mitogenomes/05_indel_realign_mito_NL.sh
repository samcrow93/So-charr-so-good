#!/bin/bash
#SBATCH --time=10:00:00
#SBATCH --account=def-ibradbur
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=samantha.crowley@dal.ca
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=4G
#SBATCH --out=slurm.%x.%j.out
#SBATCH --job-name=indel_realign_charr_mt_NL

#load packages
module load nixpkgs/16.09 gatk/3.7

export projdir=/home/samcrow/scratch/charr_wgs
export genome=/home/samcrow/scratch/charr_wgs/mitogenomes/refs/swedish_ref_mito.fasta

cat $projdir/scripts/mt_align_sets/NL_dedup_index/$set | \
   parallel --tmpdir $projdir/mitogenomes/gatktemp --jobs 10 'java -Xmx5g -Djava.io.tmpdir=$projdir/mitogenomes/gatktemp -jar $EBROOTGATK/GenomeAnalysisTK.jar -T IndelRealigner -R $genome -I $projdir/mitogenomes/aligned_swedish/{}.mito_swedish_deDup.bam -targetIntervals $projdir/mitogenomes/aligned_swedish/{}.mito_swedish.intervals -o $projdir/mitogenomes/aligned_swedish/{}.mito_swedish_realigned.bam '
