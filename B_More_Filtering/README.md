## Now that we have beagle files with low-depth individuals filtered out, we can move on to more filtering!
## This includes:
### 1) Identifying and filtering out potentially paralogous loci
### 2) Pruning loci in LD

### So, without further ado, onto part 1...
### 1) Identifying and filtering out potentially paralogous loci
First, need to make a samtools mpileup file for each population as input for ngsParalog:
A) Create sites file as input for mpileup script:
```
# Get positions from each beagle chromosome files to generate chromosome sites files (WITHOUT header):
zcat sal01_filt.beagle.gz | sed 's/_/\t/g' | cut -f 1,2 | tail -n+2 > sal01.sites

# Concatenate all sites files together:
for file in sal*.sites
do
cat $file >> allsites.txt
done
```

B) Run mpileup_pop.sh scripts (e.g. 01_mpileup_pop103.sh)
- Bamlists of samples corresponding to each population were generated using sample names which contain pop codes

C) Run ngsparalog (using pop_ngsparalog.sh scripts (e.g. 02_pop103_ngsparalog.sh)) on a per-population basis:
- For all loci for which genotype likelihoods were calculated in the original ANGSD run (i.e. allsites.txt)
- ngsParalog will output likelihoods that reads covering each SNP are mismapped/mapped to multiple locations instead of just one location.

D) Identify which SNPs should be removed based on a p-value threshold:
- Use the 03a_paralog_filt.R and 03b_paralog_filt_job.sh scripts
- Note that this will output a list of deviant ('BAD' i.e. likely having mismapped reads) SNPs, across ALL population (this means that many loci will be duplicated if they are deviant in multiple populations- output in the dev_sites.txt file)

D) Identify unique list of SNPs that are deviant in at least one population:
```
# This will cut the 2nd column from the dev_sites_all.txt file (the chrom_snp column), and only keep unique sites
cut -f2 dev_sites_all.txt | sort | uniq > dev_sites_final.txt
```

E) Identify 'GOOD' (i.e. likely non-paralogous) loci, and split up by chromosome, by running this code:
```
# Modify allsites.txt file so that there is a "_" in between chromosome and position:
cat allsites.txt | sed 's/\t/\_/' > allsites_mod.txt
# Then, reverse grep for deviant sites in list of all sites to generate list of good sites:
grep -Fvx -f /home/samcrow/scratch/charr_wgs/mpileup/ngsparalog_out/dev_sites_final.txt allsites_mod.txt > goodsites.txt
# Finally, split up good sites file by chromosome:
grep "sal01" goodsites.txt > goodsites/sal01.goodsites.txt   # etc for other chromosomes
```

Finally, use the 04_remove_dev_snps.sh script to filter out deviant SNPs and only keep "good" ones (submit as follows on a per-chromosome basis):
```
for chrom in sal01 sal02  # etc
do
sbatch --export=ALL,chrom=$chrom remove_dev_snps.sh
done
```
** Note: these paralog-filtered beagle files will not have a header!! **

### Now we have beagle files that have been filtered of likely paralogous loci and are ready to be LD-filtered. 
Initially, I filtered not super stringently, and used the paralog-pruned files without further pruning - this took a very long time!
Instead, going forward I decided to a) subsample the paralog-pruned files to every 10th SNP, then run more stringent LD-pruning.

### 2) NGSLD
a) Subsample low-filtered, paralog-filtered beagle files by selecting every 10th line. Also remove first three columns (recommendation from https://github.com/therkildsen-lab/genomic-data-analysis/blob/master/markdowns/ld.md#ld-estimation):
```
zcat sal01.para_filt.beagle.gz | awk 'NR % 10 == 0' | cut -f 4- | gzip  > sal01_subsamp_para.beagle.gz
```

b) Create position file that matches subsampled beagle file (which no longer has position info): The line below will separate the position from chromosome by replacing _ with tab, then selects only the first 2 cols, then every 10 lines:
```
zcat sal01.para_filt.beagle.gz | sed 's/_/\t/g' | cut -f 1,2 | awk 'NR % 10 == 0' | gzip > subsampled_parafilt/sal01_subsamp_para.pos.gz
```

c) Run 05_ngsld_bigkb.sh script for each chromosome:
```
for chrom in sal01 sal02 #etc to sal39
do
sbatch --export=ALL,chrom=$chrom ngsld_bigkb.sh
done
```

d) Run 06_ngsld_prune_bigkb.sh script (submit same as for script in step above). This will output a file with a list of chromosomes and positions of sites that are in linkage equilibrium. Modify this file so that chromosomes and positions are separated by a tab instead of a :
```
sed -e 's/\:\+/_/g' sal01.subsamp_bigkb_unlinked.pos > sal01_unlinked.txt
```

e) Instead of running ANGSD again for only the unlinked sites, prune paralog-filtered beagle files for only unlinked sites identified in steps above:
```
zcat ../../sal01.para_filt.beagle.gz | grep -f sal01_unlinked.txt -Fw | gzip > ldfilt_subsamp_bigkb/sal01_bigkb_para_subsamp.beagle.gz
```
** NOTE: these beagle files also do NOT have a header!! **

f) Concatenate chromosone files and add header back to prep for ngsadmix:
```
# Add header from lowfilt file
zcat lowfilt.sal01.beagle.gz | head -n 1 | gzip > /parafilts/subsampled_parafilt/ngsld_out_bigkbdist/ldfilt_subsamp_bigkb/concat_charr_bigkb_para_subsamp.beagle.gz
# Add each chromosome file sequentially
zcat sal01_bigkb_para_subsamp.beagle.gz | gzip >> concat_charr_bigkb_para_subsamp.beagle.gz # repeat for other chromosome files
```

## There are now paralog-filtered, LD-filtered chromosome beagle files, as well as a concatenated filtered file for use in ngsadmix and other downstream analyses.
