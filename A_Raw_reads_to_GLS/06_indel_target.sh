#!/bin/bash
#SBATCH --time=
#SBATCH --account=
#SBATCH --mail-type=
#SBATCH --mail-user=
#SBATCH --ntasks=
#SBATCH --mem-per-cpu=
#SBATCH --cpus-per-task=
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
