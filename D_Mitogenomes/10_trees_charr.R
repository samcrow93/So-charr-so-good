#### Plotting charr mito tree with ggtree ####
library(ggtree)
library(tidytree)
# Load these functions from the tidytree package otherwise ggtree doesn't work properly for some stuff
nodeid.tbl_tree <- utils::getFromNamespace("nodeid.tbl_tree", "tidytree")
rootnode.tbl_tree <- utils::getFromNamespace("rootnode.tbl_tree", "tidytree")
offspring.tbl_tree <- utils::getFromNamespace("offspring.tbl_tree", "tidytree")
offspring.tbl_tree_item <- utils::getFromNamespace(".offspring.tbl_tree_item", "tidytree")
child.tbl_tree <- utils::getFromNamespace("child.tbl_tree", "tidytree")
parent.tbl_tree <- utils::getFromNamespace("parent.tbl_tree", "tidytree")

#### 1. Acad ref with Sfont sequence (no designated outgroup) ####
#setwd("C:/Users/sammy/Documents/PhD/charr_all")
#tree1 <- read.tree("./mitogenomes/trees/combo_acadref_withfont_multiseqalign.fa.nwk")
#tree1$tip.label # Labels are too long/messy; clean up
#tree1$tip.label <- gsub("^.*?i5\\.", "", tree1$tip.label)
#tree1$tip.label <- gsub("^NC_000861.1_", "", tree1$tip.label)

# Load in sample metadata:
# setwd("C:/Users/sammy/Documents/PhD/charr_all")
# samples <- read.csv("./metadata/working/charr_meta_coords.csv")
# str(samples$population)
# samples$population <- as.factor(samples$population)
# samples$label <- samples$sample
# 
# # Add in metadata:
# samples_meta <- samples %>% 
#   mutate(region=case_when(grepl("PG0",sample)~ "Nunavut",
#                           grepl("Satuut",sample)~ "Nunavut",
#                           grepl("Robertson",sample)~ "Nunavut",
#                           grepl("Tugaat",sample)~ "Nunavut",
#                           grepl("Iceland",sample)~ "Europe",
#                           grepl("Tasersuaq",sample)~ "Europe",
#                           grepl("Green",sample)~ "Europe",
#                           grepl("Jan",sample)~ "Europe",
#                           grepl("KAN",sample)~ "Labrador",
#                           grepl("IKA",sample)~ "Labrador",
#                           grepl("10417",sample)~ "Labrador",
#                           grepl("IKI",sample)~ "Labrador",
#                           grepl("KIN",sample)~ "Labrador",
#                           grepl("NAC",sample)~ "Labrador",
#                           grepl("10317",sample)~ "Labrador",
#                           grepl("PAN",sample)~ "Labrador",
#                           grepl("NOR",sample)~ "Labrador",
#                           grepl("10917",sample)~ "Labrador",
#                           grepl("R7817",sample)~ "Labrador",
#                           grepl("MBB",sample)~ "Labrador",
#                           grepl("ENG",sample)~ "Labrador",
#                           grepl("PBP",sample)~ "Labrador",
#                           grepl("ANA",sample)~ "Labrador",
#                           grepl("BLD",sample)~ "Labrador",
#                           grepl("FR",sample)~ "Labrador",
#                           grepl("AVA",sample)~ "Labrador",
#                           grepl("Ker",sample)~ "Europe",
#                           grepl("SGR",sample)~ "Nunavut",
#                           grepl("NNor",sample)~ "Europe",
#                           grepl("BI",sample)~ "Europe",
#                           grepl("KL19",sample)~ "Nunavut",
#                           grepl("SRR",sample)~ "Laval_data"))
# 
# # Add in region info for Laval samples:
# samples_meta <- samples_meta %>% 
#   mutate(region=case_when(grepl("EKA",geo_loc_name)~ "Nunavut",
#                           grepl("CRB",geo_loc_name)~ "Nunavut",
#                           grepl("AKL",geo_loc_name)~ "Nunavut",
#                           grepl("SVG",geo_loc_name)~ "Nunavut",
#                           grepl("COP",geo_loc_name)~ "Nunavut",
#                           grepl("SPI",geo_loc_name)~ "Nunavik",
#                           grepl("SAT",geo_loc_name)~ "Nunavut",
#                           grepl("QSG",geo_loc_name)~ "Nunavut",
#                           grepl("QNB",geo_loc_name)~ "Nunavut",
#                           grepl("PAM",geo_loc_name)~ "Nunavut",
#                           grepl("KGJ",geo_loc_name)~ "Nunavut",
#                           grepl("IPI",geo_loc_name)~ "Nunavik",
#                           grepl("TAH",geo_loc_name)~ "Nunavut",
#                           grepl("HRN",geo_loc_name)~ "NWT",
#                           grepl("HAL",geo_loc_name)~ "Nunavut",
#                           grepl("GEO",geo_loc_name)~ "Nunavik",
#                           grepl("FRM",geo_loc_name)~ "Nunavik",
#                           TRUE ~ region))
# 
# 
# # Check all samples in tree match those in samples df
# # Expect that some won't because different filtering for mt vs. nuclear datasets
# #setdiff(samples_meta$label, tree1$tip.label)
# #setdiff(tree1$tip.label,samples_meta$label)
# 
# # Drop Neg sample and samples that are duplicated 
# # "KIN1728795", "KIN1728797", "PG015_2003_1278F", "PG080_2011_131F"
# library(ape)
# #tree2 <- drop.tip(tree1, "NEG")
#tree2 <- drop.tip(tree2, "KIN1728795")
#tree2 <- drop.tip(tree2, "KIN1728797")
#tree2 <- drop.tip(tree2, "PG015_2003_1278F")
#tree2 <- drop.tip(tree2, "PG080_2011_131F")
#tree2 <- drop.tip(tree2, "SRR26511621")

