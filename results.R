library(dplyr)
library(tidyr)
library(ggplot2)
library(ggbeeswarm)
library(data.table)
library(ggpubr)

setwd("~/19-ShinyParticles/ParticleDeath")

reslt <- as_tibble(fread("output/results.csv"))
colnames(reslt)[1] <- c("ID")
reslt <- select(reslt, ID, Label, Area, Mean, Max) 

barMax <- tibble(Label="bar", Max = 40)

ggplot(reslt, aes(Label, Max, colour=Label)) +
  geom_quasirandom(alpha=.5)+
  geom_point(data=barMax)+
  theme_classic()+
  coord_flip()

alive <- mutate(reslt, Death = ifelse(Max>40, "alive", "dead")) %>%
  mutate(areaLog=log(Area)) %>%
  filter(Label!="eb.tif") %>%
  unite(LabelDeath, Label, Death, remove=F)

ggplot(alive, aes(Label, log(Area), colour=Death))+
  geom_quasirandom(alpha=.3)+
  coord_flip()+
  scale_colour_manual(values=c("#18ab49", "#cc3300"))+
  theme_classic()+
  theme(legend.position = c(.075, .90))


a <- ggplot(alive, aes(x = log(Area), fill = Death))+
  geom_histogram(bins = 30, position = "fill")+
  scale_fill_manual(values=c("#18ab49", "#cc3300"))+
  facet_wrap(Label~.)+
  theme_classic()
a  

b <- ggdensity(alive,x = "areaLog", fill="Death")+
  scale_fill_manual(values=c("#18ab49", "#cc3300"))+
  facet_wrap(Label~., scale="free")
b

c <- ggdensity(alive,x = "areaLog", fill="Label", color="Label", palette = "jco")
  facet_wrap(Label~.) +
  rremove("legend")
c

subset <- filter(alive, Label == "D66 RB 4.jpg")

d <- ggplot(subset, aes(x = log(Area), fill = Death))+
  geom_histogram(bins = 30, position = "stack")+
  scale_fill_manual(values=c("#18ab49", "#cc3300"))+
  ggtitle(subset$Label)+
  theme_classic()

d

e <- ggdensity(subset,x = "areaLog", fill="Death")+
  scale_fill_manual(values=c("#18ab49", "#cc3300"))

e
