#!/usr/bin/env python3

# Read the sequences from the multi-FASTA file
#input_fasta=output_fasta

from Bio import SeqIO
import numpy as np
import pandas as pd
import statistics as st
import sys
from datetime import timedelta
import os

def hypothetical_dist_value(unique_seq_fasta, country_based_fasta):
    
    unique_seq = list(SeqIO.parse(unique_seq_fasta, 'fasta'))
    country_seq = list(SeqIO.parse(country_based_fasta, 'fasta'))
     

    match_found = False  # Initialize match_found flag

    for i in range(len(country_seq)): 
        try:
            if unique_seq[0].id.split('|')[2] == country_seq[i].description.split('|')[2]:
                seq_last_matched_date = i
                #print(seq_last_matched_date)    
                match_found = True  # Set flag to True when a match is found
                break
            else:
                seq_last_matched_date = None
        except IndexError:
            pass

    if match_found:
        
        country_seq_updated = unique_seq + country_seq[seq_last_matched_date+1:]
        # Function to calculate the number of mutations between two sequences
        def calculate_mutations(seq1, seq2):
            mutations = sum(1 for a, b in zip(seq1, seq2) if a != b and a not in ['X','-'] and b not in ['X','-'])
            return mutations

        # Calculate mutations for each sequence
        for i in range(len(country_seq_updated)):
            total_mutations = 0
            total_sequences = 0

            try:
                
                for j in range(i + 1, len(country_seq_updated)):  # Start from the next sequence
                    date_i= pd.to_datetime(country_seq_updated[i].description.split("|")[2], errors='coerce').date()
                    date_j= pd.to_datetime(country_seq_updated[j].description.split("|")[2], errors='coerce').date()
                    if date_i != date_j:
                        mutations = calculate_mutations(country_seq_updated[i].seq, country_seq_updated[j].seq)
                        total_mutations += mutations
                        total_sequences += 1
                dist_value = total_mutations / total_sequences if total_sequences > 0 else 0
                break
            except IndexError:
                pass
        
        pass


        return (dist_value)  



folder_path = sys.argv[1]
unique_seq_file = sys.argv[2]

fasta_file = [os.path.join(folder_path, f) for f in os.listdir(folder_path)]
print(fasta_file)

tsv_file = os.path.basename(unique_seq_file).split('.')[0] + '.tsv' 

with open(tsv_file, 'a') as table_file:
    for i in fasta_file:
        print(os.path.basename(i).split('.')[0], '\t', str(hypothetical_dist_value(unique_seq_file, i)))  
        table_file.write(os.path.basename(i).split('.')[0] + '\t' + str(hypothetical_dist_value(unique_seq_file, i)) + '\n')

    table_file.close()      
            
         