# Which samples are missing region metadata?
#library(ggnewscale)
#test_tree <- ggtree(tree2,size=0.1,layout="circular")+
#  theme_tree2()+
#  aes(color = region)+   # color the branches according to region
#  scale_color_manual(name = "Region",  
#    breaks = c("Europe", "Labrador",
#               "Nunavut","Nunavik",
#               "NWT","Sfont"),      
#    labels = c("Europe", "Labrador",
#               "Nunavut","Nunavik",
#               "NWT","Sfont"),       
#    values = c("darkred", "darkgreen","darkblue",
#               "darkturquoise","purple4","goldenrod"),  
#    na.value = "black") + 
#  scale_x_continuous(trans = "log10")
  
  

#test_tree$data <- test_tree$data %>%
#  left_join(samples_meta, by = "label")

#missing_tips <- test_tree$data %>%
#  filter(isTip & is.na(region)) %>%   # only tip nodes
#  select(label)

#missing_tips # There are 13 tips missing region metadata

#test_tree$data <- test_tree$data %>%
#  mutate(region = case_when(label == "PG001_017" ~ "Nunavut",
#    label == "PG001_2001_63F" ~ "Nunavut",
#    label =="PG008_2002_1028F" ~ "Nunavut",
#    label =="PG015_2011_813M" ~ "Nunavut",
#    label =="NNor_68-2" ~ "Europe",
#    label =="PAN1729098" ~ "Labrador",
#    label == "MBB1729303" ~ "Labrador",
#    label == "NC_000860.1_Salvelinusfontinalismitochondrioncompletegenome" ~ "Sfont",
#    label == "PG080_2002_398M" ~ "Nunavut",
#    label == "PG008_2002_1056M" ~ "Nunavut",
#    label == "PG080_2002_210F" ~ "Nunavut",
#    label == "PG080_2011_107F" ~ "Nunavut",
#    label == "PG010_2002_823M" ~ "Nunavut",
#    TRUE ~ region))

# Re-check:
#missing_tips2 <- test_tree$data %>%
#  filter(isTip & is.na(region)) %>%   # only tip nodes
#  select(label)

#missing_tips2 # Empty= good

# Finish tree:
#pdf("./mitogenomes/plots/test_tree.pdf", width = 8, height=8)
#test_tree$data$region <- factor(test_tree$data$region)
#test_tree + 
#  new_scale_color()+  
#  geom_tippoint(aes(color = region), size = 0.1)+
#geom_tippoint(
#  mapping = aes(color = region),          # tip color by continent. You may change shape adding "shape = "
#  size = 0.1)+                               # define the size of the point at the tip
#  scale_color_manual(name = "Region",  
#                     breaks = c("Europe", "Labrador",
#                                "Nunavut","Nunavik",
#                                "NWT","Sfont"),      
#                     labels = c("Europe", "Labrador",
#                                "Nunavut","Nunavik",
#                                "NWT","Sfont"),       
#                     values = c("darkred", "darkgreen","darkblue",
#                                "darkturquoise","purple4","goldenrod"),  
#                     na.value = "black")
  
