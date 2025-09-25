## This section outlines steps taken from processing raw fastq files through to generation of genotype likelihoods
### Note that this readme file describes workflow for main batch of samples (designated as "NL" in script naming etc.), however there is another batches of samples (published data (Dallaire et al. 2023 Genome Biology and Evolution) downloaded from the NCBI sequence read archive, n=517 samples available as of late 2024 for BioProject accession PRJNA1031558) that were processed using similar scripts.
### Also note that due to the very large size of this dataset, a number of steps had to be repeated due to jobs failing out from lack of time and/or memory for certain samples (especially the alignment step).

### 1.0) Create parameters file (charr_WGS_params_main.txt)
The following text is within the parameters file (specify where software and genome is located):

```
#locations
#main directory for project (where raw fastq files are stored)
projdir=/path_to_files/

#genome file location
genome=/path_to_genome

#genus
genus=$(echo Salvelinus)

#software
#trimming
fastp=/home/samcrow/programs/fastp
```

### 2.0) Read Trimming
Use job script 01_fastp.sh

### 3.0) Index Genome
Run script 02_index_genome.sh

### 4.0) Alignment
Trimmed fastq files are quite large, so run each sample as a separate job

4.1) Create Sets
Create set files that each contain one sample name as follows:
```
# Create list of sampled names:
ls *R1.trimmed.fastq.gz | \
 sed 's/\_R1.trimmed.fastq.gz//' > sets/charr_NL_inds.tsv

# Split samples into one per set file:
split -l 1 \
 -d \
../sets/charr_NL_inds.tsv \
../sets/NL_sets/charr_NL.set
```

4.2) Submit alignment jobs
Submit 03_bwamem_align_NL.sh script as follows:
```
for i in {00..#total_align_sets}
do
sbatch --export=ALL,set=charr_NL.set$i,paramfile=charr_WGS_params_main.txt 03_bwamem_align_NL.sh
done
```

### 5.0) Refining alignments - Preparation
Use the genome analysis toolkit (gatk) to remove sequence duplicates.
First, need to create a directory for the temporary files made by gatk:
```
mkdir gatktemp
```

Create different set of set files for dedup steps (much quicker than alignment, so can have more samples in each set i.e. more samples per individual job)
```
# Use same file list as before:
split -l 100 \
 -d \
../sets/charr_NL_inds.tsv \
../sets/NL_dedup_index/NL_dupindex.set
```

Next, submit the 04_mark_dups_NL.sh jobscript as follows:
```
for i in {00..#total_dedup_sets}
do
sbatch --export=ALL,set=NL_dupindex.set$i,paramfile=charr_WGS_params_main.txt 04_mark_dups_NL.sh
done
```

The deduplicated alignment files also needs to be indexed (using the 05_index_dedup.sh script):
```
for i in {00..#total_dedup_sets)
do
sbatch --export=ALL,set=NL_dupindex.set$i,paramfile=charr_WGS_params_main.txt 05_index_dedup.sh
done
```

### 6.0) Refining alignments- indel realignment
First, need to identify realignment targets using GATK (deprecated version) using 06_indel_target.sh script:
```
for i in {00..#total_dedup_sets}
do
sbatch --export=ALL,set=NL_dupindex.set$i,paramfile=charr_WGS_params_main.txt 06_indel_target.sh
done
```

Then, actually update the alignments (using 07_indel_realign.sh script):
```
for i in {00..#total_align_sets}
do
sbatch --export=ALL,set=charr_NL.set$i,paramfile=charr_WGS_params_main.txt 07_indel_realign.sh
done
```

### 7.0 Genotype likelihoods using ANGSD
### 7.1) Create ANGSD parameters file called angsd_params.txt with the following parameters:
```
bamfile=/home/samcrow/scratch/charr_wgs/all_charr/scripts/bamlist.tsv
runname=charr
minInd=1540
minDepth=3850
```

### 7.2 Create bamlist.tsv file (list of all bamfiles (n=1920)- note that this includes 4 duplicate samples as well as negatives)
```
ls /path_to_bams/*.realigned.bam > bamlist.tsv
```

Also need to create list of chromosomes (get from genome) 
```
cut -f1 /path_to_genome/genome.fna.fai | grep "sal" > chromsnuc
```

