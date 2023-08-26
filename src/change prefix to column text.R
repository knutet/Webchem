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
library(stringr)

###########
### process ##
###########

# Load data
data_raw <- read_excel("data/raw/Vm_unique_substances.xlsx")
data_raw <- read_csv("data/raw/Vm_unique_substances.csv")

# remove a prefix string in data
data_clean <- data_raw %>%
  mutate(CAS_RN = gsub("CAS_", "", CAS_RN)) %>%
  mutate(Frequency = "") %>%
  mutate(Frequency = as.numeric(Frequency))

# remove and add a prefix string in data
data_clean_prefix <- data_raw %>%
  mutate(CAS_RN = gsub("CAS_", "", CAS_RN)) %>%
  mutate(CAS_RN = paste("CAS_", CAS_RN)) %>%
  mutate(CAS_RN = gsub(" ", "", CAS_RN)) %>%
  mutate(Frequency = "") %>%
  mutate(Frequency = as.numeric(Frequency))

# add a prefix string in data
data_prefix <- data_raw %>%
  mutate(CAS_RN = paste("CAS_", CAS_RN)) %>%
  mutate(CAS_RN = gsub(" ", "", CAS_RN)) %>%
  mutate(Frequency = "") %>%
  mutate(Frequency = as.numeric(Frequency))


#############
##  Output ##
#############

# Save data to disc

# save the dataframe as a CSV file
write_csv(data_clean, "output/data_clean.csv")
write_csv(data_clean_prefix, "output/data_clean_prefix.csv")
write_csv(data_prefix, "output/data_prefix.csv")

# save the dataframe as a xlsx file
write_xlsx(data_clean, "output/data_clean.xlsx")
write_xlsx(data_clean_prefix, "output/data_clean_prefix.xlsx")
write_xlsx(data_prefix, "output/data_prefix.xlsx")

# save the dataframe as a rda file
save(data_clean, file = "output/data_clean.rda")
save(data_clean_prefix, file = "output/data_clean_prefix.rda")
save(data_prefix, file = "output/data_prefix.rda")

# load .rda files
load("output/data_clean.rda")
load("output/data_clean_prefix.rda")
load("output/data_prefix.rda")
