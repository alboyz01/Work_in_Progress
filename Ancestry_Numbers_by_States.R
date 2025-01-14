# Install and load necessary packages
install.packages("ipumsr")
install.packages(c("htmltools", "shiny", "DT"))
install.packages("rstudioapi")
install.packages("data.table")
library(ipumsr)
library(data.table)

# Load metadata and microdata
ddi <- read_ipums_ddi("C:/Users/gleni/Downloads/IPUMS/usa_00009.xml")
microdata <- as.data.table(read_ipums_micro(ddi))

#Viewer Interface
ipums_view(ddi)

# Create a lookup table for state FIPS codes to state names
state_names <- data.table(
  STATEFIP = c(1, 2, 4, 5, 6, 8, 9, 10, 11, 12, 13, 15, 16, 17, 18, 19, 20, 21, 22, 23, 
               24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 
               42, 44, 45, 46, 47, 48, 49, 50, 51, 53, 54, 55, 56),
  State_Name = c("Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", 
                 "Connecticut", "Delaware", "District of Columbia", "Florida", "Georgia", 
                 "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", 
                 "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", 
                 "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", 
                 "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", 
                 "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", 
                 "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", 
                 "Washington", "West Virginia", "Wisconsin", "Wyoming")
)

# Filter for Albanian ancestry
albania_ancestry <- microdata[ANCESTR1 == 100]

# Calculate total weighted population
total_weighted_pop <- sum(albania_ancestry$PERWT)

# Create summary statistics
summary_stats <- data.table(
  Sample_Count = nrow(albania_ancestry),
  Weighted_Population = total_weighted_pop
)

# Print results
print(summary_stats)

# State-level analysis with state names
state_estimates <- microdata[ANCESTR1 == 100, 
                             .(Sample_Count = .N,
                               Weighted_Population = sum(PERWT)),
                             by = STATEFIP]

# Merge state names
state_estimates <- merge(state_estimates, state_names, by = "STATEFIP", all.x = TRUE)

# Sort by weighted population
setorder(state_estimates, -Weighted_Population)

# Print state-level results with state names
print(state_estimates[, .(State_Name, Sample_Count, Weighted_Population)])
