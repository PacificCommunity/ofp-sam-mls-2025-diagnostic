# Prepare data, write CSV data tables

# Before: data_echo.ss_new (boot/data)
# After:  catch.csv, cpue.csv, length_comps.csv, weight_comps.csv (data)

library(TAF)
library(r4ss)
library(data.table)
library(magrittr)

mkdir("data")

# Read in Stock Synthesis data file
tmp_data <- SS_readdat("boot/data/data_echo.ss_new")

# Extract catch
catch <- tmp_data$catch
names(catch) <- c("year", "season", "fishery", "catch", "cv")
catch <- catch[catch$year > 0,]
write.taf(catch, dir="data")

# Extract CPUE
cpue <- tmp_data$CPUE
colnames(cpue) <- c("year", "season", "fishery", "index", "cv")

# Extract length comps
# reformat from wide to long, exclude negative years
length.comps <- as.data.table(tmp_data$lencomp) %>%
  .[, sex:=NULL] %>%
  .[, part:=NULL] %>%
  .[, Nsamp:=NULL] %>%
  melt(., id.vars=c("year", "month", "fleet")) %>%
  .[, variable:=as.numeric(gsub("l","",variable))] %>%
  .[year > 0] %>%
  setnames(., c("fleet","variable","value"), c("fishery","length","freq")) %>%
  .[order(fishery, year, month, length)]

# Extract weight comps
# reformat from wide to long, exclude negative years
weight.comps <- as.data.table(tmp_data$sizefreq_data_list[[1]]) %>%
  .[, method:=NULL] %>%
  .[, sex:=NULL] %>%
  .[, part:=NULL] %>%
  .[, Nsamp:=NULL] %>%
  melt(., id.vars=c("year", "month", "fleet")) %>%
  .[, variable:=as.numeric(gsub("a","",variable))] %>%
  .[year > 0] %>%
  setnames(.,c("fleet","variable","value"), c("fishery","weight","freq")) %>%
  .[order(fishery, year, month, weight)]

# Write tables
write.taf(catch, dir="data")
write.taf(cpue, dir="data")
write.taf(length.comps, dir="data")
write.taf(weight.comps, dir="data")
