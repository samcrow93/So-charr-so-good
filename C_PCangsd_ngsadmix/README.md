## PCANGSD and NGSadmix

### 1) PCANGSD
Using the beagle files with very low-depth samples removed, run PCANGSD on a per-chromosome basis as well as genome-wide on all chromosomes concatenated together




### 3) ngsAdmix
a) Run ngsadmix on multiple values of K, with 6 replicates for each. K values chosen are 2-8, as well as 16, 24, 32, 42, 51- these will ideally look at structure at broader level of glacial lineage (expected to have K=2 or 3 groups), working up to the number of sampling locations in the dataset.
```
# Submit script ngsadmix_bigkbld_morek.sh as follows:
for kvalue in 2 3 4 5 6 7 8 16 24 32 42 51
do
for replicate in 1 2 3 4 5 6
do
sbatch --export=kvalue=$kvalue,replicate=$replicate ngsadmix_bigkbld_morek.sh
done
done
```

b) Evaluate which value of K is best, using approach described in https://baylab.github.io/MarineGenomics/week-9-population-structure-using-ngsadmix.html, which also refers to using this site: https://clumpak.tau.ac.il/bestK.html

First, need to rename .out files from ngsadmix so they contain the Kvalue and replicate numbers i.e. ngsadmix_ldpruned_bigkb_para_subsamp_k2.1.out.
Next, load into R and process as follows:
```
# List all .out files to checkk all is good:
files<-list.files("./", pattern = ".out", full.names = T)

# Load in all files at once:
all_files<-lapply(1:36, FUN = function(i) readLines(files[i]))

# Find the line that starts with "b" (for "best like")
library(stringr)
likes_lines<-sapply(1:36, FUN= function(x) all_files[[x]][which(str_sub(all_files[[x]], 1, 1) == 'b')])

# Print only the actual log-likelihoods (keep decimals and change to absolute value)
numbers <- regmatches(likes_lines, regexpr("(?<=like=)-?\\d+\\.?\\d*", likes_lines, perl = TRUE))
abs_numbers <- abs(as.numeric(numbers))

# Create df that has K values and log likelihoods:
logs=data.frame(K = rep(2:7, each=6))
logs$like= abs_numbers

# Calculate delta K:
tapply(logs$like, logs$K, FUN= function(x) mean(abs(x))/sd(abs(x)))

# Largest delta K value indicates best one
```










