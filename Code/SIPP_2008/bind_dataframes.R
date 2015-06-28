library(dplyr)

####Demog####

#### Read in data ####
setwd("~/GitHub/PeterPascal-Research/Data/SIPP_2008/Output/Demog/")
temp <- list.files(pattern = "*.cy.rda")
for(i in 1:length(temp)) assign(temp[i], load(temp[i]))

cnames <- c("ssuid",     "rfid",     "rsid",     "efnp",     "epppnum",  
            "spanel",   "swave",    "srefmon",  "rhcalmn",  "rhcalyr", 
            "shhadid",  "eentaid",  "esex",     "asex",     "eeducate")

demog <- data.frame(ls())

demog <- demog %>% filter(grepl("demog_", ls..)==T)

demog <-as.character(demog$ls..)

#### Set names ####

demog_m2 <- setNames(demog_m2, cnames)

demog_m3 <- setNames(demog_m3, cnames)

demog_m4 <- setNames(demog_m4, cnames)

demog_m5 <- setNames(demog_m5, cnames)

demog_m6 <- setNames(demog_m6, cnames)

demog_m7 <- setNames(demog_m7, cnames)

demog_m8 <- setNames(demog_m8, cnames)

demog_m9 <- setNames(demog_m9, cnames)

demog_m10 <- setNames(demog_m10, cnames)

demog_m11 <- setNames(demog_m11, cnames)

demog_m12 <- setNames(demog_m12, cnames)

####bind rows####

demog_08 <- bind_rows(demog_m2, demog_m3)

demog_08 <- bind_rows(demog_08, demog_m4)

demog_08 <- bind_rows(demog_08, demog_m5)

demog_08 <- bind_rows(demog_08, demog_m6)

demog_08 <- bind_rows(demog_08, demog_m7)

demog_08 <- bind_rows(demog_08, demog_m8)

demog_08 <- bind_rows(demog_08, demog_m9)

demog_08 <- bind_rows(demog_08, demog_m10)

demog_08 <- bind_rows(demog_08, demog_m11)

demog_08 <- bind_rows(demog_08, demog_m12)

#### save .rda ####

save(demog_08, file = "demog_08.rda")

rm(list=ls())


##### Income ####

#### Read in data ####
setwd("~/GitHub/PeterPascal-Research/Data/SIPP_2008/Output/Income/")
temp <- list.files(pattern = "*.cy.rda")
for(i in 1:length(temp)) assign(temp[i], load(temp[i]))

cnames <- c("ssuid", "rfid", "rsid", "efnp", "epppnum", "spanel", "swave", "srefmon", "rhcalmn", "rhcalyr", 
            "shhadid", "eentaid", "euectyp5", "auectyp5", "tptotinc", "tpearn", "tptrninc", "tpothinc", "tpprpinc",
            "thtotinc", "thearn", "thunemp", "tftotinc", "tfearn", "tfunemp", "tstotinc", "tsfearn", "tsunemp", "tage")

income <- data.frame(ls())

income <- income %>% filter(grepl("income_", ls..)==T)

income <-as.character(income$ls..)

#### Set names ####
income_m1 <- setNames(income_m1, cnames)

income_m2 <- setNames(income_m2, cnames)

income_m3 <- setNames(income_m3, cnames)

income_m4 <- setNames(income_m4, cnames)

income_m5 <- setNames(income_m5, cnames)

income_m6 <- setNames(income_m6, cnames)

income_m7 <- setNames(income_m7, cnames)

income_m8 <- setNames(income_m8, cnames)

income_m9 <- setNames(income_m9, cnames)

income_m10 <- setNames(income_m10, cnames)

income_m11 <- setNames(income_m11, cnames)

income_m12 <- setNames(income_m12, cnames)

####bind rows####

income_08 <- bind_rows(income_m1, income_m2)

income_08 <- bind_rows(income_08, income_m3)

income_08 <- bind_rows(income_08, income_m4)

income_08 <- bind_rows(income_08, income_m5)

income_08 <- bind_rows(income_08, income_m6)

income_08 <- bind_rows(income_08, income_m7)

income_08 <- bind_rows(income_08, income_m8)

income_08 <- bind_rows(income_08, income_m9)

income_08 <- bind_rows(income_08, income_m10)

income_08 <- bind_rows(income_08, income_m11)

income_08 <- bind_rows(income_08, income_m12)

#### save .rda ####

save(income_08, file = "income_08.rda")

rm(list=ls())


#### Labor####

#### Read in data ####

