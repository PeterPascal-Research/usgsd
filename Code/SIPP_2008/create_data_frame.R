# set your working directory.
# this directory must contain the SIPP 2008 database (.db) file 
# "SIPP08.db" created by the R program specified above
# use forward slashes instead of back slashes

# uncomment this line by removing the `#` at the front..
setwd( "~/GitHub/PeterPascal-Research/SIPP/SIPP_2008" )
# ..in order to set your current working directory


# remove the # in order to run this install.packages line only once
# install.packages( c( "survey" , "RSQLite" ) )


library(survey)		# load survey package (analyzes complex design surveys)
library(RSQLite) 	# load RSQLite package (creates database files in R)


# increase size at which numbers are presented in scientific notation

options( scipen = 10 )


# if this option is set to TRUE
# R will exactly match SUDAAN results and Stata with the MSE option results
#options( survey.replicates.mse = TRUE )
# otherwise if it is commented out or set to FALSE
# R will exactly match Stata without the MSE option results

# Stata svyset command notes can be found here: http://www.stata.com/help.cgi?svyset


# immediately connect to the SQLite database
# this connection will be stored in the object 'db'
db <- dbConnect( SQLite() , "SIPP08.db" )


#############################################
# access the appropriate core waves of data #

# which waves would you like to pull?  to pull an entire calendar year, you must pull each interview that overlaps the year you want

waves <- 1:16 
year <- c(2008, 2009, 2010, 2011, 2012, 2013)  
mainwgt <- c('lgtcy1wt','lgtcy2wt','lgtcy3wt', 'lgtcy4wt', 'lgtcy5wt') 
yrnum <- 1:5


# make a character vector containing the variables that should be kept from the core file (core keep variables)
core.kv <- 
	c( 
	  'ssuid' , 'rfid', 'rsid', 'efnp', 'epppnum', 'spanel', 'swave','srefmon', 'rhcalmn', 
	  'rhcalyr', 'shhadid', 'eentaid', 'esex', 'asex', 'eeducate'
	  )


# each core wave data file contains data at the person-month level.  in general, there are four records per respondent in each core wave data set.

# in order to create a file containing every individual's monthly observations throughout the calendar year,
# query each of the waves designated above, removing each record containing an rhcalyr (calendar year) matching the year designated above

########################################################################
# loop through all twelve months, merging each month onto the previous #
start.time <- Sys.time()

for ( i in 1:12 ){

	# print the current progress to the screen
	cat( "currently working on month" , i , "of 12" , "\r" )

	# create a character vector containing each of the column names,
	# with a month number at the end, so long as it's not one of the two merge variables
	numbered.core.kv <-
		# determine column names of each variable
		paste0(
			core.kv ,
			ifelse( 
				# if the column name is either of these two..
				core.kv %in% c( "ssuid" , "epppnum" ) , 
				# ..nothing gets pasted.
				"" , 
				# otherwise, a month number gets pasted
				i 
			) 
		)

		
	# create the same character vector missing 'ssuid' and 'epppnum'
	no.se.core.kv <- numbered.core.kv[ !( numbered.core.kv %in% c( 'ssuid' , 'epppnum' ) ) ]
		
		
	# create a sql string containing the select command used to pull only a defined number of columns
	# and records containing january, looking at each of the specified waves
	sql.string <- 
		# this outermost paste0 just specifies the temporary table to create
		paste0(
			"create temp table sm as " ,
			# this paste0 combines all of the strings contained inside it,
			# separating each of them by "union all" -- actively querying multiple waves at once
			paste0( 
				paste0( 
					"select " , 
					# this paste command collapses all of the old + new variable names together,
					# separating them by a comma
					paste( 
						# this paste command combines the old and new variable names, with an "as" in between
						paste(
							core.kv , 
							"as" ,
							numbered.core.kv 
						) ,
						collapse = "," 
					) , 
					" from w" 
				) , 
				waves , 
				paste0( 
					" where rhcalmn == " ,
					i ,
					" AND rhcalyr == " , 
					year 
				) , 
				collapse = " union all " 
			)
		)

	# take a look at the full query if you like..
	sql.string
	
	# run the actual command (this takes a while)
	dbSendQuery( db , sql.string )
	
	# if it's the first month..
	if ( i == 1 ){
	
		# create the single year (sy1) table from the january table..
		dbSendQuery( db , "create temp table sy1 as select * from sm" )
		
		# ..and drop the current month table.
		dbRemoveTable( db , "sm" )
	
	# otherwise..
	} else {
	
		# merge the current month onto the single year (sy#) table..
		dbSendQuery( 
			db , 
			paste0( 
				"create temp table sy" , 
				i , 
				" as select a.* , " ,
				paste0( "b." , no.se.core.kv , collapse = "," ) , 
				" from sy" ,
				i - 1 ,
				" as a left join sm as b on a.ssuid == b.ssuid AND a.epppnum == b.epppnum" 
			)
		)
		
		# ..and drop the current month table.
		dbRemoveTable( db , "sm" )
	
	}

}

