#!/bin/bash
#SBATCH --time=1:00:00
#SBATCH --account=def-ibradbur
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=samantha.crowley@dal.ca
#SBATCH --mem=2G
#SBATCH --output=slurm-%x_%j.out
#SBATCH --job-name=windowed_beagles

# This code will generate windowed beagle files for each chromosome of 1000 SNPs each
# This latest version (April 28th 2026) does this for beagle files generated without Kerguelen samples, and without duplicates and negatives

cd /home/samcrow/scratch/charr/noker/angsd_outs/windows/$chrom


# awk -v assigns variable chrom to value "$chrom"
# NR==1 {h=$0; next} takes the first row (i.e. header, NR==1) and stores in in the variable h ($0 is the current line, i.e. header in this case)
# Then moves to next line

# Then assign chunks of 1000 lines, where lines (SNPs) 2-1001 are in chunk1, 1002-2001 are in chunk2, etc.
# post-increment the variable f i.e. increase by 1
# ++ after a variable means if a[f] is 0, the value a[f]++ is 0 but also immediately changes the value of a[f] to 1
# ! refers to not, and !0 is 'TRUE', so because a[f] is default 0 at the beginning, this essentially reads if TRUE print h (i.e. header)
# to new file with window f
# Then because a[f] is changed immediately to 1, the next time it will read if 'not 1' which will be false, so won't print anything
# Essentially only prints the header once per file

# Finally print the rest of the rows (SNPs) for each window
zcat ../../$chrom.beagle.gz | awk -v chrom="$chrom" 'NR==1 {h=$0; next}
{
f=int((NR-2)/1000)+1
if (!a[f]++) print h > chrom ".win." f ".beagle"
print >> chrom ".win." f ".beagle"
}'
# zip the file
gzip $chrom.win*.beagle




# This code will generate windowed beagles based on position (i.e. in windows of 1MB)
# I didn't end up going with this method 
#while read start end
#do
#zcat ../lowfilt.${chrom}.beagle.gz | awk -v s=$start -v e=$end '
#NR==1 {print; next}
#{
#split($1, a, "_")
#if (a[2] >= s && a[2] <= e) print
#}' | gzip > ./${chrom}/${chrom}_${start}_${end}.beagle.gz
#done < ./chrom_win_files/chrom${chrom}.windows.txt

