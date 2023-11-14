# distinctiveness_sarscov2
to check sars-cov-2 repository

#This is the code for extracting country-based information from gisaid total protein database:
grep -A 1 -E ">.*\|hCoV-19/countryname/" spikeprot1105.fasta > countryname_spike.fasta && \ 
sed '/^--$/d' countryname_spike.fasta > countryname_spike_proteinseq.fasta && \
mv countryname_spike_proteinseq.fasta countryname && \
mafft --add countryname_spike_proteinseq.fasta --keeplength --reorder 'dir'/refseq_sarscov2_spike.fasta > countryname_spike_proteinseq_aligned.fasta
