########################################################################################
# Extract presidential polls from txt fies
# Author: Sina Chen
#
########################################################################################

#### Libraries ####

library(dplyr)
library(stringr)
library(rvest)
library(readr)
library(openintro) # state abbreviations
library(Metrics)


#### Directory ####

pres_wd <- 'your working directory'
setwd(pres_wd)


#### Helper functions ####

source('helper_func_pres.R')


#### Get list of polls by state form txt files ####

# Directories with txt content for every year

{
  dir_txt2000 <- paste0(pres_wd, '/year2000/txt')
  dir_txt2004 <- paste0(pres_wd, '/year2004/txt')
  dir_txt2008 <- paste0(pres_wd, '/year2008/txt')
  dir_txt2012 <- paste0(pres_wd, '/year2012/txt')
  dir_txt2016 <- paste0(pres_wd, '/year2016/txt')
}

{
  poll_raw2000 <- read_pres(dir_txt2000)
  poll_raw2004 <- read_pres(dir_txt2004)
  poll_raw2008 <- read_pres(dir_txt2008)
  poll_raw2012 <- read_pres(dir_txt2012)
  poll_raw2016 <- read_pres(dir_txt2016)
}



#### Extract presidential polls ####

{
  # 2000
  polls2000 <- lapply(poll_raw2000, clean_split) 
  pres_polls_ls2000 <- lapply(polls2000, rm_other)
  pres_polls2000 <- convert_to_dataframe(pres_polls_ls2000, 
                                         repC = 'Bush|[(]R[)]', 
                                         demC = 'AlGore|Al Gore|Gore|[(]D[)]', 
                                         thirdC = 'Nader|[(]L[)]|[(]I[)]|[(]G[)]', 
                                         year = 2000)
  
  # 2004
  polls2004 <- lapply(poll_raw2004, clean_split)
  pres_polls_ls2004 <- lapply(polls2004, rm_other)
  pres_polls2004 <- convert_to_dataframe(pres_polls_ls2004, repC = 'Bush|[(]R[)]',
                                         demC = 'Kerry|Dean|Lieb|Clark|Clinton|Gephardt|Democrat|Edwards|Demo- crat|Daschle|[(]D[)]', 
                                         thirdC = 'Nader|Third-party|[(]L[)]|[(]I[)]|[(]G[)]', 
                                         year = 2004)
  
  # 2008
  polls2008 <- lapply(poll_raw2008, clean_split)
  pres_polls_ls2008 <- lapply(polls2008, rm_other)
  pres_polls2008 <- convert_to_dataframe(pres_polls_ls2008, 
                                         repC = 'McCain|[(]R[)]|Republican|Romney|Giuliani', 
                                         demC = 'Obama|Clinton|[(]D[)]|Democratic|Kerry|Democrat', 
                                         thirdC = 'Nader|Third-party|[(]L[)]|[(]I[)]|[(]G[)]', 
                                         year = 2008)
  
  # 2012
  polls2012 <- lapply(poll_raw2012, clean_split)
  pres_polls_ls2012 <- lapply(polls2012, rm_other)
  pres_polls2012 <- convert_to_dataframe(pres_polls_ls2012, 
                                         repC = '[(]R[)]|Republican|Romney', 
                                         demC = 'Obama|[(]D[)]|Democratic', 
                                         thirdC = 'Third-party|Johnson|Stein|[(]L[)]|[(]I[)]|[(]G[)]', 
                                         year = 2012)

  # 2016
  polls2016 <- lapply(poll_raw2016, clean_split)
  pres_polls_ls2016 <- lapply(polls2016, rm_other)
  pres_polls2016 <- convert_to_dataframe(pres_polls_ls2016, 
                                         repC = '[(]R[)]|Republican|Trump', 
                                         demC = 'Clinton|[(]D[)]|Democratic', 
                                         thirdC = 'Third-party|[(]L[)]|[(]I[)]|[(]G[)]', 
                                         year = 2016)
  
}

pres_polls2000_2016 <- rbind(pres_polls2000, 
                            pres_polls2004, 
                            pres_polls2008, 
                            pres_polls2012, 
                            pres_polls2016)


#### Add variables ####

# Add state abbreviation
pres_polls2000_2016$state <- state2abbr(pres_polls2000_2016$states_long)

# Create "Days to election"
pres_polls2000_2016 <- pres_polls2000_2016 %>% mutate(
  dte = case_when(
    election_year == '2000' ~ difftime(as.Date('11/07/2000', '%m/%d/%Y'), 
                                       as.Date(date), units = 'days'),
    election_year == '2004' ~ difftime(as.Date('11/02/2004', '%m/%d/%Y'), 
                                       as.Date(date), units = 'days'),
    election_year == '2008' ~ difftime(as.Date('11/04/2008', '%m/%d/%Y'), 
                                       as.Date(date), units = 'days'),
    election_year == '2012' ~ difftime(as.Date('11/06/2012', '%m/%d/%Y'), 
                                       as.Date(date), units = 'days'),
    election_year == '2016' ~ difftime(as.Date('11/08/2016', '%m/%d/%Y'), 
                                       as.Date(date), units = 'days')
  ),
  state_year = paste0(state, election_year)
)



# Add election results (source: Wikipedia)
election_result <- readRDS('election_result.RDS')

pres_polls2000_2016 <- merge(pres_polls2000_2016, election_result, 
                             by = c('election_year', 'state'))

# Scale poll to percentage
pres_polls2000_2016$rep_poll <- as.numeric(pres_polls2000_2016$rep_poll)/100
pres_polls2000_2016$dem_poll <- as.numeric(pres_polls2000_2016$dem_poll)/100
pres_polls2000_2016$refused <- as.numeric(pres_polls2000_2016$refused)/100
pres_polls2000_2016$undecided <- as.numeric(pres_polls2000_2016$undecided)/100
pres_polls2000_2016$third_party <- as.numeric(pres_polls2000_2016$third_party)/100
pres_polls2000_2016$other <- as.numeric(pres_polls2000_2016$other)/100

# Compute twp-party vote share for election results and polls
pres_polls2000_2016 <- pres_polls2000_2016 %>% 
  mutate(rep_result2 = rep_result/(rep_result + dem_result),
         dem_result2 = dem_result/(rep_result + dem_result),
         rep_poll2 = rep_poll/(rep_poll + dem_poll),
         dem_poll2 = dem_poll/(rep_poll + dem_poll))

# Format respondents
pres_polls2000_2016$resp_formated <- sapply(pres_polls2000_2016$respondents, resp)

# Add turnout (source: Wikipedia)
turnout <- readRDS('turnout.RDS')
pres_polls2000_2016 <- merge(pres_polls2000_2016, turnout, by = c('state', 'election_year'))

# Set missing unformation on sample size to NA
pres_polls2000_2016$n <- na_if(pres_polls2000_2016$n, '-')

# Save data
saveRDS(pres_polls2000_2016, 'pres_polls2000_2016.RDS')
