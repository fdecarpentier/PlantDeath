library(dplyr)
library(tidyr)
library(ggplot2)
library(ggbeeswarm)
library(data.table)

setwd("~/19-ShinyParticles/ParticleDeath")

reslt <- as_tibble(fread("output/results.csv"))
colnames(reslt)[1] <- c("ID")
reslt <- select(reslt, ID, Label, Area, Mean, Max)

ggplot(reslt, aes(Label, Max, colour=Label)) +
  geom_quasirandom()+
  coord_flip()
