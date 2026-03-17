## This section describes data formatting and preparation to run Ancestry_HMM 

### 1) Find Ancestry Informative Markers (AIMs) for distinguishing two main groups from ngsadmix (i.e. Arctic vs. Atlantic lineages)

a) Using lists of 50 individuals that are "pure" Arctic (aka ngsadmix group1) or "pure" Atlantic (group2), run ANGSD and generate allele frequencies and counts. Use list of sites already paralog-pruned, and polarize against the reference genome so minor allele is the same for the two groups. Do this using the angsd_ancestryhmm_ref_maf_counts.sh script on a per-chromosome basis to speed things along:
```
for chrom in sal01 #etc
do
for GROUP in group1 group2;
do
sbatch --export=chrom=$chrom,GROUP=$GROUP angsd_ancestryhmm_ref_maf_counts.sh ;
done;
done
```

After this, need to concatenate all the chrom maf files for each group:
```
# Add header to new concat file (do the same for group2):
zcat sal01.group1.AIMref.mafs.gz | head -n 1 > concat.group1.mafs.txt
# Then loop through files, remove header and append to concat file:
for chrom in sal01 sal02 #etc
do
zcat $chrom.group1.AIMref.mafs.gz | tail -n +2 >> concat.group1.mafs.txt;
done
```

b) Next, use the maf files to figure out which have large differences in frequency between the two groups, using the refpop_wrangle.R file (based off of code/script from *******CITE******). This code will also filter to have just a single SNP within a given window size, as a way of reducing LD. 

c) Ultimatley only want the chrom and position for each AIM, so modify the output file from the previous step as follows:
```
cat aims_filt_50kb_afdiff0.6.txt | cut -f 1,3 | tail -n +2 > sites/aims_sites/aims.sites

# Also generate per-chrom lists of AIM sites:
for chrom in sal01 sal02 sal03;  # etc
do
grep $chrom aims.50kb.sites > $chrom.aims.50kb.sites;
done

# Index these sites files for ANGSD:
for file in *;
do
angsd sites index $file;
done
```

d) We also need allele counts for each individual at each of the AIMs for the admixed individuals we want to test. Use population-specific bamlists, easier to generate AHMM input files in subsequent steps. Run ANGSD again using the angsd_ancestryhmm_admixinds.sh on a per-chrom basis, using list of AIMs.
```
for pop in pop;
do
bamlist=bams.$pop.txt;
for chrom in chrom;
do
for win in 50kb 100kb;
do
sbatch --export=pop=$pop,bamlist=$bamlist,chrom=$chrom,win=$win angsd_ancestryhmm_admixinds.sh ;
done;
done;
done
```

d) Next, because in step A allele counts were generated for reference groups for all paralog-pruned sites (not just AIMs), need to subset the output counts files for each chromosome based on AIMs list (note that this is clunky, but oh well):
```
# Generate files with only chrom and position for each chrom:
for chrom in sal01 #etc.
do
for GROUP in group1 group2
do
zcat $chrom.$GROUP.AIMref.pos.gz | cut -f1,2 | tail -n +2 > aim_wrangling/$chrom.$GROUP.pos_mod.txt
done
done

# Then, print the row numbers of where AIMs appear in the modified pos files for each chromosome.
# The rationale here is that the .pos.gz files and the .counts.gz files have the same number of rows, but the .counts.gz files do not list the actual positions.
# So, this is a way to get at ultimately subsetting the .counts.gz files for only AIMs.
# From aim_wrangling directory, make lists of aims lines:
for chrom in sal01 #etc.
do
for GROUP in group1 group2
do
awk -F'\t' 'NR==FNR{m[$0]=FNR; next} $0 in m{print m[$0]}' $chrom.$GROUP.pos_mod.txt ../sites/aims_sites/chrom_aims/aims.$chrom.txt > $chrom.$GROUP.aims.lines.txt
done
done

# And lastly actually subset the counts files for only the AIMs:
for chrom in sal01 #etc
do
for GROUP in group1 group2
do
awk 'NR==FNR { rows[$1]; next } FNR in rows' $chrom.$GROUP.aims.lines.txt <(zcat ../$chrom.$GROUP.AIMref_REDO_COUNTS.counts.gz | tail -n +2) > ../$chrom.$GROUP.aims.counts.txt
done
done
```

