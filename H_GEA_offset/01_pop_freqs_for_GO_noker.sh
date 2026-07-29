#!/bin/bash
#SBATCH --time=2:00:00
#SBATCH --account=def-ibradbur
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=samantha.crowley@dal.ca
#SBATCH --mem=30G
#SBATCH --out=slurm.%x.%j.out
#SBATCH --job-name=pop_freqs_for_offset

# This script is to run ANGSD and generate allele frequencies for each population (at each time point) for variant sites across all pops
# i.e. paralog-pruned variant sites from the noker dataset on a per-chrom basis
# This excludes Kerguelen samples (n=47), the < 0.5X depth samples (n=24), and duplicated samples (n=8)
# minInd is 80% of individuals
# setMinDepth is 2x number of individuals

cd /home/samcrow/projects/def-ibradbur/samcrow/realigned_bams

bamfile=/home/samcrow/scratch/charr/scripts/bamlists_noker_nodup/bams.$pop.txt
# Use concatenated file of paralog-pruned sites for which GLs were calculated:
sites=/home/samcrow/scratch/charr/noker/angsd_outs/mpileup/ngsparalog_out/goodsites/goodsites_ahmm/$chrom.goodsites.ahmm.txt
outdir=/home/samcrow/scratch/charr/offset/pop_freqs
# Get total number of inds in pop:
n_inds=$(cat $bamfile | wc -l)
# Get 80% of total inds for minInd flag:
min_ind=$(echo "$n_inds * 0.8" | bc)
# Get 2x total number of samples as minDepth:
minDepth=$(echo "$n_inds * 2" | bc)


module load StdEnv/2023 angsd/0.940

echo "Running ANGSD on chrom $chrom for pop $pop"
angsd \
  -nThreads 8 \
  -bam $bamfile \
  -ref /home/samcrow/scratch/charr/genome/Arthur_CHR_polished.fasta \
  -out $outdir/$pop.$chrom \
  -gl 1 \
  -domajorminor 4 \
  -domaf 1 \
  -minMapQ 30 \
  -minQ 30 \
  -minInd $min_ind \
  -doCounts 1 \
  -setMinDepth $minDepth \
  -uniqueOnly 1 \
  -r $chrom \
  -sites $sites \
  -remove_bads 1 \
  -only_proper_pairs 1
