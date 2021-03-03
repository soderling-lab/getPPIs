#!/usr/bin/env Rscript

library(dplyr)
library(data.table)

library(igraph)
library(getPPIs)

data(ciPSD) # geneLists
entrez <- unique(unlist(ciPSD))

length(entrez)

data(musInteractome) # getPPIs
data(list=c("mouse","human","rat"), package="getPPIs") # taxids

edge_df <- musInteractome %>% 
	filter(Interactor_A_Taxonomy %in% c(mouse,human,rat)) %>% 
	filter(osEntrezA %in% entrez & osEntrezB %in% entrez) %>%
	select(osEntrezA, osEntrezB, Publications)


g <- simplify(graph_from_data_frame(edge_df))

a <- as.matrix(as_adjacency_matrix(g))

a %>% as.data.table(keep.rownames="Entrez") %>% fwrite("ipsd_netw.csv")
