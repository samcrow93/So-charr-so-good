#!/bin/bash
#SBATCH --time=
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --ntasks=
#SBATCH --cpus-per-task=
#SBATCH --mem-per-cpu=
#SBATCH --job-name=indel_realign_charr

cd /home/samcrow/scratch/charr_wgs/all_charr/

#load variables
source $paramfile

#load packages
module load nixpkgs/16.09 gatk/3.7

##export to keep parallel happy
export projdir
export genome

cat $projdir/sets/NL_sets_extralong/$set | \
   parallel --tmpdir $projdir/gatktemp \
   --jobs 1 \
  ' java -Xmx5g \
  -Djava.io.tmpdir=$projdir/gatktemp\
  -jar $EBROOTGATK/GenomeAnalysisTK.jar  \
 -T IndelRealigner \
 -R $genome \
 -I $projdir/align/{}.deDup.bam  \
 -targetIntervals $projdir/align/{}.intervals \
 -o $projdir/align/{}.realigned.bam '
