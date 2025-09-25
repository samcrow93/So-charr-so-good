#!/bin/bash
#SBATCH --time=24:00:00
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --mem=10G
#SBATCH --output=slurm.%x.%j.out
#SBATCH --job-name=ngsadmix_ldpruned_bigkb_para_subsamp


cd /home/samcrow/scratch/charr_wgs/redo_angsd/angsd_filt_outs/lowfilts/parafilts/subsampled_parafilt/ngsld_out_bigkbdist/ldfilt_subsamp_bigkb

# Run ngsAdmix on concatenated file that contains all chromosomes (stringently ldpruned, paralog-pruned) with K=2-8,16,24,32,42,51:
# (There are 51 unique named locations in the dataset; some have multiple years of sampling; some are very close together)
# Run X replicates for each k-value in order to look at log-likelihood values

echo "Running ngsadmix with K=$kvalue for replicate=$replicate"

/home/samcrow/programs/ngsadmix/NGSadmix -likes concat_charr_bigkb_para_subsamp.beagle.gz -K $kvalue \
 -o ngsadmix/charr_bigkb_para_subsamp.$kvalue.$replicate -P 10

echo "Finished ngsAdmix K=$kvalue.$replicate"
