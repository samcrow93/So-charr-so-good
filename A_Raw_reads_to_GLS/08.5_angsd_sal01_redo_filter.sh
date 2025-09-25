#!/bin/bash
#SBATCH --time=
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --mem=
#SBATCH --job-name=angsd_sal01_redo_filter

cd /home/samcrow/scratch/charr_wgs/align/realigned_bams/

bamfile=/home/samcrow/scratch/charr_wgs/all_charr/scripts/bamlist.tsv
sites=/home/samcrow/scratch/raw_beagles/other_angsd_outs/sites/sites01.list
chroms01=/home/samcrow/scratch/raw_beagles/other_angsd_outs/sites/chroms01.txt

module load StdEnv/2023 angsd/0.940


angsd \
  -nThreads 8 \
  -bam $bamfile \
  -out /home/samcrow/scratch/charr_wgs/align/angsd_filtered/sal01_filt \
  -dobcf 1 \
  -gl 1 \
  -dopost 1 \
  -doGlf 2 \
  -domajorminor 1 \
  -domaf 1 \
  -docounts 1 \
  -dumpCounts 2 \
  -doQsDist 1 \
  -minMapQ 20 \
  -minQ 20 \
  -minInd 1540 \
  -SNP_pval 2e-6 \
  -uniqueOnly 1 \
  -minMaf 0.05 \
  -setMinDepth 3850 \
  -rf $chroms01 \
  -sites $sites \
  -remove_bads 1 \
  -only_proper_pairs 1
