## This section describes the processing of the mitogenome data

## Samples were processed in steps 1-3 in the raw_reads_to_GLs section (trimming); analyses described here picks up from that point.

## Note that reference genome used for nuclear data does not include a mitogenome reference; therefore the analyses here use a reference mitogenome from a difference sample (accession # CM098937 in NCBI)

### 1.0) Alignment to mitogenome
Trimmed fastq files are quite large, so run each sample as a separate job:

### 1.1) Create Sets
Create set files that each contain one sample name as follows:
```
# Create list of sampled names:
ls *R1.trimmed.fastq.gz | \
 sed 's/\_R1.trimmed.fastq.gz//' > mt_align_sets/NL_sets/NL_mt_inds.tsv

# Split samples into one per set file:
split -l 1 \
 -d \
NL_mt_inds.tsv \
./mt_NL_charr.set
```

### 1.2) Submit alignment jobs
Submit bwamem_mito_NL.sh script as follows:
```
for i in {00..#total_align_sets}
do
sbatch --export=set=mt_NL_charr.set$i bwamem_mito_NL.sh
done
```

### 2.0) Refining mito alignments - Preparation
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
NL_mt_inds.tsv \
mt_align_sets/NL_dedup_index/NL_dupindex.set
```

Next, submit the mark_dups_mito_NL.sh jobscript as follows:
```
for i in {00..#total_dedup_sets}
do
sbatch --export=set=NL_dupindex.set$i mark_dups_mito_NL.sh
done
```

The deduplicated alignment files also needs to be indexed (using the index_dedup_mito_NL.sh script):
```
for i in {00..#total_dedup_sets)
do
sbatch --export=set=NL_dupindex.set$i index_dedup_mito_NL.sh
done
```

### 3.0) Refining mito alignments- indel realignment
First, need to identify realignment targets using GATK (deprecated version) using indel_target_mito_NL.sh script:
```
for i in {00..#total_dedup_sets}
do
sbatch --export=set=NL_dupindex.set$i indel_target_mito_NL.sh
done
```

Then, actually update the alignments (using indel_realign_mito_NL.sh script):
```
for i in {00..#total_align_sets}
do
sbatch --export=set=NL_dupindex.set$i indel_realign_mito_NL.sh
done
```

