## This section describes the demographic reconstruction analyses using GONE2

### 1.0) Begin by converting the concatenated bcf file to a vcf file
Run bcfs_to_vcfs.sh script

### 2.0) Convert vcf file to plink files
On Cedar cluster, run:
```
module load StdEnv/2020 plink/1.9b_6.21-x86_64
plink -vcf filt_charr_concat.vcf -aec -make-bed -const-fid -out plink_files/filt_charr_concat
```
