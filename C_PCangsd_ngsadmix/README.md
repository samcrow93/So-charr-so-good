## PCANGSD and NGSadmix

### 1) PCANGSD
Using the beagle files with very low-depth samples removed, run PCANGSD on a per-chromosome basis as well as genome-wide on all chromosomes concatenated together.

A) First, need to create a virtual environment to run python. Create this virtual environment under the /home/samcrow directory:
```
virtualenv --no-download python_env

# Load python interpreter:
module load StdEnv/2020 python/3.10.2

# Activate the virtual environment:
source python_env/bin/activate

# Upgrade pip in the environment:
pip install --no-index --upgrade pip

# Install latest version of Numpy:
pip install numpy --no-index

# To deactivate virtual environment:
deactivate
```

B) Next, actually run PCANGSD on each chromosome and on concatenated file using scripts 01_pcangsd_concat.sh and 02_pcangsd_lowfilt_chroms.sh:
```
# To submit on all chroms separately
for chrom in sal01 sal02 # etc to sal39
do
sbatch --export=chrom=$chrom 02_pcangsd_lowfilt_chroms.sh
done
```


### 2) NGSadmix
A) Run ngsadmix on multiple values of K, with 6 replicates for each. K values chosen are 2-8. These will look at upper levels structure at broader level of glacial lineage. Do this using script 03_ngsadmix_bigkbld_morek.sh
```
# Submit script 03_ngsadmix_bigkbld_morek.sh as follows:
for kvalue in 2 3 4 5 6 7 8 
do
for replicate in 1 2 3 4 5 6 7 8 9 10
do
sbatch --export=kvalue=$kvalue,replicate=$replicate 03_ngsadmix_bigkbld_morek.sh
done
done
```

B) Evaluate which value of K is best, using approach described in https://baylab.github.io/MarineGenomics/week-9-population-structure-using-ngsadmix.html, which also refers to using this site: https://clumpak.tau.ac.il/bestK.html

First, need to rename .out files from ngsadmix so they contain the Kvalue and replicate numbers i.e. noker.k2.1.out.
Next, load into R and process as follows:
```
# List all .out files to checkk all is good:
# 10 replicates of Kvalues 2-8 (70 files total):
files<-list.files("./", pattern = ".log", full.names = T)

# Load in all files at once:
all_files<-lapply(1:70, FUN = function(i) readLines(files[i]))

# Find the line that starts with "b" (for "best like")
library(stringr)
likes_lines<-sapply(1:70, FUN= function(x) all_files[[x]][which(str_sub(all_files[[x]], 1, 1) == 'b')])

# Print only the actual log-likelihoods (keep decimals and change to absolute value)
numbers <- regmatches(likes_lines, regexpr("(?<=like=)-?\\d+\\.?\\d*", likes_lines, perl = TRUE))
abs_numbers <- abs(as.numeric(numbers))

# Create df that has K values and log likelihoods:
logs=data.frame(K = rep(2:8, each=10))
logs$like= abs_numbers

# Calculate delta K:
tapply(logs$like, logs$K, FUN= function(x) mean(abs(x))/sd(abs(x)))

# Largest delta K value indicates best one

# Format so R keeps 3 decimal places for CLUMPAK:
logs$like = format(round(logs$like, 3), nsmall = 3)
```

Also need to take average of Q values from across 10 replicate runs for each value of K:
```
k2.1 = read.table("charr_bigkb_para_subsamp.2.1.qopt", header=FALSE) # repeat for each replicate and kvalue
k2.1$sample_order= row.names(k2.1)
# Annoyingly, ngsadmix does not always output the same group 1st in the qopt file- need to view the heads of each and rename columns accordingly
# This is because I ran ngsadmix in a few separate runs (i.e. K=2 by itself, then K=3-6, then K=7-10)
# Always set group1 to be the larger-proportioned group in the first sample
head(k2.1)
colnames(k2.1) = c("group1", "group2", "sample_order")

# Then bind all replicate dfs together:
k2_all_long = rbind(k2.1, k2.2, k2.3, k2.4, k2.5, k2.6, k2.7, k2.8, k2.9, k2.10)
# Check the 'polarizing' of groups is correct (expect qvalues to be relatively consistent across groups for each sample):
k2_all_long %>% filter(sample_order=="1")

# Calculate mean group1 and group2 Qvalues for each sample:
k2_means = k2_all_long %>% group_by(sample_order) %>% summarize(mean_group1= mean(group1), mean_group2= mean(group2)) %>% as.data.frame()

# Write file:
write.table(k2_means, "k2_means.txt", row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t")
```












