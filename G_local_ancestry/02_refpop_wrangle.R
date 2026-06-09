# This code is adapted from Preckler-Quisquater et al. (2023)
# Note that this was run interactively on CC (hence lack of file paths)

# Read in maf files for each group:
group1ref <- read.table("concat.group1.mafs.txt", header = TRUE)
group2ref <- read.table("concat.group2.mafs.txt", header = TRUE)

# Create chromo_pos column:
group1ref$chromo_pos <- paste0(group1ref$chromo,'_',group1ref$position)
group2ref$chromo_pos <- paste0(group2ref$chromo,'_',group2ref$position)

# Merge group1 and group2 maf files together by chromo_pos col
group1_2_merge <- merge(group1ref, group2ref, by = "chromo_pos", all = TRUE)

library(dplyr)
# Select only sites that have data for both groups and at least 40 inds per group with data:
group1_2_merge_min40 <- group1_2_merge %>% filter(nInd.x > 39) %>% filter(nInd.y > 39)

# Calculate the absolute value difference in minor allele frequencies at these sites for the two groups
group1_2_merge_min40$af_diff <- abs(group1_2_merge_min40$knownEM.x - group1_2_merge_min40$knownEM.y)

# Filter for sites with absolute maf difference of at least 0.6
group1_2_merge_min40_afdiff0.6 <- filter(group1_2_merge_min40, af_diff > 0.6 )

# Prune markers to 1 per 50kb
library(tidyverse)
library(data.table)

chr = c("sal01", "sal02", "sal03", "sal04", "sal05", "sal06", "sal07", "sal08", "sal09", "sal10", "sal11", "sal12", "sal13", "sal14", "sal15", "sal16", "sal17", "sal18", "sal19", "sal20", "sal21", "sal22", "sal23", "sal24", "sal25", "sal26", "sal27", "sal28", "sal29", "sal30", "sal31", "sal32", "sal33", "sal34", "sal35", "sal36", "sal37", "sal38", "sal39")

group1_2_afdiff0.6_dt <- as.data.table(group1_2_merge_min40_afdiff0.6)
setorder(group1_2_afdiff0.6_dt, chromo.x, position.x)

aims_filt_50kb <- group1_2_afdiff0.6_dt[, {
  keep <- logical(.N)
  last_pos <- -Inf
  for (i in seq_len(.N)) {
    if (position.x[i] - last_pos >= 50000) {
      keep[i] <- TRUE
      last_pos <- position.x[i]
    }
  }
  .SD[keep]
}, by = chromo.x]

# Filter only for bi-allelic SNPs across the two reference pops:
aims_filt_50kb_bi <- aims_filt_50kb %>% filter(minor.x == minor.y)

# Write file:
write.table(aims_filt_50kb_bi, "aims_filt_50kb_afdiff0.6.txt", row.names = FALSE, sep = "\t", quote=FALSE)




