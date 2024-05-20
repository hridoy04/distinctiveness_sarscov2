#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Nov 15 night 19:37:49 2023

@author: rubayetalam
"""
#packages and libraries

from Bio import SeqIO
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')

##################################


#*************** remove duplicates ******************************************

'''# Define the input and output multi-FASTA file paths
input_fasta = "ice_aligned.fasta"  # Replace with the path to your input multi-FASTA file (fas format as MEGA used)
output_fasta = "ice_final.fasta"  # Replace with the desired output file path

# Create a set to store unique sequences
unique_sequences = set()

# Create a list to store the sequences to be retained (the first occurrence of each sequence)
sequences_to_retain = []
rm 
# Iterate through the multi-FASTA file and identify duplicate sequences
for record in SeqIO.parse(input_fasta, "fasta"):
    sequence = str(record.seq)
    if sequence not in unique_sequences:
        unique_sequences.add(sequence)
        sequences_to_retain.append(record)

# Write the retained sequences to the output multi-FASTA file
with open(output_fasta, "w") as output_handle:
    SeqIO.write(sequences_to_retain, output_handle, "fasta")

print(f"Duplicate sequences removed, and the output is saved to {output_fasta}")'''
#*****************************************************************************


#***************************** delete the first ncbi refseq from alignment*************************

# Define the input multi-FASTA file and output file
input_fasta = "japan.fasta"

#********************************************************************
  # Replace with the path to your input multi-FASTA file
output_fasta = input_fasta  # Replace with the desired output file path

# Create a list to store the remaining sequences
remaining_sequences = []

# Read the sequences from the input multi-FASTA file, skipping the first sequence
skip_first = True
for record in SeqIO.parse(input_fasta, "fasta"):
    if skip_first:
        skip_first = False
        continue
    remaining_sequences.append(record)

# Write the remaining sequences to the output multi-FASTA file
with open(output_fasta, "w") as output_handle:
    SeqIO.write(remaining_sequences, output_handle, "fasta")

print(f"First sequence removed, and remaining sequences saved to {output_fasta}")


#reorder the sequence and sorted according to the date***************


# Define the input and output FASTA files
input_fasta = output_fasta # Replace with the path to your input FASTA file; #change here

# Function to extract the date from the FASTA header
def extract_date(header):
    parts = header.split("|")
    if len(parts) >= 2:
        return parts[2]
    return ""

# Read the sequences and extract the date information
sequences = list(SeqIO.parse(input_fasta, "fasta"))
sequences_with_dates = [(record, extract_date(record.description)) for record in sequences]

# Sort the sequences based on the extracted date (important line*******)
sequences_with_dates.sort(key=lambda x: x[1], reverse = True)

output_fasta=input_fasta

# Write the sorted sequences to the output FASTA file
with open(output_fasta, "w") as output_handle:
    for record, date in sequences_with_dates:
        SeqIO.write(record, output_handle, "fasta")

print(f"FASTA file sorted and saved to {output_fasta}")

#**********************************************************************



#==============================================average mutation count======================

# Read the sequences from the multi-FASTA file

input_fasta=output_fasta
sequences = list(SeqIO.parse(input_fasta, "fasta"))

# Function to calculate the number of mutations between two sequences
def calculate_mutations(seq1, seq2):
    mutations = sum(1 for a, b in zip(seq1, seq2) if a != b and a not in ['X','-'] and b not in ['X','-'])
    return mutations

# Create a DataFrame to store mutation counts and averages
result_data = {
    "Sequence": [],
    "Date": [],
    "Total Mutations": [],
    "Average Mutations": []
}

count=0
# Calculate mutations for each sequence
for i in range(len(sequences)):
    total_mutations = 0
    total_sequences = 0
    
    for j in range(i + 1, len(sequences)):  # Start from the next sequence
        date_i= pd.to_datetime(sequences[i].description.split("|")[2], errors='coerce').date()
        date_j= pd.to_datetime(sequences[j].description.split("|")[2], errors='coerce').date()
        if date_i != date_j:
            mutations = calculate_mutations(sequences[i].seq, sequences[j].seq)
            total_mutations += mutations
            total_sequences += 1

    # Calculate the average mutations
    average_mutations = total_mutations / total_sequences if total_sequences > 0 else 0

    # Store the results in the DataFrame
    result_data["Sequence"].append(sequences[i].description)
    result_data["Date"].append(sequences[i].description.split("|")[2])
    result_data["Total Mutations"].append(total_mutations)
    result_data["Average Mutations"].append(average_mutations)

#code_check_part:
    count=count+1
    print(count)
    
    
# Create a DataFrame
mutation_df = pd.DataFrame(result_data)
# Save the mutation counts and averages to an output Excel file
excel_file = "japan_mutations.xlsx"  #change here
mutation_df.to_excel(excel_file, index=False)

#print(f"Mutation counts and averages saved to {excel_file}")

#==============================================================================================

#$$$$$$$$$$$$$$$$$$$$ Sort date based values and grouping for max value at specified date $$$$$$$$$$$$$$$$$


# Load the Excel file into a pandas DataFrame
#excel_file = "Bangladesh/distinctiveness_BD_check.xlsx"  # Replace with your Excel file path

df = pd.read_excel(excel_file)

# Convert the "Date" column to datetime if it's not already
df['Date'] = pd.to_datetime(df['Date'], errors='coerce')
df = df.sort_values(by='Date', ascending = False)

# Group the DataFrame by the "Date" column and find the maximum "Value" for each date
result = df.groupby('Date')['Average Mutations'].max().reset_index()

result = result.sort_values(by='Date', ascending = False)

# Print or save the result to a new Excel file
#print(result)

# To save the result to a new Excel file:
result.to_excel(excel_file, index=False) #change here
#print ("BD selective values for representative dates in excel") #change here


#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
# Load your data into a pandas DataFrame
# Replace 'data.csv' with the path to your data file
#excel_file = "Bangladesh/highest_values_BD_new.xlsx"  # Replace with your Excel file path

df = pd.read_excel(excel_file) #change here

# Sort the data by date (if it's not already sorted)
df['Date'] = pd.to_datetime(df['Date'], errors='coerce')  # Convert the 'Date' column to datetime
#df = df.sort_values(by='Date', ascending = True)

#df=df[::-1]

#specific date highlights
highlight_dates = ["2020-03-26"]

# Create a dot plot
plt.figure(figsize=(12, 6))  # Adjust the figure size as needed

plt.scatter(df['Date'], df['Average Mutations'], s=10, alpha=0.5, color='b', label='Data Points')

#highlight specific dates for variant determination
highlight_data = df[df['Date'].isin(pd.to_datetime(highlight_dates))]
plt.scatter(highlight_data['Date'], highlight_data['Average Mutations'], s=50, color='r', marker='o', label='Highlight')

# Customize the plot (add labels, title, etc.)
plt.xlabel('Date')
plt.ylabel('Average Mutations')
plt.title('Dot Plot for c: Date vs. Average Mutations')

# Optionally, add grid lines
plt.grid(True, linestyle='--', alpha=0.6)

# Show or save the plot to an image file
plt.xticks(rotation=45)  # Rotate the x-axis labels for better readability
plt.legend(loc='best')  # Display the legend

plt.tight_layout()  # Adjust layout for better spacing
plt.show()
#print ("plot made for c")
plt.savefig("philipines_plot.jpeg") #change here
# To save the plot as an image file, use plt.savefig("dot_plot.png")'''
 


