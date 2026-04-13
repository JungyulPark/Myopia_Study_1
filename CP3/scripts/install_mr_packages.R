# Install required packages for CP3 MR
options(repos = c(CRAN = "http://cran.us.r-project.org"))

if (!require("remotes")) install.packages("remotes")
if (!require("dplyr")) install.packages("dplyr")
if (!require("ggplot2")) install.packages("ggplot2")

cat("Installing GitHub dependencies...\n")
remotes::install_github("MRCIEU/TwoSampleMR", upgrade="never")
remotes::install_github("rondolab/MR-PRESSO", upgrade="never")

cat("Done!\n")
library(TwoSampleMR)
library(ieugwasr)
cat("TwoSampleMR is successfully loaded.\n")