#dev.off()



#### 2. Tree with Sfont as outgroup, Acad ref with Acad sequence ####
#setwd("C:/Users/sammy/Documents/PhD/charr_all")
#tree_b <- read.tree("./mitogenomes/trees/combo_acadref_withfontandacad_multiseqalign.fa.nwk")
#tree_b$tip.label # Labels are too long/messy; clean up
#tree_b$tip.label <- gsub("^.*?i5\\.", "", tree_b$tip.label)
#tree_b$tip.label <- gsub("^NC_000861.1_", "", tree_b$tip.label)

# Load in sample metadata:
#samples <- read.csv("./metadata/working/charr_meta_coords.csv")
#str(samples$population)
#samples$population <- as.factor(samples$population)
#samples$label <- samples$sample

# Add in metadata:
#samples_meta <- samples %>% 
#  mutate(region=case_when(grepl("PG0",sample)~ "Nunavut",
#                          grepl("Satuut",sample)~ "Nunavut",
#                          grepl("Robertson",sample)~ "Nunavut",
#                          grepl("Tugaat",sample)~ "Nunavut",
#                          grepl("Iceland",sample)~ "Europe",
#                          grepl("Tasersuaq",sample)~ "Europe",
#                          grepl("Green",sample)~ "Europe",
#                          grepl("Jan",sample)~ "Europe",
#                          grepl("KAN",sample)~ "Labrador",
#                          grepl("IKA",sample)~ "Labrador",
#                          grepl("10417",sample)~ "Labrador",
#                          grepl("IKI",sample)~ "Labrador",
#                          grepl("KIN",sample)~ "Labrador",
#                          grepl("NAC",sample)~ "Labrador",
#                          grepl("10317",sample)~ "Labrador",
#                          grepl("PAN",sample)~ "Labrador",
#                          grepl("NOR",sample)~ "Labrador",
#                          grepl("10917",sample)~ "Labrador",
#                          grepl("R7817",sample)~ "Labrador",
#                          grepl("MBB",sample)~ "Labrador",
#                          grepl("ENG",sample)~ "Labrador",
#                          grepl("PBP",sample)~ "Labrador",
#                          grepl("ANA",sample)~ "Labrador",
#                          grepl("BLD",sample)~ "Labrador",
#                          grepl("FR",sample)~ "Labrador",
#                          grepl("AVA",sample)~ "Labrador",
#                          grepl("Ker",sample)~ "Europe",
#                          grepl("SGR",sample)~ "Nunavut",
#                          grepl("NNor",sample)~ "Europe",
#                          grepl("BI",sample)~ "Europe",
#                          grepl("KL19",sample)~ "Nunavut",
#                          grepl("SRR",sample)~ "Laval_data"))

# Add in region info for Laval samples:
# samples_meta <- samples_meta %>% 
#   mutate(region=case_when(grepl("EKA",geo_loc_name)~ "Nunavut",
#                           grepl("CRB",geo_loc_name)~ "Nunavut",
#                           grepl("AKL",geo_loc_name)~ "Nunavut",
#                           grepl("SVG",geo_loc_name)~ "Nunavut",
#                           grepl("COP",geo_loc_name)~ "Nunavut",
#                           grepl("SPI",geo_loc_name)~ "Nunavik",
#                           grepl("SAT",geo_loc_name)~ "Nunavut",
#                           grepl("QSG",geo_loc_name)~ "Nunavut",
#                           grepl("QNB",geo_loc_name)~ "Nunavut",
#                           grepl("PAM",geo_loc_name)~ "Nunavut",
#                           grepl("KGJ",geo_loc_name)~ "Nunavut",
#                           grepl("IPI",geo_loc_name)~ "Nunavik",
#                           grepl("TAH",geo_loc_name)~ "Nunavut",
#                           grepl("HRN",geo_loc_name)~ "NWT",
#                           grepl("HAL",geo_loc_name)~ "Nunavut",
#                           grepl("GEO",geo_loc_name)~ "Nunavik",
#                           grepl("FRM",geo_loc_name)~ "Nunavik",
#                           TRUE ~ region))


# Check all samples in tree match those in samples df
# Expect that some won't because different filtering for mt vs. nuclear datasets
# setdiff(samples_meta$label, tree_b$tip.label)
# setdiff(tree_b$tip.label,samples_meta$label)

