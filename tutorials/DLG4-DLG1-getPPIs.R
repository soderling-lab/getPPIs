#!/usr/bin/env Rscript

# title: getPPIs
# description: get interactions with the key psd scaffold DLG4
# author: twab

## ---- imports

suppressPackageStartupMessages({
  library(dplyr)
  library(data.table)
})

# used for mapping genes:
library(geneLists)

## ---- data

# load the mouse interactome
data(musInteractome, package="getPPIs")


## --- main

# subset for DLG4 
dlg4 <- geneLists::getIDs("Dlg4", "symbol", "entrez", "mouse")

os_keep <- c(9606, 10116, 10090)

# use dplyr::filter to subset
df <- musInteractome %>% 
	# typically, I work with data from mouse human and rat:
	filter(Interactor_A_Taxonomy %in% os_keep) %>% 
	filter(osEntrezA == dlg4 | osEntrezB == dlg4) %>%
	# map entrez to gene symbols
	mutate(symbolA = getIDs(osEntrezA,"entrez","symbol","mouse")) %>%
	mutate(symbolB = getIDs(osEntrezB,"entrez","symbol","mouse")) %>%
	dplyr::select(osEntrezA, symbolA, osEntrezB, symbolB, Methods, Publications)

# we can split into a row for each pub
subdf = df %>% filter(symbolA == "Dlg1" | symbolB == "Dlg1") %>% 
	tidyr::separate_rows(Publications, sep="\\|")

cat(unique(subdf$Publications),sep="\n")
