## This section describes the demographic reconstruction analyses using GONE2

## First, for the Jan Mayen population:
### 1.0) Begin by converting the concatenated bcf file to a vcf file
```
bcftools view sal01.janmayen.nomaf.bcf -Ov -o sal01.janmayen.nomaf.vcf
```

### 2.0) Subset vcf file to only 500000 SNPs:
```
# Get header:
bcftools view -h sal01.janmayen.nomaf.vcf > header.vcf
# subset:
bcftools view -H sal01.janmayen.nomaf.vcf | shuf -n 500000 > random_snps.vcf
# Combine header and subsetted SNPs:
cat header.vcf random_snps.vcf > sal01.janmayen.nomaf.subset.vcf
# gzip the file:
bgzip sal01.janmayen.nomaf.subset.vcf
# Sort the file:
bcftools sort sal01.janmayen.nomaf.subset.vcf.gz -Oz -o sal01.janmayen.nomaf.subset.sort.vcf.gz
# Index the file:
tabix -p vcf sal01.janmayen.nomaf.subset.sort.vcf.gz
```

### 2.0) Convert subsetted, sorted VCF file to plink files:
```
plink --vcf sal01.janmayen.nomaf.subset.sort.vcf.gz --aec -set-missing-var-ids @:# -const-fid --recode --out plinkfiles/sal01.janmayen.nomaf.subset.sort
```

### 3.0) Run GONE2
Submit gone2_janmayen.sh script

### Alternatively (many alternatives) here is some other potentially useful stuff:
Subset a vcf for only polymorphic, biallelic SNPs and MAF filter at 0.1:
```
bcftools filter -e 'AC==0 || AC==AN || MAF <=0.1' JM_concat_young_20x_noparalog.vcf.gz | bcftools view -m2 -M2 -v snps -Oz -o JM_concat_young_20x_noparalog_poly_biallelic_maf0.1.vcf.gz
```

To subset a vcf for a variant every MB:
```
# Generate list of subset SNPs:
bcftools query -f '%CHROM\t%POS\t%ID\n' JM_concat_young_20x_noparalog_poly_biallelic_maf0.1.vcf.gz | awk 'BEGIN{OFS="\t"} {
if ($1 != last_chr || $2 - last_pos >= 1000000) {
print $1, $2
last_chr = $1
last_pos = $2
}
}' > keep_sites.tx
# Need to index the vcf to be subset:
bcftools index JM_concat_young_20x_noparalog_poly_biallelic_maf0.1.vcf.gz
# Subset vcf:
bcftools view -R keep_sites.txt -Oz -o JM_concat_young_20x_noparalog_poly_biallelic_maf0.1_subset1mb.vcf.gz JM_concat_young_20x_noparalog_poly_biallelic_maf0.1.vcf.gz
```






