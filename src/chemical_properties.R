## Pulling chemical proprty data from inchikey

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
## DATA INPUT ##
################

##Import data with CASRN
input_inchikey <- read_excel("data/raw/lacking_chem_prop.xlsx") %>%
  rename(inchikey = INCHIKEY_STANDARD)

# add column with Pubchem CIDs
x <- get_cid(input_inchikey$inchikey, from = "inchikey", match = "first", verbose = FALSE)
merge1 <- full_join(input_inchikey, x, by = c("inchikey" = "query"))

# add column with Pubchem CIDs
x <- get_cid(input_inchikey_raw$inchikey, from = "inchikey", match = "first", verbose = FALSE)

# pull chemical properties
y <- pc_prop(merge1$cid, verbose = FALSE) # y <- pc_prop(x$cid, properties = c("IUPACName", "XLogP")) # see properties at https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/property/IUPACName,XLogP/JSON
y$CID <- as.character(y$CID) # make CID into character so can join the tables (can be used as numbers instead)
merge2 <- full_join(merge1, y, by = c("cid" = "CID"))

# save to xlsx

write.xlsx(merge2, "output/chem_prop.xlsx")
