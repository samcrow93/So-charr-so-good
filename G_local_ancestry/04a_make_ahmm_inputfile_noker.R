## This file is for generating the input file needed for Ancestry HMM
## Make one input file for each admixed population of interest
## Script is written so that it can be run on any population (POP) for AIMs spaced by any distance (WIN) with any allele freq diff cutoff (AF)

# Specify $POP and $WIN variables called in shell script:
args <- commandArgs(trailingOnly = TRUE)
POP <- args[1]
WIN <- args[2]
AF <- args[3]

print(POP)
print(WIN)
print(AF)

library(dplyr)

# Load in reference panel data:
aims.WIN.AF <- read.table(file.path("/home/samcrow/scratch/charr/ahmm/noker/refs", paste0("aims.filt.",WIN,".", AF, ".txt")), header=TRUE)
aims.WIN.AF =arrange(aims.WIN.AF, chromo.x, position.x)  # arrange by chromosome and position

# Load in counts of AIMs for each reference group (group1 is Arctic, group2 is Atlantic):
group1_aims.WIN.AF = read.table(file.path("/home/samcrow/scratch/charr/ahmm/noker/refs/ref_aims_counts", paste0("concat.group1.aims.counts.", WIN, ".", AF, ".txt")), header=F)
group2_aims.WIN.AF = read.table(file.path("/home/samcrow/scratch/charr/ahmm/noker/refs/ref_aims_counts", paste0("concat.group2.aims.counts.", WIN, ".", AF, ".txt")), header=F)
colnames(group1_aims.WIN.AF)=c("A", "C", "G", "T")
colnames(group2_aims.WIN.AF)=c("A", "C", "G", "T")
# Bind together:
group1_aims_full.WIN.AF= cbind(aims.WIN.AF, group1_aims.WIN.AF)
group2_aims_full.WIN.AF= cbind(aims.WIN.AF, group2_aims.WIN.AF)

# Mutate new columns where the allele counts from major and minor alleles are 'chosen' from the column specifying the major and minor alleles for each site (i.e. when major allele is A and minor is C, choose counts from A and C columns respectively)
group1_aims_maj_min.WIN.AF = group1_aims_full.WIN.AF %>% rowwise() %>% mutate(major=get(major.x), minor=get(minor.x)) %>% ungroup() %>% select(chromo.x, position.x,major, minor) %>% as.data.frame()
group2_aims_maj_min.WIN.AF = group2_aims_full.WIN.AF %>% rowwise() %>% mutate(major=get(major.x), minor=get(minor.x)) %>% ungroup() %>% select(chromo.x, position.x,major, minor) %>% as.data.frame()

# Merge together to form the first six columns of the input file:
group1_2_aims_maj_min.WIN.AF = merge(group1_aims_maj_min.WIN.AF, group2_aims_maj_min.WIN.AF, by=c("chromo.x", "position.x"))
colnames(group1_2_aims_maj_min.WIN.AF) = c("chrom", "pos", "major_group1", "minor_group1", "major_group2", "minor_group2")
# Need to arrange by chromosome and position again (even though done again in next step for recombination rate calculation too):
group1_2_aims_maj_min.WIN.AF =arrange(group1_2_aims_maj_min.WIN.AF, chrom, pos)

# For 7th column, need distance in Morgans between previous marker and given position. There isn't a linkage map for this genome, so approximate with 1.1cM/MB constant rate:
rec_rate_cM_MB=1.1
group1_2_aims_maj_min_dist.WIN.AF = group1_2_aims_maj_min.WIN.AF %>% arrange(chrom,pos) %>% group_by(chrom) %>% mutate(dist_bp = pos -lag(pos), dist_bp = ifelse(is.na(dist_bp), 0, dist_bp), dist_M = dist_bp / 1e6 * rec_rate_cM_MB/100) %>% ungroup() %>% as.data.frame()

# Next, need to load in individual counts for the AIMs for the admixed inds:
admix_aims.WIN.AF.POP = read.table(file.path("/home/samcrow/scratch/charr/ahmm/noker/samples", WIN, AF, POP, paste0("concat.ahmm.", POP, ".samples.", WIN, ".", AF, ".counts.txt")), header=TRUE)

