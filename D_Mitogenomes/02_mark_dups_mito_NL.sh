#!/bin/bash
#SBATCH --time=6:00:00
#SBATCH --account=def-ibradbur
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=samantha.crowley@dal.ca
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=3G
#SBATCH --output=slurm.%x.%j.out
#SBATCH --job-name=markdups_NL_mito

cd /home/samcrow/scratch/charr_wgs/mitogenomes/aligned_swedish

export projdir=/home/samcrow/scratch/charr_wgs

module load StdEnv/2023 gatk/4.4.0.0

#deduplicate in parallel
cat $projdir/scripts/mt_align_sets/NL_dedup_index/$set | parallel --tmpdir $projdir/mitogenomes/gatktemp --jobs 10 'gatk  --java-options "-Xmx5G" MarkDuplicates I=$projdir/mitogenomes/aligned_swedish/{}_mito_swedish.sorted.bam O=$projdir/mitogenomes/aligned_swedish/{}.mito_swedish_deDup.bam M=$projdir/mitogenomes/aligned_swedish/{}.mito_swedish_deDupMetrics.txt REMOVE_DUPLICATES=true TMP_DIR=$projdir/mitogenomes/gatktemp'
