## This section describes the generation of population-specific maf files, GEA analysis using RDA and variance partitioning, and genomic offsets.

### (1) Generate files of population-specific minor allele frequencies (on a per-chrom basis) using ANGSD by running the 01_pop_freqs_for_GO_noker.sh script.

### (2) Next need to concatenate chromosome maf files for each population:
```
# Make new concat file for each pop and add header:
for pop in pops
do
zcat $pop.sal01.mafs.gz | head -n 1 | gzip > $pop.concat.mafs.gz
done

# Next loop through each chromosome for each pop, remove header and add to concat file:
for pop in pops
do
for chrom in chroms
do
zcat $pop.$chrom.mafs.gz | tail -n +2 | gzip >> $pop.concat.mafs.gz
done
done
```

### (3) To generate one file with all population maf data, run section "(i) Initial processing of per-population maf data" in script rda_varpar_bio_climat.R using the rda_varpar_bio_climat_job.sh script. This will output a file called pop_mafs_rda_format.csv, where rows are populations and columns are SNPs. 
