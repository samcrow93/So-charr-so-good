library(here)
library(seqinr)
library(adegenet)
library(ape)
library(DECIPHER)
library(viridis)
library(ggplot2)
library(haplotypes)

# read in the aligned data
setwd("/Users/sammy/Documents/PhD/charr_all/")
# Acad-ref, including Acad and Sfont sequences:
acad_ref_font <- haplotypes::read.fas("./mitogenomes/trees/combo_acadref_withfontandacad_multiseqalign.fa")

#find haplotypes:
h<-haplotypes::haplotype(acad_ref_font,indels="s")
# There are 666 unique haplotypes 

# Get haplotype frequencies
freqs <- as.data.frame(h@freq)
freqs$rownames <- row.names(freqs)
colnames(freqs) <- c("freq","rowname")

# Get haplotype sequences and their representative individuals:
hap_seqs <- h@sequence

# Write as fasta sequence:
library(seqinr)
sequences <- apply(hap_seqs, 1, paste, collapse="")
seq_names <- paste0("haplotype",seq(1:666))
#write.fasta(sequences = as.list(sequences),
#            names = seq_names,
#            file.out = "./mitogenomes/hap_seqs_acadref_withfontacad.fasta")

# Also need to get list of samples for each haplotype 
hapind_list <- h@hapind
# Create empty data frame to hold these individuals and their hap number:
hap_df <- data.frame(individual = character(), 
                     haplotype = character(), 
                     stringsAsFactors = FALSE)
# Loop through each haplotype
for (hap_name in names(hapind_list)) {
  # Extract individuals for this haplotype
  individuals <- hapind_list[[hap_name]]
  # Combine into a temporary data frame
  temp_df <- data.frame(individual = individuals,
                        haplotype = hap_name,
                        stringsAsFactors = FALSE)
  # Append to the main data frame
  hap_df <- rbind(hap_df, temp_df)
}
head(hap_df)
# Change column 1 to be sample names:
hap_df$sample <- row.names(hap_df)
row.names(hap_df) <- NULL
hap_df <- hap_df[,-1]

# Cut extra stuff from sample names:
hap_df$sample <- gsub("^.*?i5\\.", "", hap_df$sample)
hap_df$sample <- gsub(hap_df$sample, 
                      pattern="NC_000861.1_", replacement="", fixed=T)

# Modify sample names for other S.alpinus ref and S. fontinalis ref:
hap_df$sample[1891] <- "Sfont_ref"
hap_df$sample[1892] <- "Acad_ref"

# Load in SRA metadata (from Laval samples n=517)
sra_meta <- as.data.frame(read.csv("./metadata/raw/laval_sra.csv"))
# change column name from 'Run' to 'sample' to match sample data:
colnames(sra_meta)[1] <- "sample"
# Keep sample name and geo_loc_name only for simplified metadata:
sra_meta_reduce <- sra_meta[,c(1,24)]
# Merge SRA metadata (geo_loc_name only) with samples:
hap_merge <- merge(hap_df, sra_meta_reduce,by="sample",all.x=TRUE)

