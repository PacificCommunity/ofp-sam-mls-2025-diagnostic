# Prepare data, write CSV data tables

# Before:
# After:

library(TAF)
library(r4ss)

mkdir("data")

tmp_data = SS_readdat("boot/data/data_echo.ss_new")

lencomp <- tmp_data$lencomp
