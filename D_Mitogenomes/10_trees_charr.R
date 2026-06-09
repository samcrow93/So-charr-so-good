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

#### 1. Unique haplotypes: tree with Sfont as outgroup, Acad ref with Acad sequence, no KER, no dup ####
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

#ggsave("./mitogenomes/plots/mito_haps_pies.png",
#       mito_pies,
#       bg="white",
#       width = 14,
#       height = 6,
#       units = "in",
#       dpi = 300)