# Add in population name info for my samples:
library(dplyr)
hap_merge <- hap_merge %>% 
  mutate(population=case_when(grepl("PG001_0",sample)~ "PG001_2022",
                              grepl("PG001_2001",sample)~ "PG001_2001",
                              grepl("PG001_2013",sample)~ "PG001_2013",
                              grepl("PG004_0",sample)~ "PG004_2022",
                              grepl("PG004_1",sample)~ "PG004_2022",
                              grepl("PG004_2002",sample)~ "PG004_2002",
                              grepl("PG004_2011",sample)~ "PG004_2011",
                              grepl("PG015_2003",sample)~ "PG015_2003",
                              grepl("PG015_2011",sample)~ "PG015_2011",
                              grepl("PG080_2002",sample)~ "PG080_2002",
                              grepl("PG080_2011",sample)~ "PG080_2011",
                              grepl("PG010_2002",sample)~ "PG010_2002",
                              grepl("PG010_2013",sample)~ "PG010_2013",
                              grepl("PG014_2006",sample)~ "PG014_2006",
                              grepl("PG014_2010",sample)~ "PG014_2010",
                              grepl("PG008_2002",sample)~ "PG008_2002",
                              grepl("PG008_2014",sample)~ "PG008_2014",
                              grepl("Satuut",sample)~ "SAT_2019",
                              grepl("Robertson",sample)~ "ROB",
                              grepl("Tugaat",sample)~ "TUG",
                              grepl("Iceland",sample)~ "ICE",
                              grepl("Tasersuaq",sample)~ "TAS",
                              grepl("Green",sample)~ "EG",
                              grepl("Jan",sample)~ "JM",
                              grepl("KAN",sample)~ "KAN",
                              grepl("IKA",sample)~ "IKA",
                              grepl("10417",sample)~ "104",
                              grepl("IKI",sample)~ "IKI",
                              grepl("KIN",sample)~ "KIN",
                              grepl("NAC",sample)~ "NAC",
                              grepl("10317",sample)~ "103",
                              grepl("PAN",sample)~ "PAN",
                              grepl("NOR",sample)~ "NOR",
                              grepl("10917",sample)~ "109",
                              grepl("R7817",sample)~ "R78",
                              grepl("MBB17",sample)~ "MBB17",
                              grepl("MBB23",sample)~ "MBB23",
                              grepl("ENG",sample)~ "ENG",
                              grepl("PBP",sample)~ "PBP",
                              grepl("ANA",sample)~ "ANA",
                              grepl("BLD",sample)~ "BLD",
                              grepl("FR",sample)~ "FR",
                              grepl("AVA",sample)~ "AVA",
                              grepl("Ker",sample)~ "KER",
                              grepl("SGR",sample)~ "SGR19",
                              grepl("NNor",sample)~ "NNor",
                              grepl("BI",sample)~ "BI",
                              grepl("KL19",sample)~ "KL19",
                              grepl("SRR",sample)~ "Laval_data"))



# Next, add in specifics for Laval data:
hap_merge <- hap_merge %>% 
  mutate(population=case_when(grepl("EKA",geo_loc_name)~ "EKA",
                              grepl("CRB",geo_loc_name)~ "CRB",
                              grepl("AKL",geo_loc_name)~ "AKL",
                              grepl("SVG",geo_loc_name)~ "SGR18",
                              grepl("COP",geo_loc_name)~ "COP",
                              grepl("SPI",geo_loc_name)~ "SPI",
                              grepl("SAT",geo_loc_name)~ "SAT_2019b",
                              grepl("QSG",geo_loc_name)~ "PG015_2010",
                              grepl("QNB",geo_loc_name)~ "QNB",
                              grepl("PAM",geo_loc_name)~ "PAM",
                              grepl("KGJ",geo_loc_name)~ "KGJ",
                              grepl("IPI",geo_loc_name)~ "IPI",
                              grepl("TAH",geo_loc_name)~ "TAH",
                              grepl("HRN",geo_loc_name)~ "HRN",
                              grepl("HAL",geo_loc_name)~ "HAL",
                              grepl("GEO",geo_loc_name)~ "GEO",
                              grepl("FRM",geo_loc_name)~ "FRM",
                              TRUE ~ population))
hap_merge$population <- as.factor(hap_merge$population)
levels(hap_merge$population) #n=64