# subtract the current time from the starting time,
# and print the total twelve-loop time to the screen
Sys.time() - start.time


# once the single year (sy) table has information from all twelve months, extract it from the rsqlite database
x <- dbGetQuery( db , "select * from sy12" )


# look at the first six records of x
head( x )

write.csv(x, "SIPP_2008_Core_Demog.csv")

# #################################################
# # save your data frame for quick analyses later #
# 
# # in order to bypass the above steps for future analyses,
# # the data frame in its current state can be saved now
# # (or, really, anytime you like).  uncomment this line:
# # save( y , file = "sipp08.cy.rda" )
# # or, to save to another directory, specify the entire filepath
# # save( y , file = "C:/My Directory/sipp08.cy.rda" )
# 
# # at a later time, y can be re-accessed with the load() function
# # (just make sure the current working directory has been set to the same place)
# # load( "sipp08.cy.rda" )
# # or, if you don't set the working directory, just specify the full filepath
# # load( "C:/My Directory/sipp08.cy.rda" )
# 
# 
# ###########################################
#access the appropriate main weight data #
#run the sql query constructed above, save the resulting table in a new data frame called 
#'mw' that will now be stored in RAM
mw <- dbGetQuery( db , "select * from wgtw16" )
 
# # dump the `spanel` variable, which might otherwise sour up your merge
mw$spanel <- NULL

# # look at the first six records of mw
head( mw )

write.csv(mw, "SIPP_2008_Weights_Demog.csv")

rm(x, mw, core.kv)

gc()

########################################################################################
#income 
core.kv <- 
	c( 
	  'ssuid' , 'rfid', 'rsid', 'efnp', 'epppnum', 'spanel', 'swave','srefmon', 'rhcalmn', 
	  'rhcalyr', 'shhadid', 'eentaid',
	  'euectyp5', 'auectyp5',
	  'tptotinc', 'tpearn', 'tptrninc', 'tpothinc', 'tpprpinc', 
	  'thtotinc', 'thearn', 'thunemp', 
	  'tftotinc', 'tfearn', 'tfunemp', 
	  'tstotinc', 'tsfearn', 'tsunemp',
	  'tage'
	  )


# each core wave data file contains data at the person-month level.  in general, there are four records per respondent in each core wave data set.

# in order to create a file containing every individual's monthly observations throughout the calendar year,
# query each of the waves designated above, removing each record containing an rhcalyr (calendar year) matching the year designated above

########################################################################
# loop through all twelve months, merging each month onto the previous #



# #################################################
# # save your data frame for quick analyses later #
# 
# # in order to bypass the above steps for future analyses,
# # the data frame in its current state can be saved now
# # (or, really, anytime you like).  uncomment this line:
# # save( y , file = "sipp08.cy.rda" )
# # or, to save to another directory, specify the entire filepath
# # save( y , file = "C:/My Directory/sipp08.cy.rda" )
# 
# # at a later time, y can be re-accessed with the load() function
# # (just make sure the current working directory has been set to the same place)
# # load( "sipp08.cy.rda" )
# # or, if you don't set the working directory, just specify the full filepath
# # load( "C:/My Directory/sipp08.cy.rda" )
# 
# 
# ###########################################
#access the appropriate main weight data #
#run the sql query constructed above, save the resulting table in a new data frame called 
#'mw' that will now be stored in RAM
mw <- dbGetQuery( db , "select * from wgtw16" )
 
# # dump the `spanel` variable, which might otherwise sour up your merge
mw$spanel <- NULL

# # look at the first six records of mw
head( mw )

write.csv(mw, "SIPP_2008_Weights_Income.csv")

rm(x, mw, core.kv)

gc()

#####################################################################################
#labor

core.kv <- 
	c( 
	  'ssuid' , 'rfid', 'rsid', 'efnp', 'epppnum', 'spanel', 'swave','srefmon', 'rhcalmn', 
	  'rhcalyr', 'shhadid', 'eentaid', 
	  'epdjbthn', 'tbsocc1', 'absocc1', 'eeno1', 'ejbind1', 'tbsocc2', 'eeno2',
	  'ejbind2', 'eppflag', 'epopstat', 'rmesr', 'rwksperm'
	  )


# each core wave data file contains data at the person-month level.  in general, there are four records per respondent in each core wave data set.

