#!/bin/bash
#SBATCH --time=6:00:00
#SBATCH --account=def-ibradbur
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samantha.crowley@dal.ca
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=5G
#SBATCH --out=slurm.%j.%x.out
#SBATCH --job-name=angsd_dofasta_mito_acad

cd /home/samcrow/scratch/charr/mitogenomes/aligned_acad

module load StdEnv/2023 angsd/0.940

cat /home/samcrow/scratch/charr/mitogenomes/aligned_acad/depth_files/mt_inds_acad_angsd.txt | parallel -j 10 'angsd -i {} -doCounts 1 -dofasta 2 -out {}'