hap_merge <- hap_merge %>% 
  mutate(region=case_when(grepl("PG0",sample)~ "Nunavut",
                          grepl("Satuut",sample)~ "Nunavut",
                          grepl("Robertson",sample)~ "Nunavut",
                          grepl("Tugaat",sample)~ "Nunavut",
                          grepl("Iceland",sample)~ "Iceland",
                          grepl("Tasersuaq",sample)~ "Greenland",
                          grepl("Green",sample)~ "Greenland",
                          grepl("Jan",sample)~ "Jan_Mayen",
                          grepl("KAN",sample)~ "Labrador",
                          grepl("IKA",sample)~ "Labrador",
                          grepl("10417",sample)~ "Labrador",
                          grepl("IKI",sample)~ "Labrador",
                          grepl("KIN",sample)~ "Labrador",
                          grepl("NAC",sample)~ "Labrador",
                          grepl("10317",sample)~ "Labrador",
                          grepl("PAN",sample)~ "Labrador",
                          grepl("NOR",sample)~ "Labrador",
                          grepl("10917",sample)~ "Labrador",
                          grepl("R7817",sample)~ "Labrador",
                          grepl("MBB",sample)~ "Labrador",
                          grepl("ENG",sample)~ "Labrador",
                          grepl("PBP",sample)~ "Labrador",
                          grepl("ANA",sample)~ "Labrador",
                          grepl("BLD",sample)~ "Labrador",
                          grepl("FR",sample)~ "Labrador",
                          grepl("AVA",sample)~ "Labrador",
                          grepl("Ker",sample)~ "Kerguelen",
                          grepl("SGR",sample)~ "Nunavut",
                          grepl("NNor",sample)~ "Norway",
                          grepl("BI",sample)~ "Norway",
                          grepl("KL19",sample)~ "Nunavut",
                          grepl("SRR",sample)~ "Laval_data"))

# Add in region info for Laval samples:
hap_merge <- hap_merge %>% 
  mutate(region=case_when(grepl("EKA",geo_loc_name)~ "Nunavut",
                          grepl("CRB",geo_loc_name)~ "Nunavut",
                          grepl("AKL",geo_loc_name)~ "Nunavut",
                          grepl("SVG",geo_loc_name)~ "Nunavut",
                          grepl("COP",geo_loc_name)~ "Nunavut",
                          grepl("SPI",geo_loc_name)~ "Nunavik",
                          grepl("SAT",geo_loc_name)~ "Nunavut",
                          grepl("QSG",geo_loc_name)~ "Nunavut",
                          grepl("QNB",geo_loc_name)~ "Nunavut",
                          grepl("PAM",geo_loc_name)~ "Nunavut",
                          grepl("KGJ",geo_loc_name)~ "Nunavut",
                          grepl("IPI",geo_loc_name)~ "Nunavik",
                          grepl("TAH",geo_loc_name)~ "Nunavut",
                          grepl("HRN",geo_loc_name)~ "NWT",
                          grepl("HAL",geo_loc_name)~ "Nunavut",
                          grepl("GEO",geo_loc_name)~ "Nunavik",
                          grepl("FRM",geo_loc_name)~ "Nunavik",
                          TRUE ~ region))

# Add in "pop" and "region" info for ref samples:
hap_merge <- hap_merge %>% 
  mutate(region=case_when(grepl("Acad_ref",sample)~ "Acad_ref",
                          grepl("Sfont_ref", sample)~ "Sfont_ref",
                          TRUE~ region))
hap_merge <- hap_merge %>% 
  mutate(population=case_when(grepl("Acad_ref",sample)~ "Acad_ref",
                              grepl("Sfont_ref", sample)~ "Sfont_ref",
                              TRUE~ population))
hap_merge$population <- as.factor(hap_merge$population)
hap_merge$region <- as.factor(hap_merge$region)
levels(hap_merge$population) #n=66
levels(hap_merge$region)  #n=11

# Check which haplotypes are in Kerguelen samples; don't want to include here:
hap_merge %>% filter(region=="Kerguelen") %>% distinct(haplotype)
# Haplotype395, haplotype396, haplotype397, haplotype398
# Do these haplotypes occur in any non-Kerguelen inds? (if no, remove from fasta sequence)
hap_merge %>% filter(haplotype=="haplotype395" | haplotype=="haplotype396" |
                       haplotype=="haplotype397" | haplotype=="haplotype398") %>%
  distinct(population)

