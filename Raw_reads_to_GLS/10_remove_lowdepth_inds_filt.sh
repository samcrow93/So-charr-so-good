#!/bin/bash
#SBATCH --time=5:00:00
#SBATCH --account=def-ibradbur
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samantha.crowley@dal.ca
#SBATCH --mem=2G
#SBATCH --output=slurm.%x.%j.out
#SBATCH --job-name=remove_lowdepth_indivs_beagle


cd /home/samcrow/scratch/charr_wgs/redo_angsd/angsd_filt_outs

echo "Removing low depth samples (n=38, including negatives) from $chrom beagle file"
zcat "$chrom"_filt.beagle.gz | cut -f70,71,72,181,182,183,337,338,339,490,491,492,673,674,675,742,743,744,787,788,789,859,860,861,937,938,939,1042,1043,1044,1267,1268,1269,1273,1274,1275,1276,1277,1278,1570,1571,1572,1951,1952,1953,1960,1961,1962,2002,2003,2004,2146,2147,2148,2305,2306,2307,2332,2333,2334,2806,2807,2808,2884,2885,2886,3052,3053,3054,3067,3068,3069,3133,3134,3135,3316,3317,3318,3472,3473,3474,3535,3536,3537,3538,3539,3540,3541,3542,3543,3544,3545,3546,3547,3548,3549,3550,3551,3552,3685,3686,3687,3763,3764,3765,3811,3812,3813,3817,3818,3819,3829,3830,3831 --complement | gzip > lowfilts/lowfilt.$chrom.beagle.gz


# Explanation of what is happening here:
### Below are the individuals (and non-sample samples) to remove and their order (row numbers):
### **IMPORTANT** note that beagle file starts listing individuals at "IND0" (so, in list below, every ind should be numbered one less)**
### Individuals will be in columns based on this: ind0=4, ind1=7, ind2=10, ind3=13 (i.e. column=ind*3 +4) (OR, column=ind*3 +1 to account for numbering issue
#### PG001_2013_6F 23  ** but actually want Ind22 in beagle file since it starts numbering at Ind0
#### PG001_2001_63F 60
#### PG004_2011_394F 112
#### PG080_2002_210F 163
#### PG015_2011_813M 224
#### PG015_2011_841F 247
#### PG080_2002_398M 262
#### PG010_2013_24F 286
#### PG010_2002_823M 312
#### PG010_2002_845F 347
#### PG008_2002_1053M 422
#### PG008_2002_1056M 424
#### PG008_2002_1028F 425
#### PG080_2011_107F 523
#### NEG 650
#### NEG 667
#### NEG 768
#### NEG 935
#### NEG 1022
#### NEG 1105
#### NEG 1157
#### NEG 1178
#### NEG 1179
#### NEG 1180
#### NEG 1181
#### NEG 1182
#### NEG 1183
#### PG004_097 653
#### PG001_017 715
#### Tasersuaq_007 777
#### NAC1728905 961
#### NOR1729122 1017
#### R781729280 1044
#### Charr23-Ker-045 1228
#### Charr23-SGR-188 1254
#### NNor_70-2 1270
#### NNor_71-2 1272
#### NNor_74-1 1276



