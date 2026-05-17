## Now that we have beagle files with low-depth individuals filtered out, we can move on to more filtering!
## This includes:
### 1) Identifying and filtering out potentially paralogous loci
### 2) Pruning loci in LD

### So, without further ado, onto part 1...
### 1) Identifying and filtering out potentially paralogous loci
First, need to make a samtools mpileup file for each population as input for ngsParalog:

A) Create sites file as input for mpileup script:
```
for file in *mafs.gz;
do
zcat $file | tail -n +2 | cut -f1,2 >> concat_noker_sites.txt;
done
```

B) Run mpileup using 01_mpileup_pops.sh script.

C) Run ngsparalog on a per-population basis using the 02_ngsparalog_pops.sh script:
- For all loci for which genotype likelihoods were calculated in the original ANGSD run, ngsParalog will output likelihoods that reads covering each SNP are mismapped/mapped to multiple locations instead of just one location.

D) Identify which SNPs should be removed based on a p-value threshold:
- Use the 03a_paralog_filt.R and 03b_paralog_filt_job.sh scripts
- Note that this will output a list of unique deviant SNPs ('BAD' i.e. likely having mismapped reads)

E) Identify 'GOOD' (i.e. likely non-paralogous) loci, and split up by chromosome, by running this code:
```
# Modify concat_noker_sites.txt file so that there is a "_" in between chromosome and position:
cat concat_noker_sites.txt | sed 's/\t/\_/' > concat_noker_underscore_sites.txt
# Then, reverse grep for deviant sites in list of all sites to generate list of good sites:
grep -Fvx -f dev_sites_noker_nodup_uniq.txt ../../concat_noker_underscore_sites.txt > goodsites_noker.txt
# Finally, split up good sites file by chromosome:
grep "sal01" goodsites_noker.txt > goodsites/sal01.goodsites.txt   # etc for other chromosomes
```

Finally, use the 04_remove_dev_snps_noker.sh script to filter out deviant SNPs and only keep "good" ones (submit as follows on a per-chromosome basis):
```
for chrom in sal01 sal02  # etc
do
sbatch --export=ALL,chrom=$chrom remove_dev_snps_noker.sh
done
```

### Now we have beagle files that have been filtered of likely paralogous loci and are ready to be LD-filtered. 

### 2) NGSLD
a) Subsample paralog-filtered beagle files by selecting every 5th line. Also remove first three columns (recommendation from https://github.com/therkildsen-lab/genomic-data-analysis/blob/master/markdowns/ld.md#ld-estimation):
```
# Get header for new subsample file:
zcat sal01.parafilt.beagle.gz | head -n 1 | gzip > subsamp_para/sal01.subsamp.para.beagle.gz
# sample every 5th line, remove first 3 columns:
# Note that this removes the header first so that the first SNP sampled is indeed the 10th SNP in the file:
zcat sal01.parafilt.beagle.gz | tail -n +2 | awk 'NR % 5 == 0' | cut -f 4- | gzip  > subsamp_para/sal01.subsamp.para.beagle.gz
```

b) Create position file that matches subsampled beagle file (which no longer has position info): The line below will separate the position from chromosome by replacing _ with tab, then selects only the first 2 cols, then every 5 lines (note that this position file will not have a header):
```
zcat sal01.parafilt.beagle.gz | tail -n +2 | sed 's/_/\t/g' | cut -f 1,2 | awk 'NR % 5 == 0' | gzip > subsamp_para/sal01.subsamp.para.pos.gz
```

c) Run 05_ngsld_bigkb.sh script for each chromosome:
```
for chrom in sal01 sal02 #etc to sal39
do
sbatch --export=ALL,chrom=$chrom ngsld_bigkb.sh
done
```

d) Run 06_ngsld_prune_bigkb.sh script (submit same as for script in step above). This will output a file with a list of chromosomes and positions of sites that are in linkage equilibrium. Modify this file so that positions are sorted, and that chrom and pos are separated by a _ instead of a :
```
for chrom in sal01 sal02 # etc
do
sed 's/\:/\t/g' $chrom.subsamp.bigkb.unlinked.pos | sort -n -k2 | sed 's/\t/\_/g' > $chrom.noker.unlinked.txt
done
```

e) Instead of running ANGSD again for only the unlinked sites, prune paralog-filtered beagle files for only unlinked sites identified in steps above:
```
# First make header for new files:
for chrom in sal01 # etc
do
zcat ../../$chrom.parafilt.beagle.gz | head -n 1 | gzip > ld_filt/$chrom.para.ldfilt.beagle.gz
done
# Next filter for unlinked loci:
for chrom in sal01 # etc
do
zcat ../../$chrom.parafilt.beagle.gz | grep -f $chrom.noker.unlinked.txt -Fw | gzip >> ld_filt/$chrom.para.ldfilt.beagle.gz
done
```

f) Concatenate chromosone files and add header back to prep for ngsadmix:
```
# Add header:
zcat sal01.para.ldfilt.beagle.gz | head -n 1 | gzip > concat.para.ldfilt.noker.beagle.gz
# Add each chromosome file sequentially
for chrom in sal01 #etc.
do
zcat $chrom.para.ldfilt.beagle.gz | tail -n +2 | gzip >> concat.para.ldfilt.noker.beagle.gz
done
```

## There are now paralog-filtered, LD-filtered chromosome beagle files, as well as a concatenated filtered file for use in ngsadmix and other downstream analyses.
