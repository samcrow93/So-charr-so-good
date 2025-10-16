## This section describes the steps used to calculated Fst (between populations and groups based on ngsadmix-generated Kvalues)

## 1.0) Mask the reference genome for previously-identified paralogous loci:

### First, need to modify dev_sites_final.txt (file with unique sites identified as likely paralogous in at least one population by ngsparalog) file to have columns separated by \t instead of _:
```
cat dev_sites_final.txt | sed 's/\_/\t/' > dev_sites_final_tomask.txt
```

### Next, run the following code in R to generate a list of regions with which to mask the reference genome. This code is based off that from https://github.com/xav9536/angsd_pipeline/blob/master/01_scripts/Rscripts/deviant_masking.R, and involves masking regions of 150 bp centered on paralogous loci, then combining overlapping regions.
```
# Load in ref fasta:
index = read.table("/home/samcrow/genome/Arthur_CHR_polished.fasta.fai")

# Read in list of previously-determined deviant SNPs (determined across all pops with sufficient samples)
dev=read.table("./dev_sites_final_tomask.txt",header=FALSE)

# Rename columns:
colnames(dev)=c("chrom","pos")

# Add columns for start and end positions of masked regions (150bp) centered on deviant SNPs (as in Dallaire t al. )
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
devus %>% filter(seqnames=="sal01") %>% filter(end > index[index$V1=="
sal01","V2"]) %>% head() # Repeat for all 39 chroms
# Chroms with this issue are sal11, sal23
# Therefore, assign the end position of the chrom in question instead e.g.:
# First extract the end position value for the chrom in question:
sal11_end <- index %>% filter(V1 == "sal11") %>% pull(V2)
# Change the end value for the rows in question:
devus <- devus %>%
  mutate(end = if_else(seqnames == "sal11" & end > sal11_end, sal11_end, end))

# How much of the genome will be masked?
sum(devus$width)/sum(index$V2)*100 # about 5.7%
# How much of each chromosome will be masked:
library(dplyr)
devs_sal01=devus %>% filter(seqnames=="sal01") # Etc for other chromosomes

# Rename
mask = devus
# Write .bed file to use in masking step:
write.table(mask[,1:3],
            file = paste0("./mask_deviant", ".bed"),
            quote = F, row.names = F, col.names = F, sep = "\t")
```

### Next, use bedtools to actually mask the reference genome for these regions:
```
module load bedtools #version?
module load samtools #version?

bedtools maskfasta -fi /home/samcrow/genome/Arthur_CHR_polished.fasta -bed ./mask_deviant.bed -fo /home/samcrow/genome/MASKED_charr_ref.fasta

samtools faidx MASKED_charr_ref.fasta
```
