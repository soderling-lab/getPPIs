#!/usr/bin/env Rscript

# author: twab
# description: create edge and noa files for Cytoscape
# title: getPPIs

## ---- imports

library(dplyr)
library(data.table)

library(getPPIs) # soderling-lab/getPPIs
library(geneLists) # soderling-lab/geneLists


## ---- load the data

data(musInteractome, package = "getPPIs") # mouse PPIs from HitPredict

goi <- c("Shank2","Shank3","Syngap1","Ube3a")

entrez <- getIDs(goi,from="Symbol",to="Entrez",species="mouse")


## ---- create node annotation (noa) data frame

noa_df <- data.table(node = entrez, goi = TRUE)


## ---- collect ppis

# keep ppis from human, mouse, and rat
os_keep <- c(9606, 10116, 10090) # taxonomix identifiers


# collect interactions between swip and wash_interactome proteins
ppi_df <- musInteractome %>%
	filter(Interactor_A_Taxonomy %in% os_keep) %>%
	filter(Interactor_B_Taxonomy %in% os_keep) %>%
	subset(osEntrezA %in% entrez & osEntrezB %in% entrez)
# ^ make sure you understand dplyr's pipe  %>% !

# simplify things by just selecting the columns we need
edge_df <- ppi_df %>% dplyr::select(osEntrezA, osEntrezB, Publications)

# map entrez IDs to UniProt
protA <- geneLists::getIDs(edge_df$osEntrezA,'entrez','uniprot', "mouse")
protB <- geneLists::getIDs(edge_df$osEntrezB,'entrez','uniprot', "mouse")

# add to table
edge_df <- tibble::add_column(edge_df, protA, .before='osEntrezA')
edge_df <- tibble::add_column(edge_df, protB, .after='protA')


## ---- output

# save edges to file
myfile <- file.path("edges.csv")
data.table::fwrite(edge_df, myfile)
message("saved: ", myfile)

# load edges into cytoscape with File > Import > Network from File

# save noa file
myfile <- file.path("noa.csv")
data.table::fwrite(noa_df, myfile)
message("saved: ", myfile)

# load node attributes into cytoscape with File > Import > Load Table from File

# make sure you understand how cytoscape maps the nodes in your noa.csv file to
# the nodes you have in your graph! 

# NOTE: you can search for goi in Cytoscape with goi:True
