## load libraries

library(GEOquery)
library(data.table)
library(readxl)
library(readr)
library(stringr)

args <- commandArgs(trailingOnly = TRUE)
#work_dir <- args[1]
work_dir <- "data"

# CLIN.txt
gse <- getGEO("GSE140901", GSEMatrix = TRUE, AnnotGPL = TRUE)
dat <- gse[[1]]

# Extract clinical/phenotype (metadata / sample info)
clin <- pData(dat)
clin <- as.data.frame(clin)
clin$patientid <- sapply(1:nrow(clin), function(k){
strsplit(clin$title[k], ' ')[[1]][2]
})

clin <- clin[order(clin$patientid), ]

write.table(clin, file=file.path(work_dir, 'CLIN.txt'), sep = "\t" , quote = FALSE , row.names = FALSE)

# EXP_CPM.tsv 
expr <- read.table(
  file.path(work_dir, "GSE140901_processed_data.txt.gz"),
  header = TRUE,
  sep = "\t",
  skip = 2,
  row.names = 1,
  stringsAsFactors = FALSE,
  check.names = FALSE)

expr <- expr[-1, ]
colnames(expr) <- as.character(expr[1, ])
expr <- expr[-1, ]
expr[] <- lapply(expr, as.numeric)
expr <- expr[, 1:24]
expr <- expr[, order(colnames(expr))]

write.table(expr, file=file.path(work_dir, 'EXP_TPM.tsv'), sep = "\t" , quote = FALSE , row.names = TRUE, col.names=TRUE)
