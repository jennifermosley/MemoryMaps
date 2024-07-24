# Load necessary library
# install.packages("dplyr")
library(dplyr)
library(readxl)
library(data.table)


### Functions ###
# Define a function to write onset files for each subject
generate_onset_files <- function(data, output_dir) {
  # Ensure the output directory exists
  if (!dir.exists(output_dir)) {
    dir.create(output_dir)
  }
}
# Remove extra, empty columns at the end of the dataframe
# Function to check if a column is all NA
is_all_na <- function(column) {
  all(is.na(column))
}
### Functions ###

data <- read.csv("centralityDf.csv") # Import fullData dataset
data <- data[ ,-1] # Remove the first column
data$subID <- as.factor(data$subID) # Set subject IDs to a factor

# We need the following information for onset files:
# 1) Onsets relative to start of scan
# 2) Duration of trial (13s - based on subjects' recall duration in task output)
# 3) Trial condition
#   a) H-v-L-outdegree_run# // -indegree_run#
#   b) In-v-Out_run# **
#   c) H-v-L_degree_run# **

# Import imaging event output files as individual subject data frames 
subs <- as.numeric(levels(data$subID))
subs <- subs[-34] # Removed since it is not currently included in centrality df
# sub22 - Need to figure out modeling missing trial 8

# Subject loop for importing and cleaning subject dataframe
for (s in subs){
  # Set the filename pattern (#_MemMaps.csv)
  filename <- paste0(s,"_MemMaps.csv")
  
  # Create the full file path by combining the directory and filename
  path <- paste0("~/GitLab/SecondYearProject/MemoryMaps/Data/raw/imaging_output/",s)
  filepath <- file.path(path, filename)
  
  # Create the working dataframe for the current subject
  # NOTE: If you get an error when trying to import these files, open the file 
  # in excel and save as comma delimited file (UTF-8)
  
  df <- read.csv(filepath, sep=',')
  
  # Identify the columns after the specified column number that are all NA
  start_col <- 30
  cols_to_check <- start_col:ncol(df)
  na_cols <- which(sapply(df[, cols_to_check], is_all_na)) + (start_col - 1)
  
  # Remove the columns that are all NA after the specified column number
  if (length(na_cols) > 0) {
    df <- df[, -na_cols]
  }
  
  # Identify rows with "subID" in subID column
  inds <- grep("subID",df$subID)
  # Remove unnecessary subID rows from df
  df <- df[-inds, ]
  
  # Identify rows with "NaN" in run column
  inds <- grep("NaN",df$run)
  # Remove unecessary NaN rows from df
  df <- df[-inds, ]
  
  # Identify rows that are duplicates
  duplicates <- duplicated(df$iti1, df$q)
  # Remove duplicates
  df <- df[!duplicates, ]
  
  # Now we should have 24 rows, 8 rows for each run and 1 row corresponding to
  # each memory recalled.
  
  newname <- paste0("sub",s)
  assign(newname,df)
}

# Set onset, condition, and duration variables before adding to onset text file

runs = 1:3

# For each subject dataframe, set onset, condition, and duration
for (s in subs){
  
  # For the manipulations we will do, we need subID of Data to not 
  # be factorized but numeric
  data$subID <- as.numeric(data$subID)
  
  for (r in runs) {
    
    if (r == 1){
      onsetPattern <- paste0("onsetMatrix1_")
      trials = 1:8
    }
    if (r == 2){
      onsetPattern <- paste0("onsetMatrix2_")
      trials = 9:16
    }
    if (r == 3){
      onsetPattern <- paste0("onsetMatrix3_")
      trials = 17:24
    }
    
    ## Set duration ##
    duration <- 13.0299
    durationVec <- rep(duration,times=8)
    durationVec <- as.data.frame(durationVec)
    
    ## Set Onset (using onset matrices)
    
    # Set the filename pattern (onsetMatrix1_#_MemMaps.csv)
    filename <- paste0(onsetPattern,s,"_MemMaps.xlsx")
    
    # Create the full file path by combining the directory and filename
    path <- paste0("~/GitLab/SecondYearProject/MemoryMaps/Data/raw/imaging_output/",s)
    filepath <- file.path(path, filename)
    
    #Import subject's onset matrix current r
    onsets <- read_excel(filepath)
    
    # Create a vector for the onsets column, subsetting recall onsets from 
    # event/timing output
    onsetsDf <- onsets[ ,2]
    colnames(onsetsDf) <- c("onsets")
    
    ## End of onsets definition
    
    ## Set trial conditions
    # For centrality, high-v-low indegree/outdegree; high-low degree; outdegree>indegree
    
    # Subset current subject data from centrality dataframe
    subDf <- filter(data, subID == s)
    
    # Import centrality data to onsetsVec
    conditionsDf <- select(subDf, c(high_outdegree, low_outdegree))
    conditionsDf <- as.data.frame(conditionsDf)
    
    cent1 <- data.frame(A=NA, B=NA)
    colnames(cent1) <- c("high_outdegree","low_outdegree")
    
    for (t in trials) {
      # Subset conditions based on run
      condition <- conditionsDf %>% slice(t)
      cent1 <- rbind(cent1,condition)
    }
    
    # Remove first row created in df construction
    cent1 <- cent1[-1, ]
    
    ## End of trial conditions
    
    # Create events dataframe which will be exported
    events <- mutate(onsetsDf,cent1,durationVec)
    
    # Label events file with current run
    eventFilename <- paste0("hi-v-lo_outdegree_run",r,".txt")
    
    path <- paste0("~/GitLab/SecondYearProject/MemoryMaps/Data/processed/event_timings/",s)
    dir.create(path = path)
    newPath <- paste0("~/GitLab/SecondYearProject/MemoryMaps/Data/processed/event_timings/",s,"/")
    write.table(events, paste0(newPath,eventFilename))
    
  } # End of run subprocess
  
