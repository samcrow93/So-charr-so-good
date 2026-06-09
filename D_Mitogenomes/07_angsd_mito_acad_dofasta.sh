#!/bin/bash
#SBATCH --time=
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --ntasks=
#SBATCH --cpus-per-task=
#SBATCH --mem-per-cpu=
#SBATCH --out=
#SBATCH --job-name=angsd_dofasta_mito_acad

cd /home/samcrow/scratch/charr/mitogenomes/aligned_acad

module load StdEnv/2023 angsd/0.940

cat /home/samcrow/scratch/charr/mitogenomes/aligned_acad/depth_files/mt_inds_acad_angsd.txt | parallel -j 10 'angsd -i {} -doCounts 1 -dofasta 2 -out {}'
