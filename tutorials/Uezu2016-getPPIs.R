#!/usr/bin/env Rscript

# title: getPPIs
# author: twab
# description: illustrating how you can build a PPI graph


## ---- inputs

library(Uezu2016) # soderling-lab/Uezu2016

data(ipsd)


## ---- imports

library(dplyr)
library(data.table)

library(igraph) # for working with graphs

# to suppress warnings:
# suppressPackageStartupMessages

# load mouse PPI dataset
data(musInteractome,package="getPPIs")


## ---- collect ppis (edges)

# keep interactions from mouse human and rat
os_keep <- c(9606, 10116, 10090)

# subset the data using dplyr's pipe %>% and filter
edges <- musInteractome %>% 
	filter(osEntrezA %in% ipsd & osEntrezB %in% ipsd) %>%
	filter(Interactor_A_Taxonomy %in% os_keep) %>%
	dplyr::select(osEntrezA,osEntrezB) %>% mutate(weight=1)


## ---- convert ppi_df to adjm

G <- graph_from_data_frame(edges, directed=FALSE)

g <- simplify(G)

# convert to adjm with igraph's as_adjacency_matrix
A <- as_adjacency_matrix(g)
adjm <- as.matrix(A)

# save this and cluster it with the leiden alg!

# to preserve rownames we must convert to data.table before saving with fread
a <- as.data.table(adjm, keep.rownames="Protein")
head(colnames(a))

# be careful, adjacency matrices can be heavy!
fwrite(a,"adjm.csv")
