setwd("~/bbARR") # set directory 

# Household Incomes 
black_income <- "ACS_17_5YR_B19001B/ACS_17_5YR_B19001B_with_ann.csv"
black_income <- read.csv(black_income,colClasses = "character") # just read everything as character 

# identify margin of error columns 
mrgin_columns <- grep("Margin",black_income[1,])

black_income <- black_income[,-mrgin_columns]
meta_cols <- as.character(black_income[1,])  # the full estimate column names
black_income <- black_income[-1,]


under_15 <- c(5,6)
under_40 <- c(7:11)
under_75 <- c(12:15)
under_125 <- c(16:17)
over125 <- c(18:20)

sum_cols <- function(the_data){ 
  apply(the_data,MARGIN = 1,FUN = function(x){sum(as.numeric(x))})
  }

black_income[,"under15k"] <- sum_cols(black_income[,under_15])
black_income[,"15k-40k"]  <- sum_cols(black_income[,under_40])
black_income[,"40k-75k"]  <- sum_cols(black_income[,under_75]) 
black_income[,"75k-125k"]  <- sum_cols(black_income[,under_125]) 
black_income[,"125k+"]  <- sum_cols(black_income[,over125])

# fixing some extra things 

black_income$State <- gsub("Census Tract [^,]*,[^,]*, ","",black_income$GEO.display.label)
View(black_income)

# Suboptimal loop method ( > 30s )
# black_income[,"County"] <- { 
#   r = NULL
#   for(i in 1:nrow(black_income)){
#   temp. <-  substr(black_income$GEO.display.label[i], 
#                    start = gregexpr(pattern = ",",text = black_income$GEO.display.label
#                                     ,fixed = TRUE
#                    )[[1]][1]+1 , 
#                    stop = gregexpr(pattern = ",",
#                                    text = black_income$GEO.display.label[i]
#                                    ,fixed = TRUE)[[1]][2]-1) 
#     r = c(r, temp.)
#   }
#   r
#   }
  
# Optimal apply method  (< 5s)
black_income[,"County"] <- apply(X = black_income["GEO.display.label"], MARGIN = 1, FUN = function(x){ 
  substr(x,
  start = gregexpr(pattern = ",",text = x)[[1]][1]+2, 
  stop = gregexpr(pattern = ",",
                  text = x)[[1]][2]-1) 
  
  })



write_rds(black_income,"black_income.rds")

system.time({ 
a = readRDS("black_income.rds")  
  })
system.time({ 
  
a = read_rds("black_income.rds")  
  })









