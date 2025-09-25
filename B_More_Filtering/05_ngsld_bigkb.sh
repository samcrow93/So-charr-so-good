#!/bin/bash
#SBATCH --time=3:00:00
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --mem=5G
#SBATCH --output=slurm.%x.%j.out
#SBATCH --job-name=charr_ngsld_subsamp_bigkb

# Calculate LD using ngsLD
# have cloned git repository for ngsLD into subdirectory

geno=/home/samcrow/scratch/charr_wgs/redo_angsd/angsd_filt_outs/lowfilts/parafilts/subsampled_parafilt/"$chrom"_subsamp_para.beagle.gz
pos=/home/samcrow/scratch/charr_wgs/redo_angsd/angsd_filt_outs/lowfilts/parafilts/subsampled_parafilt/"$chrom"_subsamp_para.pos.gz
n_sites=$(zcat /home/samcrow/scratch/charr_wgs/redo_angsd/angsd_filt_outs/lowfilts/parafilts/subsampled_parafilt/"$chrom"_subsamp_para.pos.gz | wc -l)


echo "Running ngsLD on chrom $chrom for $n_sites sites, with max_kb_dist 200"
# there are 1878 unique individuals, but 1882 samples in the beagle files because 4 samples were sequenced twice
/home/samcrow/programs/ngsLD/ngsLD --geno $geno --pos $pos --probs --n_ind 1882 \
--n_sites $n_sites --max_kb_dist 200 --n_threads 10 \
--out /home/samcrow/scratch/charr_wgs/redo_angsd/angsd_filt_outs/lowfilts/parafilts/subsampled_parafilt/ngsld_out_bigkbdist/$chrom.ngsld_subsamp_bigkb.ld

echo "Finished running ngsLD on chrom $chrom"