# in order to create a file containing every individual's monthly observations throughout the calendar year,
# query each of the waves designated above, removing each record containing an rhcalyr (calendar year) matching the year designated above

########################################################################
# loop through all twelve months, merging each month onto the previous #
start.time <- Sys.time()

for ( i in 1:12 ){

	# print the current progress to the screen
	cat( "currently working on month" , i , "of 12" , "\r" )

	# create a character vector containing each of the column names,
	# with a month number at the end, so long as it's not one of the two merge variables
	numbered.core.kv <-
		# determine column names of each variable
		paste0(
			core.kv ,
			ifelse( 
				# if the column name is either of these two..
				core.kv %in% c( "ssuid" , "epppnum" ) , 
				# ..nothing gets pasted.
				"" , 
				# otherwise, a month number gets pasted
				i 
			) 
		)

		
	# create the same character vector missing 'ssuid' and 'epppnum'
	no.se.core.kv <- numbered.core.kv[ !( numbered.core.kv %in% c( 'ssuid' , 'epppnum' ) ) ]
		
		
	# create a sql string containing the select command used to pull only a defined number of columns
	# and records containing january, looking at each of the specified waves
	sql.string <- 
		# this outermost paste0 just specifies the temporary table to create
		paste0(
			"create temp table sm as " ,
			# this paste0 combines all of the strings contained inside it,
			# separating each of them by "union all" -- actively querying multiple waves at once
			paste0( 
				paste0( 
					"select " , 
					# this paste command collapses all of the old + new variable names together,
					# separating them by a comma
					paste( 
						# this paste command combines the old and new variable names, with an "as" in between
						paste(
							core.kv , 
							"as" ,
							numbered.core.kv 
						) ,
						collapse = "," 
					) , 
					" from w" 
				) , 
				waves , 
				paste0( 
					" where rhcalmn == " ,
					i ,
					" AND rhcalyr == " , 
					year 
				) , 
				collapse = " union all " 
			)
		)

	# take a look at the full query if you like..
	sql.string
	
	# run the actual command (this takes a while)
	dbSendQuery( db , sql.string )
	
	# if it's the first month..
	if ( i == 1 ){
	
		# create the single year (sy1) table from the january table..
		dbSendQuery( db , "create temp table sy1 as select * from sm" )
		
		# ..and drop the current month table.
		dbRemoveTable( db , "sm" )
	
	# otherwise..
	} else {
	
		# merge the current month onto the single year (sy#) table..
		dbSendQuery( 
			db , 
			paste0( 
				"create temp table sy" , 
				i , 
				" as select a.* , " ,
				paste0( "b." , no.se.core.kv , collapse = "," ) , 
				" from sy" ,
				i - 1 ,
				" as a left join sm as b on a.ssuid == b.ssuid AND a.epppnum == b.epppnum" 
			)
		)
		
		# ..and drop the current month table.
		dbRemoveTable( db , "sm" )
	
	}

}

# subtract the current time from the starting time,
# and print the total twelve-loop time to the screen
Sys.time() - start.time


# once the single year (sy) table has information from all twelve months, extract it from the rsqlite database
x <- dbGetQuery( db , "select * from sy12" )


# look at the first six records of x
head( x )

write.csv(x, "SIPP_2008_Core_labor.csv")

# #################################################
# # save your data frame for quick analyses later #
# 
# # in order to bypass the above steps for future analyses,
# # the data frame in its current state can be saved now
# # (or, really, anytime you like).  uncomment this line:
# # save( y , file = "sipp08.cy.rda" )
# # or, to save to another directory, specify the entire filepath
# # save( y , file = "C:/My Directory/sipp08.cy.rda" )
# 
# # at a later time, y can be re-accessed with the load() function
# # (just make sure the current working directory has been set to the same place)
# # load( "sipp08.cy.rda" )
# # or, if you don't set the working directory, just specify the full filepath
# # load( "C:/My Directory/sipp08.cy.rda" )
# 
# 
# ###########################################
#access the appropriate main weight data #
#run the sql query constructed above, save the resulting table in a new data frame called 
#'mw' that will now be stored in RAM
mw <- dbGetQuery( db , "select * from wgtw16" )
 
# # dump the `spanel` variable, which might otherwise sour up your merge
mw$spanel <- NULL

# # look at the first six records of mw
head( mw )

write.csv(mw, "SIPP_2008_Weights_labor.csv")

rm(x, mw, core.kv)

gc()

################################################################
#weights

core.kv <- 
	c( 
	  'ssuid' , 'rfid', 'rsid', 'efnp', 'epppnum', 'spanel', 'swave','srefmon', 'rhcalmn', 
	  'rhcalyr', 'shhadid', 'eentaid', 'wffinwgt', 'wsfinwgt',
	  'whfnwgt', 'wpfinwgt'
	  )


