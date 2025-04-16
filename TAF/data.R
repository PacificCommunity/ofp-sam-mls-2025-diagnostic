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
cpue <- tmp_data[["CPUE"]]
colnames(cpue) <-c("year", "season", "fishery", "index", "cv")
cpue_nocv=cpue[,-5]

write.taf(cpue_nocv, file = "data/cpue.csv")



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

fwrite(agecomp,"data/agecomp.csv")

catch <- tmp_data$catch
names(catch) <- c("year", "season", "fishery", "catch", "cv")
catch <- catch[catch$year > 1900,]
write.taf(catch, dir="data")

# extract length composition data; reformat from wide to long
# only retain observations fitted in the model
sizefreq <- as.data.table(tmp_data$sizefreq_data_list[[1]]) %>%
           .[,part:=NULL] %>%
           .[,Nsamp:=NULL] %>%
           .[,method:=NULL] %>%
           melt(.,id.vars=c("year","month","fleet","sex")) %>%
           .[,variable:=as.numeric(gsub("a","",variable))] %>%
           .[year>0&value>0] %>%
           setnames(.,c("fleet","variable","value"),c("fishery","weight","freq")) %>%
           .[order(fishery,year,month,length)]
write.taf(sizefreq, "data/weight_comps.csv")

