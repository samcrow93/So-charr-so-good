#!/bin/bash
#SBATCH --time=12:00:00
#SBATCH --account=def-ibradbur
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=samantha.crowley@dal.ca
#SBATCH --ntasks=32
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=10G
#SBATCH --job-name=mark_duplicates_charr_NL

cd /home/samcrow/scratch/charr_wgs/all_charr/
source $paramfile

module load StdEnv/2023 gatk/4.4.0.0

#export variables to keep parallel happy
export gatk
export projdir

#deduplicate in parallel
cat $projdir/sets/NL_sets_extralong/$set | \
  parallel --tmpdir $projdir/gatktemp \
  --jobs 32 \
  'gatk  --java-options "-Xmx5G" \
  MarkDuplicates \
  I=$projdir/align/{}.sorted.bam \
  O=$projdir/align/{}.deDup.bam M=$projdir/align/{}_deDupMetrics.txt \
  REMOVE_DUPLICATES=true \
  TMP_DIR=$projdir/gatktemp '
