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


