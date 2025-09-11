## Now that we have beagle files with low-depth individuals filtered out, we can move on to more filtering!
## This includes:
### 1) Identifying and filtering out potentially paralogous loci
### 2) Pruning loci in LD

### So, without further ado, onto part 1...
### 1) Identifying and filtering out potentially paralogous loci
First, need to make a samtools mpileup file for each population as input for ngsParalog - use mpileup_pop.sh scripts to do this.

Next, use the pop_ngsparalog.sh scripts to run ngsParalog on a per-population basis, for all loci for which genotype likelihoods were calculated in the original ANGSD run.
ngsParalog will output likelihoods that reads covering each SNP are mismapped/mapped to multiple locations instead of just one locus.

After this, can identify which SNPs should be removed based on a p-value threshold; using the paralog_filt_job.sh and paralog_filt.R scripts.
Note that this will output a list of 'BAD' (i.e. likely having mismapped reads) SNPs.
Subsequently, can figure out which are 'GOOD', and split up by chromosome, by running this code:
```
grep -Fvx -f /home/samcrow/scratch/charr_wgs/mpileup/ngsparalog_out/dev_sites_final.txt allsites_mod.txt > goodsites.txt
grep "sal01" goodsites.txt > goodsites/sal01.goodsites.txt   # etc for other chromosomes
```

Finally, use the remove_dev_snps.sh script to filter out deviant SNPs and only keep "good" ones (submit as follows on a per-chromosome basis):
```
for chrom in sal01 sal02  # etc
do
sbatch --export=ALL,chrom=$chrom remove_dev_snps.sh
done
```

Now we have beagle files that have been filtered of likely paralogous loci and are ready to be LD-filtered. 
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

c) Run ngsld_bigkb.sh script for each chromosome:
```
for chrom in sal01 sal02 #etc to sal39
do
sbatch --export=ALL,chrom=$chrom ngsld_bigkb.sh
done
```

d) Run ngsld_prune_bigkb.sh script (submit same as for script in step above). This will output a file with a list of chromosomes and positions of sites that are in linkage equilibrium. Modify this file so that chromosomes and positions are separated by a tab instead of a :
```
sed -e 's/\:\+/_/g' sal01.subsamp_bigkb_unlinked.pos > sal01_unlinked.txt
```

e) Instead of running ANGSD again for only the unlinked sites, prune paralog-filtered beagle files for only unlinked sites identified in steps above:
```
zcat ../../sal01.para_filt.beagle.gz | grep -f sal01_unlinked.txt -Fw | gzip > ldfilt_subsamp_bigkb/sal01_bigkb_para_subsamp.beagle.gz
```






