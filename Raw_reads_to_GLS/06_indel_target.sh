#!/bin/bash
#SBATCH --time=6:00:00
#SBATCH --account=def-ibradbur
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=samantha.crowley@dal.ca
#SBATCH --ntasks=32
#SBATCH --mem-per-cpu=5G
#SBATCH --cpus-per-task=1
#SBATCH --job-name=indel_target_charr

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
   --jobs 32 \
  ' java -Xmx5g \
  -Djava.io.tmpdir=$projdir/gatktemp\
  -jar $EBROOTGATK/GenomeAnalysisTK.jar  \
  -T RealignerTargetCreator \
  -R $genome \
  -I $projdir/align/{}.deDup.bam \
  -o $projdir/align/{}.intervals'
