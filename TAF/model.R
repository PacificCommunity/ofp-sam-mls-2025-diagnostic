# Run analysis, write model results

# Before:
# After:

library(TAF)

mkdir("model")

# Copy executable
cp("../SS3/ss3_linux",   "model")

# Copy input files
cp("../SS3/control.ss",  "model")
cp("../SS3/data.ss",     "model")
cp("../SS3/forecast.ss", "model")
cp("../SS3/starter.ss",  "model")

# Run model
setwd("model")
system("ss3_linux")
setwd("..")