# Drop Neg sample, samples that are duplicated, and Ker samples
# duplicated samples: "KIN1728795", "KIN1728797", "PG015_2003_1278F", "PG080_2011_131F"
# library(ape)
# tree_b2 <- drop.tip(tree_b, "NEG")
# tree_b2 <- drop.tip(tree_b2, "KIN1728795")
# tree_b2 <- drop.tip(tree_b2, "KIN1728797")
# tree_b2 <- drop.tip(tree_b2, "PG015_2003_1278F")
# tree_b2 <- drop.tip(tree_b2, "PG080_2011_131F")
# tree_b2 <- drop.tip(tree_b2, "SRR26511621")
# tree_b2 <- drop.tip(tree_b2, grep("Ker", tree_b2$tip.label, value = TRUE))

# Which samples are missing region metadata?
# library(ggnewscale)
# test_tree_b <- ggtree(tree_b2,size=0.1)+
#  # ggtree(tree_b2,size=0.1,
#   #                    branch.length="none")+
#   theme_tree2()+
#   aes(color = region)+   # color the branches according to region
#   scale_color_manual(name = "Region",  
#                      breaks = c("Europe", "Labrador",
  #                               "Nunavut","Nunavik",
  #                               "NWT","Sfont","Acadref"),      
  #                    labels = c("Europe", "Labrador",
  #                               "Nunavut","Nunavik",
  #                               "NWT","Sfont","Acadref"),       
  #                    values = c("darkred", "darkgreen","darkblue",
  #                               "darkturquoise","purple4","goldenrod",
  #                               "magenta"),  
  #                    na.value = "black") 
  # #scale_x_continuous(trans = "log10")



# test_tree_b$data <- test_tree_b$data %>%
#   left_join(samples_meta, by = "label")
# 
# missing_tips_b <- test_tree_b$data %>%
#   filter(isTip & is.na(region)) %>%   # only tip nodes
#   select(label)
# 
# missing_tips_b # There are 14 tips missing region metadata
# 
# test_tree_b$data <- test_tree_b$data %>%
#   mutate(region = case_when(label == "PG001_017" ~ "Nunavut",
#                             label == "PG001_2001_63F" ~ "Nunavut",
#                             label =="PG008_2002_1028F" ~ "Nunavut",
#                             label =="PG015_2011_813M" ~ "Nunavut",
#                             label =="NNor_68-2" ~ "Europe",
#                             label =="PAN1729098" ~ "Labrador",
#                             label == "MBB1729303" ~ "Labrador",
#                             label == "NC_000860.1_Salvelinusfontinalismitochondrioncompletegenome" ~ "Sfont",
#                             label == "PG080_2002_398M" ~ "Nunavut",
#                             label == "PG008_2002_1056M" ~ "Nunavut",
#                             label == "PG080_2002_210F" ~ "Nunavut",
#                             label == "PG080_2011_107F" ~ "Nunavut",
#                             label == "PG010_2002_823M" ~ "Nunavut",
#                             label == "Salvelinus_alpinus_mitochondrion_complete_genome" ~ "Acadref",
#                             TRUE ~ region))
# 
# # Re-check:
# missing_tips_b2 <- test_tree_b$data %>%
#   filter(isTip & is.na(region)) %>%   # only tip nodes
#   select(label)
# 
# missing_tips_b2 # Empty= good
# 
# # Finish tree:
# #pdf("./mitogenomes/plots/test_tree_rooted.pdf", width = 4, height=10)
# test_tree_b$data$region <- factor(test_tree_b$data$region)
# test_tree_b + 
#   new_scale_color()+  
#   geom_tippoint(aes(color = region), size = 0.1)+
#   geom_tippoint(
#     mapping = aes(color = region),          # tip color by continent. You may change shape adding "shape = "
#     size = 0.1)+                               # define the size of the point at the tip
#   scale_color_manual(name = "Region",  
#                      breaks = c("Europe", "Labrador",
#                                 "Nunavut","Nunavik",
#                                 "NWT","Sfont","Acadref"),      
#                      labels = c("Europe", "Labrador",
#                                 "Nunavut","Nunavik",
#                                 "NWT","Sfont","Acadref"),       
#                      values = c("darkred", "darkgreen","darkblue",
#                                 "darkturquoise","purple4","goldenrod",
#                                 "magenta"),  
#                      na.value = "black")
# 
# 

#dev.off()


