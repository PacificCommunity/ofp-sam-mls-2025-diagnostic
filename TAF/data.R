# Prepare data, write CSV data tables

# Before:
# After:

library(TAF)
library(r4ss)
library(data.table)
library(magrittr)

mkdir("data")

# read in Stock Synthesis data file
tmp_data = SS_readdat("boot/data/data_echo.ss_new")

# extract length composition data; reformat from wide to long
# only retain observations fitted in the model
lencomp <- as.data.table(tmp_data$lencomp) %>%
           .[,part:=NULL] %>%
           .[,Nsamp:=NULL] %>%
           melt(.,id.vars=c("year","month","fleet","sex")) %>%
           .[,variable:=as.numeric(gsub("l","",variable))] %>%
           .[year>0&value>0] %>%
           setnames(.,c("fleet","variable","value"),c("fishery","length","freq")) %>%
           .[order(fishery,year,month,length)]

fwrite(lencomp,"data/lencomp.csv")

# extract age composition data; reformat from wide to long
# only retain observations fitted in the model
agecomp <- as.data.table(tmp_data$agecomp) %>%
           .[,part:=NULL] %>%
           .[,ageerr:=NULL] %>%
           .[,Nsamp:=NULL] %>%
           .[,Lbin_lo:=NULL] %>%
           melt(.,id.vars=c("year","month","fleet","sex","Lbin_hi")) %>%
           .[,variable:=as.numeric(gsub("a","",variable))] %>%
           .[year>0&value>0] %>%
           setnames(.,c("fleet","variable","value","Lbin_hi"),c("fishery","age","freq","length")) %>%
           .[order(fishery,year,month,age,length)] %>%
           .[,.(year,month,fishery,sex,age,length,freq)]

fwrite(lencomp,"data/agecomp.csv")