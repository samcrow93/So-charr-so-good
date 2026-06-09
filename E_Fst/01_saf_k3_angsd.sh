#!/bin/bash
#SBATCH --time=8:00:00
#SBATCH --account=def-ibradbur
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=samantha.crowley@dal.ca
#SBATCH --mem=30G
#SBATCH --out=slurm.%j.%x.out
#SBATCH --job-name=saf_k3_angsd_noker

# Here, reference genome used as reference AND as ancestral
# Do not have info re: ancestral alleles, therefore polarize based on reference genome for all pops
# Use reference genome masked for paralogs (using no-Ker dataset)
REF=/home/samcrow/scratch/charr/genome/MASKED_charr_noker_ref.fasta

cd /home/samcrow/projects/def-ibradbur/samcrow/realigned_bams

module load StdEnv/2023 angsd/0.940

# Loop through each group:
for GROUP in group1 group2 group3
do
        echo "Calculating SAF for $GROUP for $chrom"
        angsd -b /home/samcrow/scratch/charr/Fst/noker/sample_lists/k3_top50_"$GROUP"_forFst.txt -ref $REF -anc $REF \
        -out /home/samcrow/scratch/charr/Fst/noker/k3/saf/$chrom.$GROUP \
                -uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 \
                -minMapQ 20 -minQ 20 -minInd 40 -setMinDepth 100 -doCounts 1 \
                -GL 1 -doSaf 1 -r $chrom
done
