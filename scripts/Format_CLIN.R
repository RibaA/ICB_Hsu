## load libraries
library(stringr)
library(tibble)

args <- commandArgs(trailingOnly = TRUE)
#input_dir <- args[1]
#output_dir <- args[2]
#annot_dir <- args[3]

input_dir <- "data/input"
output_dir <- "data/output"
annot_dir <- "data/annot"

source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/Get_Response.R")
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/annotate_tissue.R")
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/annotate_drug.R")

clin = read.csv( file.path(input_dir, "CLIN.txt"), stringsAsFactors=FALSE , sep="\t" , header=TRUE )
rownames(clin) <- clin$patientid
cols <- c('patientid', 'gender.ch1', 'age.ch1', 'best_response.ch1', 'os_event.ch1', 'os_time.ch1',
          'pfs_event.ch1', 'pfs_time.ch1')

clin <- clin[, c(cols, colnames(clin)[!colnames(clin) %in% cols])]
colnames(clin)[colnames(clin) %in% cols] <- c('patient', 'sex', 'age', "recist",
                                              'os', 't.os', 'pfs', 't.pfs')

new_cols <- c( 'histo', "stage", "primary" , "response.other.info" , "response" , "drug_type" , "dna" , "rna", "rna.info")
clin[new_cols] <- NA

clin$drug_type <- 'PD-1/PD-L1'
clin$rna <- 'nanostring'
clin$rna.info <- 'cpm'
clin$primary <- 'Liver'

clin$os <- ifelse(clin$os == 'Yes', 1, ifelse(clin$os == 'No', 0, NA)) 
clin$pfs <- ifelse(clin$pfs == 'Yes', 1, ifelse(clin$pfs == 'No', 0, NA)) 
clin$t.os <- clin$t.os/ 4.345
clin$t.pfs <- clin$t.pfs/ 4.345

clin$response = Get_Response( data=clin )

# Tissue and drug annotation
annotation_tissue <- read.csv(file=file.path(annot_dir, 'curation_tissue.csv'))
clin <- annotate_tissue(clin=clin, study='Hsu', annotation_tissue=annotation_tissue, check_histo=FALSE)

annotation_drug <- read.csv(file=file.path(annot_dir, 'curation_drug.csv'))
clin <- add_column(clin, treatmentid=clin$drug_type, .after='tissueid')

write.table( clin , file=file.path(output_dir, "CLIN.csv") , quote=FALSE , sep=";" , col.names=TRUE , row.names=FALSE )