### 2) Make input files for Ancestry_HMM
The first two columns of the input file are the chrom and position of each AIM; this is the aims.sites file. The next 4 columns are (pooled) counts of major and minor alleles for both reference panels (i.e. group1 and group2). So first, need to concatenate the chrom-specific AIM count files for each group:
```
for file in *group1.aims.counts* # same for group2
do
at $file >> concat.group1.aims.counts.txt
done
```

Okay this is complicated ugh, also need to modify originally-generated aims table to figure out which are the major and minor alleles at each aim locus:
```
# In R:
library(dplyr)
aims_100kb= read.table("/home/samcrow/scratch/charr/ahmm_round3/refs/aims_filt_100kb_afdiff0.6.txt", header=TRUE)
aims_100kb =arrange(aims_100kb, chromo.x, position.x)  # arrange by chromosome and position
# Load in aims counts for each group:
group1_aims_100kb = read.table("/home/samcrow/scratch/charr/ahmm_round3/refs/ref_aims_counts/100kb/concat.group1.aims.counts.100kb.txt", header=F)
group2_aims_100kb = read.table("/home/samcrow/scratch/charr/ahmm_round3/refs/ref_aims_counts/100kb/concat.group2.aims.counts.100kb.txt", header=F)
colnames(group1_aims_100kb)=c("A", "C", "G", "T")
colnames(group2_aims_100kb)=c("A", "C", "G", "T")
# Bind together:
group1_aims_full_100kb= cbind(aims_100kb, group1_aims_100kb)
group2_aims_full_100kb= cbind(aims_100kb, group2_aims_100kb)
# Mutate new columns where the allele counts from major and minor alleles are 'chosen' from the column specifying the major and minor alleles for each site (i.e. when major allele is A and minor is C, choose counts from A and C columns respectively)
group1_aims_maj_min_100kb = group1_aims_full_100kb %>% rowwise() %>% mutate(major=get(major.x), minor=get(minor.x)) %>% ungroup() %>% select(chromo.x, positio
n.x,major, minor) %>% as.data.frame()
group2_aims_maj_min_100kb = group2_aims_full_100kb %>% rowwise() %>% mutate(major=get(major.x), minor=get(minor.x)) %>% ungroup() %>% select(chromo.x, positio
n.x,major, minor) %>% as.data.frame()

# Merge together to form the first six columns of the input file:
group1_2_aims_maj_min_100kb = merge(group1_aims_maj_min_100kb, group2_aims_maj_min_100kb, by=c("chromo.x", "position.x"))
colnames(group1_2_aims_maj_min_100kb) = c("chrom", "pos", "major_group1", "minor_group1", "major_group2", "minor_group2")
# Need to arrange by chromosome and position again (even though done again in next step for recombination rate calculation too):
group1_2_aims_maj_min_100kb =arrange(group1_2_aims_maj_min_100kb, chrom, pos)

# For 7th column, need distance in Morgans between previous marker and given position. There isn't a linkage map for this genome, so approximate with 1.1cM/MB constant rate:
rec_rate_cM_MB=1.1
group1_2_aims_maj_min_dist_100kb = group1_2_aims_maj_min_100kb %>% arrange(chrom,pos) %>% group_by(chrom) %>% mutate(dist_bp = pos -lag(pos), dist_bp = ifelse(is.na(dist_bp), 0, dist_bp), dist_M = dist_bp / 1e6 * rec_rate_cM_MB/100) %>% ungroup() %>% as.data.frame()

# Next, need to load in individual counts for the AIMs for the admixed inds:
# For ANA pop, for exampe:
admix_aims_100kb_ANA = read.table("/home/samcrow/scratch/charr/ahmm_round3/samples/100kb/ANA/concat.ahmm.ANA.samples.100kb.counts.txt", header=TRUE)

# IMPORTANT! Not all aims in ref pops may be in admixed pops (could have been exluded due to map quality or other filters etc.) So, need to also load in positions of sites in admixed pops and subset the ref panel aims to these ones:
admix_aims_100kb_ANA_pos = read.table("/home/samcrow/scratch/charr/ahmm_round3/samples/100kb/ANA/concat.ahmm.ANA.samples.100kb.pos.txt", header=TRUE)
# Get rid of total depth column:
admix_aims_100kb_ANA_pos = admix_aims_100kb_ANA_pos[,-3]
colnames(admix_aims_100kb_ANA_pos) = c("chrom", "pos")

# Merge together, keeping only those in pos file (i.e. variants in admixed pop):
group1_2_aims_maj_min_dist_100kb_ANA = merge(group1_2_aims_maj_min_dist_100kb, admix_aims_100kb_ANA_pos, by=c("chrom", "pos"),all.x=FALSE, all.y=TRUE)
# Arrange by chrom and pos again:
group1_2_aims_maj_min_dist_100kb_ANA = arrange(group1_2_aims_maj_min_dist_100kb_ANA, chrom, pos)

# Need to also get only the counts for maj and min alleles at each AIM for admixed pops:
# Bind together with original aims file that contains maj/min allele info (both are arranged by chrom and pos already, okay to cbind):
admix_aims_100kb_ANA_maj_min = cbind(aims_100kb, admix_aims_100kb_ANA)

# Mutate new major and minor columns for each ind in admixed pop:
inds=c("ind0", "ind1", "ind2", "ind3", "ind4", "ind5", "ind6", "ind7", "ind8", "ind9", "ind10", "ind11", "ind12", "ind13", "ind14", "ind15", "ind16", "ind17", "ind18", "ind19", "ind20", "ind21", "ind22", "ind23", "ind24", "ind25", "ind26", "ind27", "ind28", "ind29", "ind30", "ind31", "ind32", "ind33", "ind34", "ind35", "ind36", "ind37", "ind38", "ind39") # Change number depending on pop

aims_ANA_maj_min_100kb_all <- admix_aims_100kb_ANA_maj_min

for(ind in inds) {
  aims_ANA_maj_min_50kb_all <- aims_ANA_maj_min_50kb_all %>%
rowwise() %>%
    mutate(
      !!paste0(ind, "_maj") := get(paste0(ind, "_", major.x)),
      !!paste0(ind, "_min") := get(paste0(ind, "_", minor.x))
    ) %>% as.data.frame()
}

# Convert to df:
aims_ANA_maj_min_100kb_all <- as.data.frame(aims_ANA_maj_min_100kb_all)

# Separate out inds major/minor only:
inds_ANA_100kb= aims_ANA_maj_min_100kb_all[,c(1,3,97:136)] # For df with 136 columns and 20 inds, keep 97-136
colnames(inds_ANA_100kb)[1:2] = c("chrom", "pos")

# Combine with group1_2_aims_maj_min_dist:
ahmm_input_ANA_100kb = merge(group1_2_aims_maj_min_dist_100kb_ANA, inds_ANA_100kb, by=c("chrom", "pos"))

# Get rid of bp dist column:
ahmm_input_ANA_100kb= ahmm_input_ANA_100kb[,-7]

# Arrange one last time by chrom and pos:
ahmm_input_ANA_100kb = arrange(ahmm_input_ANA_100kb, chrom, pos)

# Write file!
write.table(ahmm_input_ANA_100kb, "/home/samcrow/scratch/charr/ahmm_round3/inputs/100kb/ANA/ahmm.input.ANA.100kb.txt", row.names = FALSE, sep = "\t", quote=FALSE, col.names=F) # need without header
```