setwd("~/GitHub/PeterPascal-Research/Data/SIPP_2008/Output/Labor/")
temp <- list.files(pattern = "*.cy.rda")
for(i in 1:length(temp)) assign(temp[i], load(temp[i]))

cnames <- c("ssuid", "rfid", "rsid", "efnp", "epppnum", "spanel", "swave", "srefmon", "rhcalmn", "rhcalyr", 
            "shhadid", "eentaid", "epdjbthn", "tbsocc1", "absocc1", "eeno1", "ejbind1", "tbsocc2", "eeno2", 
            "ejbind2", "eppflag", "epopstat", "rmesr", "rwksperm")

labor <- data.frame(ls())

labor <- labor %>% filter(grepl("labor_", ls..)==T)

labor <-as.character(labor$ls..)

#### Set names ####
labor_m1 <- setNames(labor_m1, cnames)

labor_m2 <- setNames(labor_m2, cnames)

labor_m3 <- setNames(labor_m3, cnames)

labor_m4 <- setNames(labor_m4, cnames)

labor_m5 <- setNames(labor_m5, cnames)

labor_m6 <- setNames(labor_m6, cnames)

labor_m7 <- setNames(labor_m7, cnames)

labor_m8 <- setNames(labor_m8, cnames)

labor_m9 <- setNames(labor_m9, cnames)

labor_m10 <- setNames(labor_m10, cnames)

labor_m11 <- setNames(labor_m11, cnames)

labor_m12 <- setNames(labor_m12, cnames)

####bind rows####

labor_08 <- bind_rows(labor_m1, labor_m2)

labor_08 <- bind_rows(labor_08, labor_m3)

labor_08 <- bind_rows(labor_08, labor_m4)

labor_08 <- bind_rows(labor_08, labor_m5)

labor_08 <- bind_rows(labor_08, labor_m6)

labor_08 <- bind_rows(labor_08, labor_m7)

labor_08 <- bind_rows(labor_08, labor_m8)

labor_08 <- bind_rows(labor_08, labor_m9)

labor_08 <- bind_rows(labor_08, labor_m10)

labor_08 <- bind_rows(labor_08, labor_m11)

labor_08 <- bind_rows(labor_08, labor_m12)

#### save .rda ####

save(labor_08, file = "labor_08.rda")

rm(list=ls())


#### weights####

#### Read in data ####

setwd("~/GitHub/PeterPascal-Research/Data/SIPP_2008/Output/Weights/")
temp <- list.files(pattern = "*.cy.rda")
for(i in 1:length(temp)) assign(temp[i], load(temp[i]))

cnames <- c("ssuid", "rfid", "rsid", "efnp", "epppnum", "spanel", "swave", "srefmon", "rhcalmn", 
            "rhcalyr", "shhadid", "eentaid", "wffinwgt", "wsfinwgt", "whfnwgt", "wpfinwgt")

wgts <- data.frame(ls())

wgts <- wgts %>% filter(grepl("weights_", ls..)==T)

wgts <-as.character(wgts$ls..)

#### Set names ####
weights_m1 <- setNames(weights_m1, cnames)

weights_m2 <- setNames(weights_m2, cnames)

weights_m3 <- setNames(weights_m3, cnames)

weights_m4 <- setNames(weights_m4, cnames)

weights_m5 <- setNames(weights_m5, cnames)

weights_m6 <- setNames(weights_m6, cnames)

weights_m7 <- setNames(weights_m7, cnames)

weights_m8 <- setNames(weights_m8, cnames)

weights_m9 <- setNames(weights_m9, cnames)

weights_m10 <- setNames(weights_m10, cnames)

weights_m11 <- setNames(weights_m11, cnames)

weights_m12 <- setNames(weights_m12, cnames)

####bind rows####
#weights_08 <- bind_rows(weights_m1, weights_m2)

weights_08 <- bind_rows(weights_m1, weights_m3)

#weights_08 <- bind_rows(weights_08, weights_m3)

weights_08 <- bind_rows(weights_08, weights_m4)

weights_08 <- bind_rows(weights_08, weights_m5)

weights_08 <- bind_rows(weights_08, weights_m6)

weights_08 <- bind_rows(weights_08, weights_m7)

weights_08 <- bind_rows(weights_08, weights_m8)

weights_08 <- bind_rows(weights_08, weights_m9)

weights_08 <- bind_rows(weights_08, weights_m10)

weights_08 <- bind_rows(weights_08, weights_m11)

weights_08 <- bind_rows(weights_08, weights_m12)

#### save .rda ####

save(weights_08, file = "weights_08.rda")

rm(list=ls())
