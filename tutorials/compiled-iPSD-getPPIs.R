#!/usr/bin/env Rscript

library(dplyr)
library(igraph)
library(data.table)

library(getPPIs)
library(geneLists)

data(ciPSD) # geneLists
entrez <- unique(unlist(ciPSD))

length(entrez)

data(musInteractome) # getPPIs
data(list=c("mouse","human","rat"), package="getPPIs") # taxids

edge_df <- musInteractome %>% 
	filter(Interactor_A_Taxonomy %in% c(mouse,human,rat)) %>% 
	filter(osEntrezA %in% entrez & osEntrezB %in% entrez) %>%
	select(osEntrezA, osEntrezB, Publications) %>%
	mutate(osEntrezA=paste0("entrez",osEntrezA)) %>%
	mutate(osEntrezB=paste0("entrez",osEntrezB))

# ^ row and column indices should be char!

g <- simplify(graph_from_data_frame(edge_df))

a <- as.matrix(as_adjacency_matrix(g))

a %>% as.data.table(keep.rownames="Entrez") %>% fwrite("ipsd_netw.csv")
