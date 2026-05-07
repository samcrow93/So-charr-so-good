# This R script is for running lostruct on the results from windowed PCAs using PCANGSD
# Takes too long to load in data on laptop
# Update May 7th 2026: running on dataset generated from no Ker, no dup, no lowdepth, no neg dataset (n=1827 samples)

# Specify $chrom variable called in shell script job:
args <- commandArgs(trailingOnly = TRUE)
chrom <- args[1]

print(chrom)

# Load required packages:
library(lostruct)
library(data.table)
library(dplyr)
library(tidyr)

# Load in files:
files<-data.frame(list.files("./", pattern = ".cov", full.names = F))
colnames(files)<- "file_name"
files$chrom<-1
files$win <- sub("^.*\\.win\\.([0-9]+)\\.cov$", "\\1", files$file_name)
files$win=as.numeric(files$win)
win_order<-files[order(files$chrom, files$win),]

N_PC=2
N_IND=1827
N_MDS=10
# matrix will have 3657 columns
# col1=sum squares, col2-3= eigenvalues of first 2 PCs
# cols 4-3657 are eigenvectors for first two PCs for each of 1827 individuals
win_eigs<-matrix(nrow=dim(win_order)[1], ncol= (1+N_PC+ (N_IND*N_PC)))

for (i in 1:dim(win_order)[1]){
  print(paste("Loading in window", i))
  win_covmats_i<-as.matrix(read.table(win_order$file_name[i]))
  win_eigs[i,]<- cov_pca(k=N_PC, covmat=win_covmats_i)
}
print("Finished making win_eigs table")

# Calculate distance matrix between windows for PCs 1 and 2
win_dist<- pc_dist(win_eigs, npc=N_PC)
print("Finished making win_dist table")

# Save this file:
#write.table(win_dist, paste0(chrom, "_win_dist.txt"), row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t")


# Multidimensional scaling
# 'Takes a set of dissimilarities and returns a set of points such that
# the distances between the points are approx. equal to the dissimilarities'
mds_axe<-cmdscale(win_dist, eig=TRUE, k=N_MDS)
win_order_mds<-cbind(win_order, mds_axe$points)

#plot(mds_axe$points[,1], mds_axe$points[,2], pch=20)
#text(mds_axe$points[,1], mds_axe$points[,2], labels =win_order$win)

# Calculate mean and SD mds score for each window for each axis:
colnames(win_order_mds) <- c("file_name","chrom","win","mds1","mds2",
                             "mds3","mds4","mds5","mds6","mds7",
                             "mds8","mds9","mds10")
mds_means <- win_order_mds %>% 
  summarize(across(c("mds1","mds2",
                     "mds3","mds4","mds5","mds6","mds7",
                     "mds8","mds9","mds10"), mean))
mds_sds <- win_order_mds %>% 
  summarize(across(c("mds1","mds2",
                     "mds3","mds4","mds5","mds6","mds7",
                     "mds8","mds9","mds10"), sd))
# Write file of full mds results:
#write.table(win_order_mds, paste0(chrom, "_mds_results.txt"), row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t")


# Find outliers greater than 3*SDs beyond the mean MDS value:
mds_pos_outliers <- win_order_mds %>%
  pivot_longer(
    cols = -c(file_name, chrom, win),
    names_to = "mds",
    values_to = "mds_value") %>%
  left_join(mds_means %>%
      pivot_longer(everything(),
        names_to = "mds",
        values_to = "mean_mds_value"),
    by = "mds") %>%
  left_join(mds_sds %>%
      pivot_longer(everything(),
      names_to = "mds",
      values_to = "sd_mds_value"),
      by = "mds") %>%
  filter(mds_value >= (mean_mds_value + 3*sd_mds_value))
# Write this file: 
write.table(mds_pos_outliers, paste0(chrom, "_mds_pos_outliers.txt"), row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t")

# Find outliers more than 3*SDs below the mean MDS value:
mds_neg_outliers <- win_order_mds %>%
  pivot_longer(
    cols = -c(file_name, chrom, win),
    names_to = "mds",
    values_to = "mds_value") %>%
  left_join(mds_means %>%
              pivot_longer(everything(),
                           names_to = "mds",
                           values_to = "mean_mds_value"),
            by = "mds") %>%
  left_join(mds_sds %>%
              pivot_longer(everything(),
                           names_to = "mds",
                           values_to = "sd_mds_value"),
            by = "mds") %>%
  filter(mds_value <= (mean_mds_value - 3*sd_mds_value))
# Write this file:
write.table(mds_neg_outliers, paste0(chrom, "_mds_neg_outliers.txt"), row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t")