### 7.3) Run ANGSD
Submit 08_angsd_chromos.sh script as follows:
```
while read chromsnuc
do
sbatch --export=ALL,chromsnuc=$chromsnuc,paramfile=charr_WGS_params_main.txt,angsdparam=angsd_params.txt 08_angsd_chromos.sh
done < chromsnuc
```

## HOWEVER: MISTAKES WERE MADE
It turns out that there was originally a typo in my angsd_params.txt file:
The 'minInd' variable was actually spelled as 'midInd'
Apparently, ANGSD will not fail out if it cannot find that variable, but instead will just carry on and not do any filtering based on coverage at each site across individuals....

SO

### 8.0 Re-Run ANGSD
This next ANGSD run includes the same parameters as the first, but now also includes the minInd filter
Additionally, I limit the sites to only those output in the first run (to cut down on run time requirements, which were huge during the first run, up to 7+ days depending on chromosome!)

### 8.1) Generate sites files for each chromosome (using .pos.gz files output from first run), index these, and also generate chromosome files to specify region:
```
# Make sites directory
mkdir sites
# create sites files for each chromosome (sal01 given as example below)
zcat charr.sal01.pos.gz | cut -f1,2 | tail -n +2 > sites/sites01.list

# Index sites file
module load StdEnv/2023 angsd/0.940
angsd sites index sites01.list

# Generate chromosome files
echo "sal01" > sites/chroms01.txt
```

### 8.2) Using tailored job scripts for each chromosome (based on memory used and time requirements from first run), submit separate ANGSD jobs for each chromosome:
```
sbatch angsd_sal01_redo_filter.sh
```

** In the end, I decided to split up a number of chromosomes and run ANGSD separately on the different sections, due to resource issues (many smaller jobs queued and ran faster than one huge job per chromosome. Also didn't limit these jobs to sites genotyped previously, because it didn't seem to help runtime at all) **

### 9.0) Remove low-depth individuals as identified earlier from beagle files 
### 9.1) Calculate average depth and coverage for each individual for each chromosome using samtools coverage (use 09_depth_from_bams.sh script). This will generate a .txt file for each sample.

### 9.2) Concatenate all sample .txt files with per-chromosome mean depth, coverage, and quality info:
```
cd depth_files
output_file="concat_depth.txt"
touch $output_file

for f in *realigned.bam.txt
do filename=$(basename "$f")
filename="${filename%.*}"
echo "Appending file: $f"
tail -n +2 "$f" | awk -v filename="$filename" '{print $0 "\t" filename}' >> "$output_file"
done
```
This will return a file of all the coverage/depth info per sample concatenated, with the file name in a new column.

### 9.3) Next, need to search for samples with very low depth (use coverage= 0.5x for nuclear chromosomes).
```
awk '$7 < 0.5 && /NC_049/' concat_depth.txt | awk '{print $10}' | sort -u >> low_samples.txt
```
Cleanup: Delete the ".realigned.bam" from each line in the file
```
sed -i 's/\.realigned\.bam//g' low_samples.txt
```

### 9.4) Remove low-depth individuals (low_samples.txt) from beagle files):
To remove individuals from a beagle file is very clunky. First, need to match sample names in bamlist.tsv to "Ind#" names used in beagle file:
```
# Print the row number corresponding to each sample (order in which beagle files were generated):
awk '{print $0,NR}' bamlist.tsv > bamlist_rownumbers.txt
```
Have to go through the file manually to figure out the numbers for the samples listed in the lownuc_samples.txt file above. Explanation for how this is done is given in actual jobscript (10_remove_lowdepth_inds_filt.sh). Running this script will prune beagle files of the low-depth individuals needing to be excluded from downstream analysis: 1920 original files - 38 low-depth files = 1882 remaining files. The file lowfilts.txt will contain samples that have average per-chromosome depths greater than 0.5X. There are 1882 samples in the file, but note that this corresponds to 1878 unique fish (4 fish were sequenced twice- but keep these duplicates in for downstream analyses for now). 

### 9.5) Concatenate chromosome beagle files (with low-depth inds filtered out) together (for use in whole-genome PCA visualization) by running 11_concat_lowfilt_beagles.sh.



