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
