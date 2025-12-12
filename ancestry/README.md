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
awk 'NR==FNR { rows[$1]; next } FNR in rows' $chrom.$GROUP.aims.lines.txt <(zcat ../$chrom.$GROUP.AIMref_REDO_COUNTS.counts.gz) > ../$chrom.$GROUP.aims.counts.txt
done
done
```














