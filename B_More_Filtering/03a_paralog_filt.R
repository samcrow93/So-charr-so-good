# This script is to determine which SNPs are likely to have reads mapped to more than one location
# This uses the .lr files output by ngsparalog
# Running on the no Ker, no dup, no lowdepth, no neg dataset (n=1827 samples)

# Start by loading in .lr files for each population:
pops =c("103", "AVA", "EG", "GEO", "IKI", "NAC", "PBP", "PG004_2011", "PG010_2013", "PG080_2002", "ROB", "TAH",
"104", "BI", "EKA", "HAL", "KIN", "NNor", "PG001_2001", "PG004_2022", "PG014_2006", "PG080_2011", "SAT", "TAS",
"109", "BLD", "ENG", "HRN", "KL19", "NOR", "PG001_2013", "PG008_2002", "PG014_2010", "QNB", "SGR", "TUG",
"AKL", "COP", "FR", "ICE", "MBB17", "PAM", "PG001_2022", "PG008_2014", "PG015_2003", "QSG", "SPI","ANA",
"CRB", "FRM", "IKA", "MBB23", "PAN", "PG004_2002", "PG010_2002", "PG015_2011", "R78", "SVG")

# Create empty df to hold all lr file data:
lr_all <- data.frame(chrom = character(),
  pos = numeric(),
  neglognulllike = numeric(),
  neglogaltlike = numeric(),
  lr_mismap = numeric(),
  pval = numeric(),
  pval.adj = numeric())


for (p in pops) {
  lr_file <- file.path(paste0(p, ".lr"))
  lr_pop <- read.table(lr_file, header=FALSE)
  # Calculate pvalue for LR mismap for each pop separately:
  lr_pop$pval <- 0.5*pchisq(lr_pop$V5,df=1,lower.tail=FALSE)
  lr_pop$pval.adj <- p.adjust(lr_pop$pval, method="bonferroni")
  # Add to lr_all df:
  lr_all <- rbind(lr_all, lr_pop)
}

colnames(lr_all) <- c("chrom", "pos", "neglognulllike", "neglogaltlike", "lr_mismap", "pval", "pval.adj")

# Make df with deviant sites to be removed:
dev.sites <- lr_all[which(lr_all$pval.adj < 0.05),c(1,2,7)]
dev.sites$locus <- paste0(dev.sites$chrom, "_", dev.sites$pos)
# Only keep list of unique deviant sites (lots of overlap among pops):
library(dplyr)
dev.sites_unique <- dev.sites %>% distinct(locus)
write.table(dev.sites_unique,"dev_sites_noker_nodup_uniq.txt", sep="\t", row.names=F, col.names=F, quote=F)