# IMPORTANT! Not all aims in ref pops may be in admixed pops (could have been exluded due to map quality or other filters etc.) So, need to also load in positions of sites in admixed pops and subset the ref panel aims to these ones:
admix_aims.WIN.AF.POP.pos = read.table(file.path("/home/samcrow/scratch/charr/ahmm/noker/samples", WIN, AF, POP, paste0("concat.ahmm.", POP, ".samples.", WIN, ".", AF, ".pos.txt")), header=TRUE)
# Get rid of total depth column:
admix_aims.WIN.AF.POP.pos = admix_aims.WIN.AF.POP.pos[,-3]
colnames(admix_aims.WIN.AF.POP.pos) = c("chrom", "pos")

# Merge together, keeping only those in pos file (i.e. variants in admixed pop):
group1_2_aims_maj_min_dist.WIN.AF.POP = merge(group1_2_aims_maj_min_dist.WIN.AF, admix_aims.WIN.AF.POP.pos, by=c("chrom", "pos"),all.x=FALSE, all.y=TRUE)
# Arrange by chrom and pos again:
group1_2_aims_maj_min_dist.WIN.AF.POP = arrange(group1_2_aims_maj_min_dist.WIN.AF.POP, chrom, pos)

# Need to also get only the counts for maj and min alleles at each AIM for admixed pops:
# Bind together with original aims file that contains maj/min allele info (both are arranged by chrom and pos already, okay to cbind):
admix_aims.WIN.AF.POP.maj_min = cbind(aims.WIN.AF, admix_aims.WIN.AF.POP)

# Mutate new major and minor columns for each ind in admixed pop:
# Get total number of inds in admixed pop:
ninds=ncol(admix_aims.WIN.AF.POP)/4
inds <- paste0("ind", 0:(ninds - 1))

aims.WIN.AF.POP.maj.min.all <- admix_aims.WIN.AF.POP.maj_min

for(ind in inds) {
  aims.WIN.AF.POP.maj.min.all <- aims.WIN.AF.POP.maj.min.all %>%
rowwise() %>%
    mutate(
      !!paste0(ind, "_maj") := get(paste0(ind, "_", major.x)),
      !!paste0(ind, "_min") := get(paste0(ind, "_", minor.x))
    ) %>% as.data.frame()
}

# Convert to df:
aims.WIN.AF.POP.maj.min.all <- as.data.frame(aims.WIN.AF.POP.maj.min.all)

# Separate out inds major/minor only:
# Only want columns 1 and 3 (chrom and pos), and then maj/min cols for each ind (ninds*2 cols at end of df)
inds.WIN.AF.POP <- cbind(aims.WIN.AF.POP.maj.min.all[,c(1,3)],aims.WIN.AF.POP.maj.min.all[, (ncol(aims.WIN.AF.POP.maj.min.all) - ninds * 2 + 1):ncol(aims.WIN.AF.POP.maj.min.all)])
colnames(inds.WIN.AF.POP)[1:2] = c("chrom", "pos")

# Combine with group1_2_aims_maj_min_dist:
ahmm_input.WIN.AF.POP = merge(group1_2_aims_maj_min_dist.WIN.AF.POP, inds.WIN.AF.POP, by=c("chrom", "pos"))

# Get rid of bp dist column:
ahmm_input.WIN.AF.POP= ahmm_input.WIN.AF.POP[,-7]

# Arrange one last time by chrom and pos:
ahmm_input.WIN.AF.POP = arrange(ahmm_input.WIN.AF.POP, chrom, pos)

# Write file!
outfile=file.path("/home/samcrow/scratch/charr/ahmm/noker/inputs", WIN, AF, POP, paste0("ahmm.input.", POP, ".", WIN, ".", AF, ".txt"))
write.table(ahmm_input.WIN.AF.POP, outfile, row.names = FALSE, col.names=FALSE,quote=FALSE,sep="\t")
