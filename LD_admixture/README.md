## Now that we have beagle files with low-depth individuals filtered out, we can move on to more filtering!
## This includes:
### 1) Identifying and filtering out potentially paralogous loci
### 2) Identifying and excluding loci in sex-linked regions
### 3) Pruning loci in LD

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
