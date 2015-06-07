library(survey)		# load survey package (analyzes complex design surveys)
library(RSQLite) 	# load RSQLite package (creates database files in R)



# if this option is set to TRUE
# R will exactly match SUDAAN results and Stata with the MSE option results
options( survey.replicates.mse = TRUE )

# otherwise if it is commented out or set to FALSE
# R will exactly match Stata without the MSE option results

# Stata svyset command notes can be found here: http://www.stata.com/help.cgi?svyset


# immediately connect to the SQLite database
# this connection will be stored in the object 'db'
db <- dbConnect( SQLite() , "SIPP08.db" )

#### DB query ####

query_vars <- ("SELECT 'ssuid' , 'spanel', 'swave', 'srotation', 'srefmon', 'rhcalmn', 'rhcalyr', 'shhadid', 'thearn', 'rhcbrf', 'thunemp', 'eckjt', 'ackjt', 'tckjtint', 'ackjtint','eckoast', 'ackoast', 'tckoint', 'ackoint', 'esvjt', 'asvjt', 'tsvjtint', 'asvjtint','esvoast', 'asvoast', 'tsvoint', 'asvoint', 'emdjt', 'amdjt', 'tmdjtint', 'amdjtint','emdoast', 'amdoast', 'tmdoint', 'amdoint'")

query_db <- function(dbase){
  for (i in list(dbListTables(dbase))){
    dbSendQuery(dbase, paste0(query_vars, " FROM ",i))
  }
}

x <-dbSendQuery(db, "SELECT 'ssuid' , 'spanel', 'swave', 'srotation', 'srefmon', 'rhcalmn', 'rhcalyr', 'shhadid', 'thearn', 'rhcbrf', 'thunemp', 'eckjt', 'ackjt', 'tckjtint', 'ackjtint','eckoast', 'ackoast', 'tckoint', 'ackoint', 'esvjt', 'asvjt', 'tsvjtint', 'asvjtint','esvoast', 'asvoast', 'tsvoint', 'asvoint', 'emdjt', 'amdjt', 'tmdjtint', 'amdjtint','emdoast', 'amdoast', 'tmdoint', 'amdoint'
            FROM w1")

