# This section describes how to filter dataset further based on:
## 1) Identifying and excluding likely paralogous loci;
## 2) Removing SNPs in sex-linked regions
\
### 1) Identifying likely paralogous loci using ngsParalog (Linderoth 2018)
### A couple steps to this:
### a) ngsParalog only accepts samtools-generated mpileup files as input, so need to generate mpileup files
- Generating mpileup files with samtools for this dataset is VERY slow
- To speed things up a bit, divide each chromosome into multiple sets of loci and run with separate jobs
- e.g. for sal01, use the following code to generate sets with 4000 SNPs each:
```
# First, generate list of sites for which GLs were generated in ANGSD run:
zcat sal01_filt.pos.gz | cut -f1,2 | tail -n +2 > sites/sites1.list

# Next, split this sites list into multiple smaller sites lists:
split -l 4000 -d sites1.list sites1.set

# Rename set files so the names are less unwieldy:
for file in sites1.set*; do new_name=$(echo "$file" | sed 's/^sites1\.//'); mv "$file" "$new_name"; done
```

- Then, submit the mpileup1_sets.sh script as follows:
```
for i in {##..##}; do sbatch --export=ALL,set=set$i mpileup1_sets.sh ; done
```
