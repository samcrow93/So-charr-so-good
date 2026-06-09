## This section describes data formatting and preparation to run Ancestry_HMM on admixed populations using reference panels of "pure" group1 and group2 (i.e. Arctic and Atlantic) individuals.

### 1) Find Ancestry Informative Markers (AIMs) for distinguishing two main groups from ngsadmix (i.e. Arctic vs. Atlantic lineages)

a) Using lists of 50 individuals that are "pure" Arctic (aka ngsadmix group1) or "pure" Atlantic (group2), run ANGSD and generate allele frequencies and counts. Use list of sites already paralog-pruned, and polarize against the reference genome so minor allele is the same for the two groups. There is a partA and partB for this step: PartA involves determining which of the loci listed in the paralog-pruned input sites list is variant across the two groups (01a_angsd_ancestryhmm_ref_maf_counts_noker.sh). Part B involves taking this newly-generated list of variant sites and calculating counts and mafs for each group separately (01b_angsd_ancestryhmm_ref_maf_counts_noker.sh).
```
for chrom in sal01 #etc
do
for GROUP in group1 group2;  # Include this line only for partB
do
sbatch --export=chrom=$chrom,GROUP=$GROUP 01a_angsd_ancestryhmm_ref_maf_counts_noker.sh ;
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

b) Next, use the maf files to figure out which have large differences in frequency between the two groups, using the 02_refpop_wrangle.R file (based off of code/script from Preckler-Quisquater et al. (2023)). This code will also filter to have just a single SNP within a given window size, as a way of reducing LD. 

c) Ultimately only want the chrom and position for each AIM, so modify the output file from the previous step as follows:
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

d) We also need allele counts for each individual at each of the AIMs for the admixed individuals we want to test. Use population-specific bamlists, easier to generate AHMM input files in subsequent steps. Run ANGSD again using the 03_angsd_ancestryhmm_admixinds_noker.sh on a per-chrom basis, using list of AIMs.
```
for pop in pop; #list pop names
do
bamlist=bams.$pop.txt;
for chrom in chrom; #list chroms
do
for win in 50kb; # Can test other window sizes if desired
do
sbatch --export=pop=$pop,bamlist=$bamlist,chrom=$chrom,win=$win 03_angsd_ancestryhmm_admixinds_noker.sh ;
done;
done;
done
```

d) Next, because in step A allele counts were generated for reference groups for all variant paralog-pruned sites (not just those later chosen as AIMs), need to subset the output counts files for each chromosome based on AIMs list (note that this is clunky, but oh well):
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

### 2) Make input files for Ancestry_HMM for each admixed population we want to analyse:
First, need to concatenate the chrom-specific AIM count files for each group:
```
for file in *group1.aims.counts* # same for group2 # This will go in numerical order based on how files are named/numbered
do
cat $file >> concat.group1.aims.counts.txt
done
```

Next, run 04a_make_ahmm_inputfile_noker.R with 04b_make_ahmm_inputfile_noker.sh to generate an input file for each admixed population of interest.

### 3) Run AncestryHMM for each admixed population of interest using the 05_ancestry_hmm_noker.sh script.









