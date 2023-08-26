## Pulling chemical identifiers

# documetnation:
# Rdocumentation: https://rdocumentation.org/packages/webchem/versions/1.1.3
# Github: https://github.com/ropensci/webchem
# Web page: https://docs.ropensci.org/webchem/

#################
##### SETUP #####
#################
rm(list = ls())

## opening libraries
library(webchem)
library(tidyverse)
library(readr)
library(openxlsx)
library(readxl)
library(dplyr)
library(writexl)
library(lubridate)
library(tibble)

################
### SETTINGS ###
################

# setting the folders
data_in <- "data/raw/"
data_out <- "data/out/"
data_temp <- "data/temp/"
data_lookup <- "data/lookup/"

# Naming the import files
casrn_file_csv <- "data/raw/aopwiki_STRESSORS_V13.csv"
casrn_file_xls <- "data/raw/STRESSORS_V13.xlsx"

################
## DATA INPUT ##
################


##Import data with CASRN
input_casrn_raw <- read_csv(casrn_file_csv)
input_casrn_raw <- read_excel(casrn_file_xls)
ra_chem_ident_temp <- read_excel("template/ra_chemical_identifiers.xlsx")

## view data
print(input_casrn_raw)

## Remove prefix CAS_
input_casrn_raw <- input_casrn_raw %>%
  mutate(CAS_RN = gsub("CAS_", "", CAS_RN))

## subset the data set
input_casrn = input_casrn_raw
input_casrn <- slice(input_casrn_raw, 1:3) # %>% select(ID, STRESSOR_NAME, CAS_RN) #for testing

# add column with std inchikey
input_casrn$inchikey <- cts_convert(input_casrn$CAS_RN, from = "CAS", to = "InChIKey", match = "first", verbose = FALSE) %>%
  as.character(unlist(inchikey))

# add column with Pubchem CIDs
x <- get_cid(input_casrn$inchikey, from = "inchikey", match = "first", verbose = FALSE)
merge1 <- full_join(input_casrn, x, by = c("inchikey" = "query"))

# pull chemical properties
y <- pc_prop(merge1$cid, verbose = FALSE) # y <- pc_prop(x$cid, properties = c("IUPACName", "XLogP")) # see properties at https://pubchem.ncbi.nlm.nih.gov/docs/pug-rest#section=Full-record-Retrieval
y$CID <- as.character(y$CID) # make CID into character so can join the tables (can be used as numbers instead)
merge2 <- full_join(merge1, y, by = c("cid" = "CID"))


################
## Tidy data ###
################

# Extract headings
col_names1 <- colnames(ra_chemical_identifiers)
col_names2 <- colnames(merge2)

# print column names
print(col_names1)
print(col_names2)

# create an empty data frame as host for the data
ra_chemical_identifiers <- tibble(
  CHEMICAL_ID = numeric(),
  CHEMICAL_NAME = character(),
  INCHI_STANDARD = character(),
  INCHI_NONSTANDARD = character(),
  INCHI_AUXINFO = character(),
  INCHIKEY_STANDARD = character(),
  INCHIKEY_NONSTANDARD = character(),
  SMILES = character(),
  SMILES_CANONICAL = character(),
  SMILES_CHEMSPIDER = character(),
  CHEMBL_ID = character(),
  CAS_RN = character(),
  TOXCAST_ID = character(),
  PUBCHEM_CID = numeric(),
  PUBCHEM_SID = numeric(),
  PUBCHEM_NAME = character(),
  CHEMSPIDER_ID = numeric(),
  CHEMSPIDER_NAME = character(),
  STATUS = character(),
  DSSTOX_SUBST_ID = character(),
  DWH_VALIDFROMDATE = as.Date(character()),
  DWH_VALIDTODATE = date(),
  DWH_VALID = numeric(),
  MODIFIEDBYPKG = date(),
  stringsAsFactors = FALSE)


bind_rows(ra_chemical_identifiers, merge2)

# reformat to RA_CHEMICAL_IDENTIFERS format
ra_chemical_identifiers <- select(

)

#############
##  Output ##
#############

# Save data to disc
write_csv(input_casrn, "output/cas_inchikey.csv")
write.xlsx(input_casrn, "output/cas_inchikey.xlsx")

# save the dataframe as a CSV file
write_csv(merge2, "output/output.csv")

# save the dataframe as an XLSX file
write_xlsx(merge2, "output/output.xlsx")

# save the dataframe as an RDA file
saveRDS(merge2, "output/output.rda")