#### 3. Unique haplotypes: tree with Sfont as outgroup, Acad ref with Acad sequence, no KER, no dup ####
setwd("C:/Users/sammy/Documents/PhD/charr_all")
# Use consensus sequence from UFBoot run (1000 bootstrap reps)
tree_hap <- read.tree("./mitogenomes/trees/hap_seqs_acadref_withfontacad_noKER_nodup_UFBOOT.contree")
# Root tree on Sfont:
library(ape)
tree_hap_root <- ape::root(tree_hap,
                      outgroup = "haplotype665", edgelabel = TRUE,
                      resolve.root=TRUE)

tree_hap_root$tip.label # Labels are haplotype numbers
tree_hap_root$node.label # Node labels are UFBoot support values
# According to documentation, should only begin to trust when support >95%

library(ggnewscale)
#pdf("./mitogenomes/plots/test_tree_hap.pdf", width = 8, height=8)
 test_tree_hap_root <- ggtree(tree_hap_root, 
                              layout="rectangular")+
 # test_tree_hap <- ggtree(tree_hap,size=0.1,branch.length="none)+
  theme_tree2()+
   # Add node labels for main splits (i.e. bootstrap supports):
   geom_nodelab(aes(subset = node %in% c(660, 990, 991,992,
                                         1151),
                  label = label), size=4,
               hjust=1.3,vjust = -0.5)+
   theme(axis.text.x=element_text(size=20), 
          axis.title.x = element_text(size=20))
   # Add haplotype labels to tips:
  # geom_tiplab(size=0.8)
   # Add node numbers for subsetting later:
 # geom_text2(mapping = aes(subset = !isTip, label = node),
#              size = 2,
#              color = "darkred")
# test_tree_hap_root
 
 #ggsave("./mitogenomes/plots/test_tree_hap_root.png",
##        test_tree_hap_root,
#        bg="white",
#        width = 20,
##        height = 16,
#        units = "in",
#        dpi = 300)  

# Add highlighting of Lineage clades:
test_tree_hap_root + geom_hilight(node = 992,
    fill = "#DD3D2D",
    extend = 0.0017, alpha=0.3) + 
  geom_cladelabel(node=992, label="Atlantic", 
                  color="#DD3D2D", offset=0.02,align=FALSE,
                  fontsize=6)+
 geom_hilight(node = 660,
    fill = "#364B9A",alpha=0.3,
    extend = 0.0017) +
  geom_cladelabel(node=660, label="Arctic", 
                  color="#364B9A", offset=0.02,align=FALSE,
                  fontsize=6)+
  geom_hilight(node = 1151,
              fill = "deeppink4",
               extend = 0.0017)+
  geom_cladelabel(node=1151, label="Acadian?", 
                  color="deeppink4", offset=0.02,align=FALSE,
                  fontsize=6)+
  theme(axis.text.x=element_text(size=20), 
        axis.title.x = element_text(size=20))

# Node 992 appears to be main Atlantic branch; node 660 is Arctic, 1151 Acadian?
 
  

# Scale Arctic and Atlantic clades to "flatten" them visually and make the plot better
scale_arc <- scaleClade(test_tree_hap_root, node=660, scale=.1)
scale_arc_atl <- scaleClade(scale_arc, node=992, scale=.1)
scale_acad_arc_atl <- scaleClade(scale_arc_atl, node=1151, scale=.1)

collapse_clades <- scale_acad_arc_atl +  geom_hilight(node = 992,
                              fill = "#DD3D2D",
                              extend = 0.0017, alpha=0.3) + 
  geom_cladelabel(node=992, label="Atlantic1", 
                  color="#DD3D2D", offset=0.003,align=FALSE,
                  fontsize=8)+
  geom_hilight(node = 660,
               fill = "#364B9A",alpha=0.3,
               extend = 0.0017) +
  geom_cladelabel(node=660, label="Arctic", 
                  color="#364B9A", offset=0.003,align=FALSE,
                  fontsize=8)+
  geom_hilight(node = 1151,
               fill = "deeppink4",
               extend = 0.0017)+
  geom_cladelabel(node=1151, label="Atlantic2/Acadian?", 
                  color="deeppink4", offset=0.003,align=FALSE,
                  fontsize=8)+
  theme(axis.text.x=element_text(size=20), 
        axis.title.x = element_text(size=20))
collapse_clades

