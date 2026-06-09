#!/bin/bash
#SBATCH --time=
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --mem=
#SBATCH --out=
#SBATCH --job-name=ancestry_hmm_pops_noker

# This script is to run Ancestry_HMM on the charr data (generated from the no-Ker, no dup, no lowdepth, no neg dataset)
# Flags: -a indicate 2 ancestral groups and their proportions
# Note that it's a bit confusing because groups are numbered starting at 0 for AHMM parameterization
# This means that my "Group1" (Arctic) is parameterized as group0, while my "Group2" (Atlantic) is parameterized as group1
# -p indicates a single pulse of group0 (Arctic) into group1 (Atlantic) estimated around 1500 generations ago (9k years divided by ~6 yr gen time?)
# Divergence time of Arctic and Atlantic lineages estimated ~400k years (so, 66,666 gens?)
# This estimates are just used as a starting point by the program

module load armadillo/12.6.4

cd /home/samcrow/scratch/charr/ahmm/noker/inputs/$WIN/$AF/$POP

# Specify file containing mean global ancestry proportions for the admixed populations
ancfile=/home/samcrow/scratch/charr/scripts/ahmm_admix_noker_inputs.txt

# Need to specify what the global (whole-genome) mean admixture proportions are (from ngsadmix K=2 output):
read ANC0 ANC1 < <(awk -v p="$POP" '$1 == p { print $2, $3 }' $ancfile)
echo "Genome-wide mean Arctic admixture is $ANC0; mean Atlantic admixture is $ANC1; for population $POP"
# ANC0 is the mean proportion of group0 (Arctic) ancestry in the population; ANC1 is Atlantic

# Ancestry_hmm with 1 pulse of Arctic into Atlantic:
echo "1 pulse, Arc to Atl, $POP"
/home/samcrow/programs/Ancestry_HMM/src/ancestry_hmm -i ahmm.input.$POP.$WIN.$AF.txt \
 -s ahmm.$POP.samplefile.txt -a 2 $ANC0 $ANC1 -p 1 -66666 $ANC1 \
 -p 0 -1500 $ANC0 -e 1e-3 > ./outputs/$POP.$WIN.$AF.arc2atl.1pulse.output.txt