# Also check duplicated samples:
# "KIN1728795" is haplotype274 (fine, not singleton) and haplotype277 (remove, singleton)
# "KIN1728797" is haplotype278 (remove, singleton) and haplotype284 (remove, singleton)
# "PG015_2003_1278F" is haplotype1 and haplotype56 (both fine, not singletons)
# "PG080_2011_131F" is haplotype60 and haplotype63 (both fine, not singletons)
hap_merge %>% filter(haplotype=="haplotype274") %>% distinct(sample)
# Nope, they only occur in Kerguelen- remove and write new fasta file
# Also remove haplotype277, haplotype278, and haplotype284 (only in duplicates):
# There's a negative sample still in there too; remove (haplotype170, singleton)

# Write as fasta sequence:
library(seqinr)
hap_seqs_noKER_nodup <- hap_seqs[-c(170,277, 278,284,395,396,397,398),]
sequences_noKER_nodup <- apply(hap_seqs_noKER_nodup, 1, paste, collapse="")
seq_names_noKER_nodup <- paste0("haplotype", c(1:169,171:276, 279:283, 285:394, 399:666))
#write.fasta(sequences = as.list(sequences_noKER_nodup),
#            names = seq_names_noKER_nodup,
#            file.out = "./mitogenomes/hap_seqs_acadref_withfontacad_noKER_nodup.fasta")

# How many samples total for these haplotypes?
hap_merge %>%
  filter(!grepl("Ker",sample)) %>%
  filter(sample!="NEG") %>%
  filter(sample!="KIN1728795" & sample!="KIN1728797" & sample!="PG015_2003_1278F" & sample!="PG080_2011_131F") %>%
  tally()
str(seq_names_noKER_nodup)
# There are 1836 samples, and 658 unique haplotypes
# How many are singletons?
hap_merge %>% 
  filter(!grepl("Ker",sample)) %>%
  filter(sample!="NEG") %>%
  filter(sample!="KIN1728795" & sample!="KIN1728797" & sample!="PG015_2003_1278F" & sample!="PG080_2011_131F") %>%
  group_by(haplotype) %>% tally() %>%
  as.data.frame() %>% filter(n==1)
# 446 haplotypes are singletons (446/658*100 =~68% of haplotypes)
# 20 haplotypes occurred in >10 individuals
# 1 haplotype occurred in 401 individuals (most common by far)


# Now can tally how many of each haplotype correspond to each region (excluding KER and dups):
hap_merge_tally <- hap_merge %>%
  filter(!grepl("Ker",sample)) %>%
  filter(sample!="NEG") %>%
  filter(sample!="KIN1728795" & sample!="KIN1728797" & sample!="PG015_2003_1278F" & sample!="PG080_2011_131F") %>%
  group_by(haplotype, region) %>%
  tally() %>% as.data.frame()
#write.table(hap_merge_tally, 
#            "./mitogenomes/hap_tally_acadref_withfontacad_noKER_nodup.txt",
#            row.names=F, col.names=T, quote=F, sep="\t")
#write.table(hap_merge,
#            "./mitogenomes/hap_sample_acadref_withfontacad.txt",
#            row.names=F, col.names=T, quote=F, sep="\t")

# Convert from long to wide:
library(tidyr)
hap_merge_tally_region <- hap_merge_tally %>% 
  pivot_wider(names_from = region, values_from = n)
# Replace NAs with zeros:
hap_merge_tally_region[is.na(hap_merge_tally_region)] <- 0

# This info can now be incorporated into the nexus file for POPART
#write.csv(hap_merge_tally_region, 
#          "./mitogenomes/acadref/hap_acadrefwithfontacad_noker_nodup_tally_region.csv",
#          row.names=FALSE, quote=FALSE)