#ggsave("./mitogenomes/plots/haps_tree_root_noKer_nodup_collapse_UFBOOT.png",
#      collapse_clades,
#       bg="white",
#       width = 10,
#       height = 8,
#       units = "in",
#       dpi = 300)  

# Get haplotype names for each lineage clade:
# Arctic:
arc <- as.data.frame(get_taxa_name(collapse_clades, node = 660)) #n=467
colnames(arc) <- "haplotype"
arc$lin <- "Arctic"
# Atlantic1:
atl1 <- as.data.frame(get_taxa_name(collapse_clades, node = 992)) #n=176
colnames(atl1) <- "haplotype"
atl1$lin <- "Atlantic1"
# Atlantic2/Acadian:
acad <- as.data.frame(get_taxa_name(collapse_clades, node = 1151)) #n=13
colnames(acad) <- "haplotype"
acad$lin <- "Atlantic2/Acadian"
hap_lins <- rbind(arc,atl1,acad)
# This sums to 656 haplotypes out of 658 total 
# missing S. fontinalis and that weird one sticking off of the Atlantic branch


#### Mapping piecharts of mito lineage haplotypes ####
# Read in full haplotype info:
hap_info <- read.table("./mitogenomes/hap_sample_acadref_withfontacad.txt",
                       header=TRUE, sep="\t")
# Exclude Ker samples as well as dups and neg:
hap_info_noker_nodup <- hap_info %>%
  filter(!grepl("Ker",sample)) %>%
  filter(sample!="NEG") %>%
  filter(sample!="KIN1728795" & sample!="KIN1728797" & sample!="PG015_2003_1278F" & sample!="PG080_2011_131F")
# 1836 samples now, good

# Merge with haplotype lineage df:
hap_info_lins <- merge(hap_info_noker_nodup, hap_lins,
                       by="haplotype", all.x=TRUE)

# Which samples group in the Atlantic2/Acadian clade?
hap_info_lins %>% filter(lin=="Atlantic2/Acadian") %>%
  group_by(population) %>% tally()
# 14 samples from Parker's brook, with 3 haplotypes (351, 352, 353)
# EG: 1 (singleton)
# ICE: 7 (7 haplotypes (all singletons))
# TAS: 2 (1 haplotype)
# 25 samples total including the Acadian reference


# Tally by population:
hap_info_lins_tally <- hap_info_lins %>%
  group_by(population, lin) %>%
  tally() %>%
  mutate(tot_lins=sum(n)) %>%
  mutate(prop_lin=n/tot_lins) %>%
  ungroup() %>%
  as.data.frame()

# Now add in sample coordinate data and region info:
samples <- read.csv("./metadata/working/charr_meta_coords.csv")

# Add in region info for my samples:
library(dplyr)
samples <- samples %>% 
  mutate(region=case_when(grepl("PG0",sample)~ "Nunavut",
                          grepl("Satuut",sample)~ "Nunavut",
                          grepl("Robertson",sample)~ "Nunavut",
                          grepl("Tugaat",sample)~ "Nunavut",
                          grepl("Iceland",sample)~ "Europe",
                          grepl("Tasersuaq",sample)~ "Europe",
                          grepl("Green",sample)~ "Europe",
                          grepl("Jan",sample)~ "Europe",
                          grepl("KAN",sample)~ "Labrador",
                          grepl("IKA",sample)~ "Labrador",
                          grepl("10417",sample)~ "Labrador",
                          grepl("IKI",sample)~ "Labrador",
                          grepl("KIN",sample)~ "Labrador",
                          grepl("NAC",sample)~ "Labrador",
                          grepl("10317",sample)~ "Labrador",
                          grepl("PAN",sample)~ "Labrador",
                          grepl("NOR",sample)~ "Labrador",
                          grepl("10917",sample)~ "Labrador",
                          grepl("R7817",sample)~ "Labrador",
                          grepl("MBB",sample)~ "Labrador",
                          grepl("ENG",sample)~ "Labrador",
                          grepl("PBP",sample)~ "Labrador",
                          grepl("ANA",sample)~ "Labrador",
                          grepl("BLD",sample)~ "Labrador",
                          grepl("FR",sample)~ "Labrador",
                          grepl("AVA",sample)~ "Labrador",
                          grepl("Ker",sample)~ "Europe",
                          grepl("SGR",sample)~ "Nunavut",
                          grepl("NNor",sample)~ "Europe",
                          grepl("BI",sample)~ "Europe",
                          grepl("KL19",sample)~ "Nunavut",
                          grepl("SRR",sample)~ "Laval_data"))

