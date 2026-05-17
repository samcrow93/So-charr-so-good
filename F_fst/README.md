## This section describes the steps used to calculated Fst (between populations and groups based on ngsadmix-generated Kvalues)

## 1.0) Mask the reference genome for previously-identified paralogous loci:

### First, need to modify dev_sites_noker_nodup_uniq.txt (file with unique sites identified as likely paralogous in at least one population by ngsparalog) file to have columns separated by \t instead of _:
```
cat dev_sites_noker_nodup_uniq.txt | sed 's/\_/\t/' > dev_sites_noker_nodup_uniq_tomask.txt
```

### Next, run the following code in R to generate a list of regions with which to mask the reference genome. This code is based off that from https://github.com/xav9536/angsd_pipeline/blob/master/01_scripts/Rscripts/deviant_masking.R, and involves masking regions of 150 bp centered on paralogous loci, then combining overlapping regions.
```
# Load in ref fasta:
index = read.table("/home/samcrow/scratch/charr/genome/Arthur_CHR_polished.fasta.fai")

# Read in list of previously-determined deviant SNPs (determined across all pops)
dev=read.table("./dev_sites_noker_nodup_uniq_tomask.txt",header=FALSE)

# Rename columns:
colnames(dev)=c("chrom","pos")

# Add columns for start and end positions of masked regions (150bp) centered on deviant SNPs (as in Dallaire 3t al.)
dev$start=dev$pos - 75
dev$end=dev$pos + 75

# Some start positions may be before the beginning of the chromosome; correct for this
dev$start[dev$start < 1] =1

# Load required libraries:
library(GenomicRanges)

# Make genomic ranges:
gdev = makeGRangesFromDataFrame(dev, seqnames.field = "chrom", start.field = "start", end.field = "end")
# Combine overlapping ranges together:
gdevu=union(gdev,gdev)
# Make data frame:
devu = as.data.frame(gdevu)
# Exclude (i.e. don't mask) isolated deviant SNPs:
gdevus = gdevu[width(gdevu) > 151,] 
# Make data frame:
devus = as.data.frame(gdevus)
# Check for any chromosomes with regions that end beyond the end of the chromosome:
7# Repeat for all 39 chroms
# Chroms with this issue are sal11, sal23
# Therefore, assign the end position of the chrom in question instead e.g.:
# First extract the end position value for the chrom in question:
sal11_end <- index %>% filter(V1 == "sal11") %>% pull(V2)
# Change the end value for the rows in question:
devus <- devus %>%
  mutate(end = if_else(seqnames == "sal11" & end > sal11_end, sal11_end, end))

# How much of the genome will be masked?
sum(devus$width)/sum(index$V2)*100 # about 6.94%
# How much of each chromosome will be masked:
library(dplyr)
devs_sal01=devus %>% filter(seqnames=="sal01") # Etc for other chromosomes

# Rename
mask = devus
# Write .bed file to use in masking step:
write.table(mask[,1:3],
            file = paste0("./mask_deviant_noker", ".bed"),
            quote = F, row.names = F, col.names = F, sep = "\t")
```

### Next, use bedtools to actually mask the reference genome for these regions:
```
module load bedtools #version?
module load samtools #version?

bedtools maskfasta -fi /home/samcrow/scratch/charr/genome/Arthur_CHR_polished.fasta -bed ./mask_deviant_noker.bed -fo /home/samcrow/scratch/charr/genome/MASKED_charr_noker_ref.fasta

samtools faidx MASKED_charr_noker_ref.fasta
```

## Fst for 'lineage' groups based on ngsadmix outputs (K=2 or K=3 groups):
1) For K=2, used 50 individuals that had ~100% either group1 or group2 admixture. For group3, there aren't any individuals with close to 100% group3 admixture, so choose top 50 individuals that also have <5% group2 admixture (use ngsadmix_process.R script for this selection process). List of individuals (bam files) named (for example) k3_group1_samplesforFst.txt etc.

2) Use ANGSD to calculate sample allele frequency (SAF) for each group using masked reference genome on a per-chromosome basis:
```
for chrom in #sal01 etc
do
sbatch --export=chrom=$chrom saf_k2_angsd.sh     # or saf_k3_angsd.sh
done
```

3) Next, use winsfs to calculate site frequency spectrum (SFS) for each group on a per-chromosome basis:
```
# For k=2, submit jobs as follows:
for chrom in #sal01 etc
do
sbatch --export=chrom=$chrom winsfs_k2_angsd.sh
done

# For k=3, submit jobs as follows (slightly more complicated given the number of combinations):
for chrom in #sal01 etc
do
for GROUP in group2 group3
do
TARGET=group1
sbatch --export=chrom=$chrom,GROUP=$GROUP,TARGET=$TARGET winsfs_k3_angsd.sh
done
done
# And then also:
for chrom in $sal01 etc.
do
for GROUP in group2
do
TARGET=group3
sbatch --export=chrom=$chrom,GROUP=$GROUP,TARGET=$TARGET winsfs_k3_angsd.sh
done
done
```

4) Now need to merge chromosome saf files and sum SFS files:
```
# Merge saf files using realSFS:
realSFS cat sal01.$POP.saf.idx sal02.$POP.saf.idx -outnames $POP.merged  # list all chrom files to be concatenated at once

# winsfs creates output files with a header that realSFS fst index function doesn't like, so remove header from SFS files first:
for file in winsfs*.sfs
do
tail -n +2 $file > sfs_noheader/noheader.$file
done

# In R, sum across SFS files for each population/group:
# For pops 103 and FR, for example:
files_103_FR <- list.files(pattern = "*.103\\.FR\\.sfs$")
# read all files
files_103_FR <- lapply(files_103_FR, read.table)
# sum column-wise
df_sum_103_FR <- Reduce(`+`, files_103_FR)
# write output
write.table(df_sum_103_FR, "sums.103.FR.sfs", quote=F, sep="\t", row.names=F, col.names=F)
```



5) Next, need to calculate Fst with realSFS and the saf and sfs files:
```

# For each group comparison calculate per-site Fst:
realSFS fst index $group2.saf.idx $group1.saf.idx -sfs noheader.winsfs.group1.group2.sfs -fstout fst/group2.group1.fst

# Also calculate global weighted Fst:
realSFS fst stats group2.group1.fst.idx
```

6) Lastly, calculate windowed Fst (for window and step size of 10k bp):
```
realSFS fst stats2 group2.group1.fst.idx -win 10000 -step 10000 > fst_window/group2.group1.fst.txt
```
















