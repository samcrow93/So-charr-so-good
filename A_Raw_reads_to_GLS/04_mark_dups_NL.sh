#!/bin/bash
#SBATCH --time=
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --ntasks=
#SBATCH --cpus-per-task=
#SBATCH --mem-per-cpu=
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
