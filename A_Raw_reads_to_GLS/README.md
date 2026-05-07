## This section outlines steps taken from processing raw fastq files through to generation of genotype likelihoods
### Note that this readme file describes workflow for main batch of samples (designated as "NL" in script naming etc.), however there is another batches of samples (published data (Dallaire et al. 2023 Genome Biology and Evolution) downloaded from the NCBI sequence read archive, n=517 samples available as of late 2024 for BioProject accession PRJNA1031558) that were processed using similar scripts.

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
Trimmed fastq files are quite large, so run each sample as a separate job:

4.1) Create set files that each contain one sample name as follows:
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

4.2) Submit 03_bwamem_align_NL.sh script as follows:
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

Create different set of set files for dedup steps (much quicker than alignment, so can have more samples in each set i.e. more samples per individual job):
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

### 7.0) Remove low-depth individuals:
7.1) Calculate average depth and coverage for each individual for each chromosome using samtools coverage (use 08_depth_from_bams.sh script). This will generate a .txt file for each sample.

7.2) Concatenate all sample .txt files with per-chromosome mean depth, coverage, and quality info:
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

7.3) Next, need to search for samples with very low depth (use coverage= 0.5x for nuclear chromosomes).
```
awk '$7 < 0.5 && /NC_049/' concat_depth.txt | awk '{print $10}' | sort -u >> low_samples.txt
```
These samples were removed prior to downstream analysis (i.e. calculation of genotype likelihoods). Also removed were negatives, Kerguelen samples, and 8 duplicated sample names (leaving a total of 1827 samples remaining for genotype likelihood calculation).

### 8.0 Genotype likelihoods using ANGSD
Run ANGSD: Submit 09_angsd_chroms.sh script as follows:
```
for chrom in sal01 sal02 # etc.
do
sbatch --export=chrom=$chrom 09_angsd_chroms.sh
done
```

9) Concatenate chromosome beagle files together (for use in whole-genome PCA visualization) by running 10_concat_beagles.sh.

### The beagle files are now ready for use in PCANGSD, and also ready for additional processing for downstream analyses (i.e. paralog filtering, LD-filtering, admixture- see other sections of this repository).


