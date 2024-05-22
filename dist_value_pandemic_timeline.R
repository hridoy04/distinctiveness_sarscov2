#Date: 2024-05-22
#comment: This script is used to plot the distinctiveness values of spike, RBD, and antigenic sites over the pandemic timeline

# Load the required libraries
library(ggplot2)
library(readxl)

# Define the function to read the excel files
dataframe_from_excel_files <- function(output_dataframe_name = NULL) {
 
   # Prompt for output_dataframe_name if not provided
  if (is.null(output_dataframe_name)) {
    output_dataframe_name <- as.character(readline(prompt = "Enter the output dataframe name: "))
  }
  
  name = as.character(substitute(output_dataframe_name)) # get the name as string of the argument
  directory_path = as.character(readline("what's the directory path? ")) # input the directory path
  file_list = paste0(directory_path, '/', list.files(path = directory_path, pattern = "*.xlsx")) # list all the files in the directory
  output_dataframe_name <- map_df(.x = file_list, .f= read_excel) # read all the excel files in the directory and put them in a single dataframe
  assign(name, output_dataframe_name, envir = .GlobalEnv) # assign the dataframe to the global environment
  return(output_dataframe_name)
}


plot %>% ggplot(aes(x=Date.x, y=dist_value, color = protein_region)) + 
  geom_jitter(size=0.5, alpha=0.3, width = 0.1, height = 0.1) + 
  ylim(0,40) + 
  labs(x= 'Pandemic Timeline', y= 'Distinctiveness Values', 
       title='Comparison of distinctivness values among spike, RBD, and Antigenic sites', 
       color='Protein Region') + 
  scale_color_manual(values = c('spike_dist_value'='cyan','rbd_dist_value'='black','antigen_dist_value'='red'),
                     labels = c("spike_dist_value"= "Spike","rbd_dist_value"='Receptor-binding region','antigen_dist_value'='Antigenic sites')) + 
  theme_minimal()