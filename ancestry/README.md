## This section describes data formatting and preparation to run Ancestry_HMM 

### 1) Find Ancestry Informative Markers (AIMs) for distinguishing two main groups from ngsadmix (i.e. Arctic vs. Atlantic lineages)

a) Using lists of 50 individuals that are "pure" Arctic (aka ngsadmix group1) or "pure" Atlantic (group2), run ANGSD and generate allele frequencies. Use list of sites already paralog-pruned, and polarize against the reference genome so minor allele is the same for the two groups. Do this using the angsd_ancestryhmm_ref_geno_maf.sh script on a per-chromosome basis to speed things along:
```
for chrom in sal01 #etc
do
for GROUP in group1 group2;
do
sbatch --export=chrom=$chrom,GROUP=$GROUP angsd_ancestryhmm_ref_geno_maf.sh ;
done;
done
```

Note that this script will also generate counts of each allele for each individual, which will ultimately be useful later when actually making the Ancestry_HMM input file.

b) Next, use the maf files to figure out which have large differences in frequency between the two groups, using the refpop_wrangle.R file (based off of code/script from *******CITE******). This code will also filter to have just a single SNP within a given window size, as a way of reducing LD. 

c) Ultimatley only want the chrom and position for each AIM, so modify the output file from the previous step as follows:
```
cat aims_filt_50kb_afdiff0.6.txt | cut -f 1,3 | tail -n +2 > sites/aims_sites/aims.sites
```

d) We also need allele counts for each individual at each of the AIMs for the admixed individuals we want to test. In the original ANGSD run, the counts were grouped and thus not in the individual format needed for Ancestry_HMM. Therefore, run ANGSD again using the angsd_ancestryhmm_admixinds.sh (no need to run on per-chromosome basis because list of AIMs is quite small ~2000). 

d) Next, because in step A allele counts were generated for all paralog-pruned sites (not just AIMs), need to subset the output counts files for each chromosome based on AIMs list (note that this is clunky, but oh well):
```
# First, generate separate AIMs files for each chromosome:
for chrom in sal01 #etc
do
grep $chrom sites/aims_sites/aims.sites > sites/aims_sites/chrom_aims/aims.$chrom.txt
done

# Next, generate files with only chrom and position for each chrom:
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
aims= read.table("./aims_filt_50kb_afdiff0.6.txt", header=TRUE)
aims =arrange(aims, chromo.x, position.x)  # arrange by chromosome and position
# Load in aims counts for each group:
group1_aims= read.table("./concat.group1.aims.counts.txt", header=F)
group2_aims= read.table("./concat.group2.aims.counts.txt", header=F)
colnames(group1_aims)=c("A", "C", "G", "T")
colnames(group2_aims)=c("A", "C", "G", "T")
# Bind together:
group1_aims_full= cbind(aims, group1_aims)
group2_aims_full= cbind(aims, group2_aims)
# Mutate new columns where the allele counts from major and minor alleles are 'chosen' from the column specifying the major and minor alleles for each site:
group1_aims_maj_min = group1_aims_full %>% rowwise() %>% mutate(major=get(major.x), minor=get(minor.x)) %>% ungroup() %>% select(chromo.x, positio
n.x,major, minor) %>% as.data.frame()
group2_aims_maj_min = group2_aims_full %>% rowwise() %>% mutate(major=get(major.x), minor=get(minor.x)) %>% ungroup() %>% select(chromo.x, positio
n.x,major, minor) %>% as.data.frame()

# Merge together to form the first six columns of the input file:
group1_2_aims_maj_min = merge(group1_aims_maj_min, group2_aims_maj_min, by=c("chromo.x", "position.x")
colnames(group1_2_aims_maj_min) = c("chrom", "pos", "major_group1", "minor_group1", "major_group2", "minor_group2")

# For 7th column, need distance in Morgans between previous marker and given position. There isn't a linkage map for charr, so approximate (FOR NOW) with 1.1cM/MB constant rate:
rec_rate_cM_MB=1.1
group1_2_aims_maj_min_dist = group1_2_aims_maj_min %>% arrange(chrom,pos) %>% group_by(chrom) %>% mutate(dist_bp = pos -lag(pos), dist_bp = ifelse(is.na(dist_bp), 0, dist_bp), dist_M = dist_bp / 1e6 * rec_rate_cM_MB/100) %>% ungroup() %>% as.data.frame()

# Next, need to load in individual counts for the AIMs for the admixed inds:
admix_aims = read.table("../samples/charr_group3_aims.counts.gz", header=TRUE)

# Need to do the same thing with the admix_aims df to get only the counts for maj and min alleles at each AIM:
admix_aims_full= cbind(aims, admix_aims)

# Mutate new major and minor columns for each ind:
admix_aims_maj_min = admix_aims_full %>%
  rowwise() %>%
  mutate(across(everything(), ~ .)) # just to keep rowwise active

for(ind in inds) {
  admix_aims_maj_min <- admix_aims_maj_min %>%
    mutate(
      !!paste0(ind, "_maj") := get(paste0(ind, "_", major.x)),
      !!paste0(ind, "_min") := get(paste0(ind, "_", minor.x))
    )
}
# Convert to df
admix_aims_maj_min = as.data.frame(admix_aims_maj_min)

# Separate out inds major/minor only:
inds= admix_aims_maj_min[,-c(1:16)]

# Combine with group1_2_aims_maj_min_dist:
ancestry_hmm_input = cbind(group1_2_aims_maj_min_dist, inds)

# Write file!
write.table(ancestry_hmm_input, "ancestry_hmm_input_test.txt", row.names = FALSE, sep = "\t", quote=FALSE)
write.table(ancestry_hmm_input, "ancestry_hmm_input_test_noheader.txt", row.names = FALSE, sep = "\t", quote=FALSE, col.names=F) # might need without header
```








