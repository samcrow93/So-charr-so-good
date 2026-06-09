#!/bin/bash
#SBATCH --time=6:00:00
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=3G
#SBATCH --output=slurm.%x.%j.out
#SBATCH --job-name=markdups_NL_mito

cd /home/samcrow/scratch/charr_wgs/mitogenomes/aligned_acad

export projdir=/home/samcrow/scratch/charr_wgs

module load StdEnv/2023 gatk/4.4.0.0

#deduplicate in parallel
cat $projdir/scripts/mt_align_sets/NL_dedup_index/$set | parallel --tmpdir $projdir/mitogenomes/gatktemp --jobs 10 'gatk  --java-options "-Xmx5G" MarkDuplicates I=$projdir/mitogenomes/aligned_acad/{}_mito_acad.sorted.bam O=$projdir/mitogenomes/aligned_acad/{}.mito_acad_deDup.bam M=$projdir/mitogenomes/aligned_acad/{}.mito_acad_deDupMetrics.txt REMOVE_DUPLICATES=true TMP_DIR=$projdir/mitogenomes/gatktemp'
