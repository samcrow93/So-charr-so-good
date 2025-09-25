#!/bin/bash
#SBATCH --time=1:00:00
#SBATCH --account=def-ibradbur
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=samantha.crowley@dal.ca
#SBATCH --mem=1G
#SBATCH --out=slurm.%x.%j.out
#SBATCH --job-name=charr_LD_prune_bigkb

# Generate pruned SNP list using the prune_graph.pl script within ngsLD
# Do this for each chromosome

cd /home/samcrow/programs/prune_graph
dir=/home/samcrow/scratch/charr_wgs/redo_angsd/angsd_filt_outs/lowfilts/parafilts/subsampled_parafilt/ngsld_out_bigkbdist

echo "Pruning sites for $chrom"
./target/release/prune_graph --header \
 --in $dir/$chrom.ngsld_subsamp_bigkb.ld \
 --weight-field "r2" --weight-filter "dist <= 200000 && r2 >= 0.1" \
 --out $dir/$chrom.subsamp_bigkb_unlinked.pos
echo "Finished pruning sites for $chrom"
