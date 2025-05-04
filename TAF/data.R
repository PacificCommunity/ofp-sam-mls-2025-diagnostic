# Prepare data, write CSV data tables

# Before: data_echo.ss_new (boot/data)
# After:  catch.csv, cpue.csv, length_comps.csv, weight_comps.csv (data)

library(TAF)
library(r4ss)
library(data.table)
library(magrittr)

mkdir("data")

# Read in Stock Synthesis data file
dat <- SS_readdat("boot/data/data_echo.ss_new")

# Otoliths
oto <- dat$agecomp
x <- oto
x$Nsamp <- NULL
cols <- c("year", "month", "fleet", "sex", "part", "ageerr", "Lbin_lo",
          "Lbin_hi")
# Store variables as a combined string
rowlab <- apply(x[cols], 1, paste, collapse = "|")
# Prepare composition data
x <- x[!names(x) %in% cols]
names(x) <- gsub("[a-z]", "", names(x))
x <- as.matrix(x)
row.names(x) <- rowlab
# Convert composition data to long format
comp <- as.data.frame(as.table(x), stringsAsFactors = FALSE)
vars <- read.table(text = comp[["Var1"]], sep = "|", col.names = cols)
comp[["Var1"]] <- NULL
comp[["Var2"]] <- type.convert(comp[["Var2"]], as.is = TRUE)
names(comp) <- c("age", "freq")
# Combine vars and comp
out <- data.frame(vars, comp)
# Remove zero freq
out <- out[out$freq > 0,]
# One line per sample
out <- out[rep(seq_len(nrow(out)), out$freq),]

# Extract catch
catch <- dat$catch
names(catch) <- c("year", "season", "fishery", "catch", "cv")
catch <- catch[catch$year > 0,]
write.taf(catch, dir="data")

# Extract CPUE
cpue <- dat$CPUE
colnames(cpue) <- c("year", "season", "fishery", "index", "cv")

# Extract length comps
# reformat from wide to long, exclude negative years
length.comps <- as.data.table(dat$lencomp) %>%
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
weight.comps <- as.data.table(dat$sizefreq_data_list[[1]]) %>%
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
