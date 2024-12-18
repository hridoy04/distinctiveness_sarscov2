# Date: 2024-05-22
# Comment: This script is used to plot the distinctiveness values of spike, RBD, and antigenic sites over the pandemic timeline

# Load the required libraries
library(ggplot2)    # For creating visualizations
library(readxl)     # For reading Excel files
library(tidyverse)  # For data manipulation and visualization

# Define a function to read all Excel files from a given directory into a single dataframe
dataframe_from_excel_files <- function(output_dataframe_name = NULL) {
  
  # If the output dataframe name is not provided, prompt the user to enter one
  if (is.null(output_dataframe_name)) {
    output_dataframe_name <- as.character(readline(prompt = "Enter the output dataframe name: "))
  }
  
  # Capture the argument name as a string (for later assignment in the global environment)
  name = as.character(substitute(output_dataframe_name))
  
  # Prompt the user to input the directory path where the Excel files are stored
  directory_path = as.character(readline("What's the directory path? ")) 
  
  # Get a list of all Excel files in the directory with ".xlsx" extension
  file_list = paste0(directory_path, '/', list.files(path = directory_path, pattern = "*.xlsx"))
  
  # Read all Excel files and combine them into one dataframe using map_df
  output_dataframe_name <- map_df(.x = file_list, .f = read_excel)
  
  # Assign the created dataframe to the global environment with the specified name
  assign(name, output_dataframe_name, envir = .GlobalEnv)
  
  return(output_dataframe_name)  # Return the combined dataframe
}

# Rename the 'Distinctiveness_value_mean' column in each dataset for clarity
antigen <- antigen %>% rename(dist_value_antigen = Distinctiveness_value_mean)
rbd <- rbd %>% rename(dist_value_rbd = Distinctiveness_value_mean)
spike <- final_dist_combined_all %>% rename(dist_value_spike = Distinctiveness_value)

# Merge the antigen, rbd, and spike dataframes based on the 'Sequence_ID' column
list(antigen, rbd, spike) %>% 
  reduce(full_join, by = 'Sequence_ID') -> merged_dist_value

# Select and rename relevant columns
merged_dist_value %>% 
  select(Sequence_ID, Date.x, dist_value_antigen, dist_value_rbd, dist_value_spike) %>% 
  rename(Dates = Date.x) -> merged_dist_value

# Convert the 'Dates' column from character to Date format and clean up the dataframe
merged_dist_value$Date <- as.Date(merged_dist_value$Dates)  # Convert to Date type
merged_dist_value %>% 
  select(-Dates) -> merged_dist_value  # Drop the redundant 'Dates' column

# Categorize the regions (spike, RBD, antigenic sites) based on distinctiveness values
merged_dist_value %>% 
  mutate(spike_region = case_when(
    spike_region == 'dist_value_antigen' ~ 'antigenic sites',
    spike_region == 'dist_value_rbd' ~ 'receptor-binding region',
    spike_region == 'dist_value_spike' ~ 'complete spike')) -> merged_dist_value

# Filter the data to remove any invalid or extreme values and keep only relevant dates and values
merged_dist_value %>% 
  filter(!(spike_region == "antigenic sites" & dist_values > 10)) %>%  # Filter out extreme antigenic site values
  filter(Date >= '2019-12-01' & dist_values < 50) %>%  # Filter for relevant date range and reasonable distinctiveness values
  
  # Create a jitter plot to visualize the distinctiveness values over the pandemic timeline
  ggplot(aes(x = Date, y = dist_values)) + 
  geom_jitter(size = 0.5, alpha = 0.3, width = 0.1, height = 0.1) +  # Add jitter for better point visibility
  
  # Labeling and titles
  labs(x = 'Pandemic Timeline', 
       y = 'Distinctiveness Values', 
       title = 'Comparison of distinctiveness values among \n spike, receptor-binding region, and antigenic sites') + 
  
  # Facet plot to separate visualizations by spike region with free y-scales
  facet_wrap(~factor(spike_region, 
                     levels = c('antigenic sites', 'receptor-binding region', 'complete spike')), 
             nrow = 1, ncol = 3, strip.position = 'top', scales = 'free_y') +
  
  # Allow y-axis limits to adjust dynamically
  scale_y_continuous(limits = function(y) c(min(y), max(y))) +
  
  # Customizing the theme for clarity and aesthetics
  theme_minimal() +
  theme(axis.text.x = element_text(size = 14, angle = 45, vjust = 1, hjust = 1),  # Rotate x-axis labels for readability
        axis.title.x = element_text(size = 18, face = 'bold', vjust = 0),  # Style x-axis title
        axis.title.y = element_text(size = 18, face = 'bold'),  # Style y-axis title
        axis.text.y = element_text(size = 16),  # Style y-axis labels
        strip.text = element_text(size = 14, face = 'bold'),  # Style facet labels
        plot.title = element_text(size = 18, face = 'bold', hjust = 0.5),  # Style plot title
        legend.position = 'none')  # Hide the legend

# Output the processed dataframe
merged_dist_value
