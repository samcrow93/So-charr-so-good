## This section describes the processing of the mitogenome data

### Samples were processed in steps 1-3 in the raw_reads_to_GLs section (trimming); analyses described here picks up from that point.

### Note that reference genome used for nuclear data does not include a mitogenome reference; therefore the analyses here use a reference mitogenome from a difference sample (accession # NC_000861 in NCBI)

### 1.0) Alignment to mitogenome
Trimmed fastq files are quite large, so run each sample as a separate job:

1.1) Create set files that each contain one sample name as follows:
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

1.2) Submit alignment jobs with 01_bwamem_mito_NL.sh script as follows:
```
for i in {00..#total_align_sets}
do
sbatch --export=set=mt_NL_charr.set$i 01_bwamem_mito_NL.sh
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

Next, submit the 02_mark_dups_mito_NL.sh jobscript as follows:
```
for i in {00..#total_dedup_sets}
do
sbatch --export=set=NL_dupindex.set$i 02_mark_dups_mito_NL.sh
done
```

The deduplicated alignment files also needs to be indexed (using the 03_index_dedup_mito_NL.sh script):
```
for i in {00..#total_dedup_sets)
do
sbatch --export=set=NL_dupindex.set$i 03_index_dedup_mito_NL.sh
done
```

### 3.0) Refining mito alignments- indel realignment
First, need to identify realignment targets using GATK (deprecated version) using 04_indel_target_mito_NL.sh script:
```
# First need to create .dict file (not already part of mitogenome ref files downloaded from NCBI):
gatk CreateSequenceDictionary -R swedish_ref_mito.fasta

# Then submit jobs:
for i in {00..#total_dedup_sets}
do
sbatch --export=set=NL_dupindex.set$i 04_indel_target_mito_NL.sh
done
```

Then, actually update the alignments (using 05_indel_realign_mito_NL.sh script):
```
for i in {00..#total_align_sets}
do
sbatch --export=set=NL_dupindex.set$i 05_indel_realign_mito_NL.sh
done
```

### 4.0) Exclude samples with low depths
Use same approach as for nuclear data to identify individuals with low average depths on the mitogenome (< 15X):

4.1) Run 06_mito_depth_from_bams.sh script;

4.2) Next, need to concatenate all .txt files with depth and coverage info:
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

4.3) Identify which samples have mean depth < 15X:
```
awk '$7 < 15 && /CM098937.1/' concat_depth.txt | awk '{print $10}' | sort -u > lowmito_charr_samples.txt
# These samples all end with the suffix .mito_swedish_realigned.bam
```

4.4) Create new sample list of only those with mean depths >= 15X:
```
# Generate list of sample names for which there are realigned bams:
ls *.mito_swedish_realigned.bam.txt  | sed 's/\.txt//' > mt_inds.tsv
# Reverse grep to remove low depth samples from full sample list:
grep -v -F -f lowmito_charr_samples.txt mt_inds.tsv > mt_inds_freebayes.txt
```

4.5) Uuse ANGSD -dofasta to call genotypes (run angsd_mito_dofasta.sh).
This will generate a consensus fasta sequence for each individual that passed the >=15X cutoff (listed in mt_inds_freebayes.txt).

4.6) Concatenate all fasta files together:
```
output="combined.fasta"
for file in *.fa.gz;
do
sample=$(basename "$file" .mito_swedish_realigned.bam.fa.gz);
zcat "$file" | while IFS= read -r line;
do
if [[ "$line" == ">"* ]];
then
echo "${line}_${sample}" >> "$output"; else echo "$line" >> "$output";
fi;
done;
done
```

4.7) Run a multiple sequence alignment using Clustal Omega (using clustal_charr_mito.sh script). Include both the Acadian reference sequence (NC_000861), as well as a brook trout (S. fontinalis) reference (NC_000860) as well. 

4.8) Import the resulting fasta file file into R to determine haplotypes (using mito_full_haplotypes.R script). This will end by writing a new fasta file with the sequences of unique whole-mitogenome haplotypes. 

4.9) Use the fasta file of whole-mitogenome haplotype sequences to generate a maximum likelihood tree using the IQ-TREE2 program:
```
# Note that 'haplotype665' is the S. fontinalis sequence and is used as the outgroup here
# The TIM3+F+R2 was determined to be the best substitution model from a previous run using the -m TEST option
# Also use the UFBOOT option with 1000 replicates to bootstrap
iqtree -s hap_seqs_acadref_withfontacad_noKER_nodup.fasta -o haplotype665 -m TIM3+F+R2 -B 1000 --prefix hap_seqs_acadref_withfontacad_noKER_nodup_UFBOOT
```

4.10) Visualize the output consensus tree (.contree) in R using ggtree (use trees_charr.R script).