# Add in region info for Laval samples:
samples <- samples %>% 
  mutate(region=case_when(grepl("EKA",geo_loc_name)~ "Nunavut",
                          grepl("CRB",geo_loc_name)~ "Nunavut",
                          grepl("AKL",geo_loc_name)~ "Nunavut",
                          grepl("SVG",geo_loc_name)~ "Nunavut",
                          grepl("COP",geo_loc_name)~ "Nunavut",
                          grepl("SPI",geo_loc_name)~ "Nunavik",
                          grepl("SAT",geo_loc_name)~ "Nunavut",
                          grepl("QSG",geo_loc_name)~ "Nunavut",
                          grepl("QNB",geo_loc_name)~ "Nunavut",
                          grepl("PAM",geo_loc_name)~ "Nunavut",
                          grepl("KGJ",geo_loc_name)~ "Nunavut",
                          grepl("IPI",geo_loc_name)~ "Nunavik",
                          grepl("TAH",geo_loc_name)~ "unknown",
                          grepl("HRN",geo_loc_name)~ "NWT",
                          grepl("HAL",geo_loc_name)~ "Nunavut",
                          grepl("GEO",geo_loc_name)~ "Nunavik",
                          grepl("FRM",geo_loc_name)~ "Nunavik",
                          TRUE ~ region))

# Make hap_info_lins_tally wide:
hap_info_lins_wide <- hap_info_lins_tally %>%
  select(population, lin, prop_lin) %>%
  pivot_wider(names_from=lin, 
              values_from=prop_lin)
# Remove NA col (extra "lin" for Sfont), and change NAs in lin cols to zero
hap_info_lins_wide <- hap_info_lins_wide[,-5]
hap_info_lins_wide[is.na(hap_info_lins_wide)] <- 0

# Merge samples with hap_info_lins_wide:
# make pop coords summary df:
samples$lat <- as.numeric(samples$lat)
samples$long <- as.numeric(samples$long)
pop_coords <- samples %>% group_by(population) %>%
  summarise(mean_lat=mean(lat),
            mean_long=mean(long))

hap_info_lins_wide$population <- as.factor(hap_info_lins_wide$population)
pop_coords$population <- as.factor(pop_coords$population)
hap_pop_coords <- merge(hap_info_lins_wide, pop_coords,
                        by="population",
                        all.x=TRUE, all.y=FALSE)
# Acad_ref, Sfont_ref, and TAH don't have coords (fine)
# Note that there were 2 samples in the haplotypes tree that didn't have lineage info
# One was Sfont, the other was KAN1728666 (the weird one outside the ATL clades)

# Plot!
library(sf)
setwd("/Users/sammy/Documents/PhD/charr_all/")
geo.box <- c(xmin=-128.0, xmax=20.0, ymin=50.0, ymax=75.0)
sf::sf_use_s2(FALSE)
library(dplyr)
charr_sites <- sf::read_sf("../../../Desktop/GSHHS_shp/f/GSHHS_f_L1.shp") %>%
  st_crop(geo.box)

library(PieGlyph)
mito_pies <- ggplot(data=charr_sites) + 
  geom_sf(fill="#C1D9C1") +
  theme_bw() + 
  geom_pie_glyph(data=hap_pop_coords,
                 aes(x=mean_long, y=mean_lat), 
                 slices = c("Arctic","Atlantic1", "Atlantic2/Acadian"),
                 radius=0.2, color="black")+
  scale_fill_manual(values=c("#364B9A","#DD3D2D","deeppink4"),
                    labels=c("Arctic","Atlantic1",
                             "Atlantic2/Acadian"),
                    name="Mitogenome haplotype clade")+
  theme(plot.background = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text=element_text(size=12))+
  labs(x = "Longitude", y = "Latitude")+
  theme(axis.title=element_text(size=16))+
  theme(axis.text=element_text(size=16),
        strip.text = element_text(size = 14))
mito_pies

ggsave("./mitogenomes/plots/mito_haps_pies.png",
       mito_pies,
       bg="white",
       width = 14,
       height = 6,
       units = "in",
       dpi = 300)

  
# Add in barplot beside tree for distribution of haplotypes across regions:
#library(aplot)
#hap_merge_tally <- read.table("./mitogenomes/hap_tally_acadref_withfontacad_noKER.txt",
 #                             header=T)
