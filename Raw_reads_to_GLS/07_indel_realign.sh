#!/bin/bash
#SBATCH --time=12:00:00
#SBATCH --account=def-ibradbur
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=samantha.crowley@dal.ca
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=10G
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