# each core wave data file contains data at the person-month level.  in general, there are four records per respondent in each core wave data set.

# in order to create a file containing every individual's monthly observations throughout the calendar year,
# query each of the waves designated above, removing each record containing an rhcalyr (calendar year) matching the year designated above

########################################################################
# loop through all twelve months, merging each month onto the previous #
start.time <- Sys.time()

for ( i in 1:12 ){

	# print the current progress to the screen
	cat( "currently working on month" , i , "of 12" , "\r" )

	# create a character vector containing each of the column names,
	# with a month number at the end, so long as it's not one of the two merge variables
	numbered.core.kv <-
		# determine column names of each variable
		paste0(
			core.kv ,
			ifelse( 
				# if the column name is either of these two..
				core.kv %in% c( "ssuid" , "epppnum" ) , 
				# ..nothing gets pasted.
				"" , 
				# otherwise, a month number gets pasted
				i 
			) 
		)

		
	# create the same character vector missing 'ssuid' and 'epppnum'
	no.se.core.kv <- numbered.core.kv[ !( numbered.core.kv %in% c( 'ssuid' , 'epppnum' ) ) ]
		
		
	# create a sql string containing the select command used to pull only a defined number of columns
	# and records containing january, looking at each of the specified waves
	sql.string <- 
		# this outermost paste0 just specifies the temporary table to create
		paste0(
			"create temp table sm as " ,
			# this paste0 combines all of the strings contained inside it,
			# separating each of them by "union all" -- actively querying multiple waves at once
			paste0( 
				paste0( 
					"select " , 
					# this paste command collapses all of the old + new variable names together,
					# separating them by a comma
					paste( 
						# this paste command combines the old and new variable names, with an "as" in between
						paste(
							core.kv , 
							"as" ,
							numbered.core.kv 
						) ,
						collapse = "," 
					) , 
					" from w" 
				) , 
				waves , 
				paste0( 
					" where rhcalmn == " ,
					i ,
					" AND rhcalyr == " , 
					year 
				) , 
				collapse = " union all " 
			)
		)

	# take a look at the full query if you like..
	sql.string
	
	# run the actual command (this takes a while)
	dbSendQuery( db , sql.string )
	
	# if it's the first month..
	if ( i == 1 ){
	
		# create the single year (sy1) table from the january table..
		dbSendQuery( db , "create temp table sy1 as select * from sm" )
		
		# ..and drop the current month table.
		dbRemoveTable( db , "sm" )
	
	# otherwise..
	} else {
	
		# merge the current month onto the single year (sy#) table..
		dbSendQuery( 
			db , 
			paste0( 
				"create temp table sy" , 
				i , 
				" as select a.* , " ,
				paste0( "b." , no.se.core.kv , collapse = "," ) , 
				" from sy" ,
				i - 1 ,
				" as a left join sm as b on a.ssuid == b.ssuid AND a.epppnum == b.epppnum" 
			)
		)
		
		# ..and drop the current month table.
		dbRemoveTable( db , "sm" )
	
	}

}

# subtract the current time from the starting time,
# and print the total twelve-loop time to the screen
Sys.time() - start.time


# once the single year (sy) table has information from all twelve months, extract it from the rsqlite database
x <- dbGetQuery( db , "select * from sy12" )


# look at the first six records of x
head( x )

write.csv(x, "SIPP_2008_Core_weights.csv")

# #################################################
# # save your data frame for quick analyses later #
# 
# # in order to bypass the above steps for future analyses,
# # the data frame in its current state can be saved now
# # (or, really, anytime you like).  uncomment this line:
# # save( y , file = "sipp08.cy.rda" )
# # or, to save to another directory, specify the entire filepath
# # save( y , file = "C:/My Directory/sipp08.cy.rda" )
# 
# # at a later time, y can be re-accessed with the load() function
# # (just make sure the current working directory has been set to the same place)
# # load( "sipp08.cy.rda" )
# # or, if you don't set the working directory, just specify the full filepath
# # load( "C:/My Directory/sipp08.cy.rda" )
# 
# 
# ###########################################
#access the appropriate main weight data #
#run the sql query constructed above, save the resulting table in a new data frame called 
#'mw' that will now be stored in RAM
mw <- dbGetQuery( db , "select * from wgtw16" )
 
# # dump the `spanel` variable, which might otherwise sour up your merge
mw$spanel <- NULL

# # look at the first six records of mw
head( mw )

write.csv(mw, "SIPP_2008_Weights_weights.csv")