#hap_merge_tally$region <- as.factor(hap_merge_tally$region)
#hap_merge_tally$haplotype <- as.factor(hap_merge_tally$haplotype)

#hap_bar <- ggplot(hap_merge_tally, aes(fill=region, y=n, x=haplotype)) + 
#  geom_bar(position="stack", stat="identity")+
# scale_fill_manual(values=c("gold","orangered4","orangered3","orangered2",
#                            "darkgreen","red","turquoise4","darkblue",
#                            "purple3","magenta"))+
#  coord_flip() + theme_tree2()

#hap_bar %>% insert_left(test_tree_hap,width=1.5)
#dev.off()



# Circular tree:
#library(ggtreeExtra)
#pdf("./mitogenomes/plots/test_tree_hap_circ.pdf", width = 8, height=6)
#tree_hap_circ <- ggtree(tree_hap,
 #                       layout = "circular",
  #                      branch.length = "none",
   #                     size = 0.1)

# add barplot as outer ring
#tree_hap_circ +
 # geom_fruit(data = hap_merge_tally,
  #  geom = geom_bar,
   # mapping = aes(y = haplotype,
    #              x = n,
     #             fill = region),
    #stat = "identity",
    #orientation = "y",
    #pwidth = 0.5) +
  #scale_fill_manual(values = c("gold","orangered4","orangered3","orangered2",
   #                            "darkgreen","red","turquoise4","darkblue",
    #                           "purple3","magenta"))
#dev.off()

 

#### 3. Dloop sequences: tree with Sfont as outgroup, Acad ref with Acad sequence ####
# setwd("C:/Users/sammy/Documents/PhD/charr_all")
# # Use consensus sequence from UFBoot run (1000 bootstrap reps)
# tree_dloop <- read.tree("./mitogenomes/trees/combo_acadref_withfont_multiseqalign_dloop.fasta.treefile")
# # Root tree on Sfont:
# library(ape)
# tree_root_dloop <- ape::root(tree_dloop,
#                            outgroup = "NC_000860.1_Salvelinusfontinalismitochondrioncompletegenome", 
#                            edgelabel = TRUE,
#                            resolve.root=TRUE)
# 
# tree_root_dloop$tip.label # # Labels are too long/messy; clean up
# tree_root_dloop$tip.label <- gsub("^.*?i5\\.", "", tree_root_dloop$tip.label)
# tree_root_dloop$tip.label <- gsub("^NC_000861.1_", "", tree_root_dloop$tip.label)
# 
# library(ggnewscale)
# #pdf("./mitogenomes/plots/test_tree_hap.pdf", width = 8, height=8)
# tree_root_dloop_plot <- ggtree(tree_root_dloop, 
#                              layout="rectangular")+
#   # test_tree_hap <- ggtree(tree_hap,size=0.1,branch.length="none)+
#   theme_tree2()
# # Add haplotype labels to tips:
#  #geom_tiplab(size=0.8)+
# # Add node numbers for subsetting later:
#  #geom_text2(mapping = aes(subset = !isTip, label = node),
# #           size = 1,
# #          color = "darkred")
# 
# 
# scale_dloop_arc <- scaleClade(tree_root_dloop_plot, node=1897, scale=.1)
# scale_dloop_arc_atl <- scaleClade(scale_dloop_arc, node=3350, scale=.1)
# 
# collapse_clades_dloop <- scale_dloop_arc_atl +  geom_hilight(node = 3350,
#                                                  fill = "red",
#                                                  extend = 0.0017, alpha=0.3) + 
#   geom_cladelabel(node=3350, label="Atlantic", 
#                   color="red", offset=0.002,align=FALSE,
#                   fontsize=8)+
#   geom_hilight(node = 1897,
#                fill = "darkblue",alpha=0.3,
#                extend = 0.0017) +
#   geom_cladelabel(node=1897, label="Arctic", 
#                   color="darkblue", offset=0.003,align=FALSE,
#                   fontsize=8)+
#   geom_hilight(node = 3766,
#                fill = "gold",
#                extend = 0.0017)+
#   geom_cladelabel(node=3766, label="Acadian?", 
#                   color="goldenrod", offset=0.001,align=FALSE,
#                   fontsize=8)
# collapse_clades_dloop
# 
# ggsave("./mitogenomes/plots/tree_root_dloop_allseqs.png",
#        collapse_clades_dloop,
#        bg="white",
#        width = 20,
#        height = 16,
#        units = "in",
#        dpi = 300)  
# 



