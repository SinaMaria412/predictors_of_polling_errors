# Instruction on scraping, processing and analysing US presidential election polls

## Data generation

To run the folowiung script you need to subscribe to pollingreport.us and save your username and password in "usr_pwd.txt" (username:password).
First you need to run the [downloadscript_pres.R](https://github.com/SinaMaria412/predictors_of_polling_errors/blob/master/us_president/scrape/downloadscript_pres.R). The websites with polling results from will be downloaded and stored separately for every year and state/group of states as html files. The folder structure is year/html/. In a next step, to convert these html files to txt for further processing run the [convert_txt_pres.R](https://github.com/SinaMaria412/predictors_of_polling_errors/blob/master/us_president/scrape/convert_txt_pres.R) script. Running this script will create the subfolder "txt" within every year folder (year/txt/) with ine txt file per state. To extract the relvant information and combina all in one data frame run [extract_pres.R](https://github.com/SinaMaria412/predictors_of_polling_errors/blob/master/us_president/scrape/extract_pres.R). This data frame includes information on :

- state: state abbreviation
- election_year: year, election took place
- date: last date of field period
- pollFirm: name of polling firm
- n: sample size (if reported)
- respondents: reported respondents, unformatted
- dem_candidate: reported name of Rep. candidaterep_candidate: reported name of Dem. candidate
- rep_poll: Rep. poll vote share 
- dem_poll: Dem. poll vote share 
- rep_poll2: two-party Rep. poll vote share 
- dem_poll2: two-party Dem. poll vote share 
- undecided: share of respondents answerung being undecided (if reported)
- refused: share of poll refusals (if reported)
- third_party: share of third party poll votes (if reported)
- other: share of other poll repsonses (if reported)
- MoE: reported margin of error
- states_long: state name
- dte: temportál distabce between last day of fueld period and election day in days
- state_year: state-level election identifier
- rep_result: Rep. election vote share
- dem_result: Dem. election vote share
- rep_result2: two-party Rep. election vote share
- dem_result2: two-party Dem. election vote share
- resp-formated: formated respondents type: LV = likely voters, RV = registered voters, Statewide = statewide polls
- turnout: turnout
- diff_to_prev: differemnce in turnout to previous state-level election
- to_mean: average state-level turnout from 2000 to 2016

In the [add_variables.R](https://github.com/SinaMaria412/predictors_of_polling_errors/blob/master/us_president/scrape/add_variables.R) file, additional information is added:

- ev: number of electoral college votes
- ev_sc: between 0 and 1 scaled eelctoral college votes
- after_rep: dummy indicating whether the poll was conducted after (0) or before (1) the Rep. national convention
- after_dem: dummy indicating whether the poll was conducted after (0) or before (1) the Dem. national convention
- swing: dummy indicating swing states (1) and safe states (0)
- dte_sc: between 0 and 1 scaled days to election (based on data up to 365 days before election)