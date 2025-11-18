# distinctiveness_sarscov2

Tools for estimating SARS-CoV-2 spike protein distinctiveness values, summarizing
country-specific FASTA collections, and visualizing the resulting statistics.

## Repository layout

| File | Purpose |
| --- | --- |
| `distinctiveness_analysis_protein_final.py` | Removes duplicates, sorts sequences by date, and calculates per-sequence mutation counts/averages from a country-level aligned FASTA file. |
| `hypothetical_distinctiveness_value_unique_variant.py` | Projects the distinctiveness trajectory of a unique sequence against per-country FASTA collections. |
| `dist_value_pandemic_timeline.R` | Creates a jitter plot comparing spike, RBD, and antigenic-site distinctiveness values over time. |
| `scatterplot_pandemic-timeline_v1.R` | Extended version of the timeline visualization with tidyverse helpers and faceted output. |
| `Prevalence-based_Violin-plot_v1.R` | Builds violin plots that relate distinctiveness values to variant prevalence categories. |
| `correlation_analysis.R` | Explores correlations between distinctiveness and relative prevalence deltas. |

All R scripts expect data frames already loaded in the current R session (see
per-script instructions below) and use tidyverse-style operations. The Python
scripts assume Biopython, pandas, and matplotlib are available.

## Country-level spike extraction

Use the following shell pipeline to pull spike sequences for a single country
from GISAID data (replace `countryname` and the reference path with the desired
values):

```bash
grep -A 1 -E ">.*\|hCoV-19/countryname/" spikeprot1105.fasta > countryname_spike.fasta && \
  sed '/^--$/d' countryname_spike.fasta > countryname_spike_proteinseq.fasta && \
  mv countryname_spike_proteinseq.fasta countryname && \
  mafft --add countryname_spike_proteinseq.fasta --keeplength --reorder "<ref_dir>/refseq_sarscov2_spike.fasta" \
    > countryname_spike_proteinseq_aligned.fasta
```

The aligned FASTA file generated above becomes the input for the downstream
Python analysis scripts.

## Script-by-script usage

### `distinctiveness_analysis_protein_final.py`

1. Update the `input_fasta` variable to point to your aligned FASTA file (one
   country per file). The script overwrites the same file after removing the
   first (reference) sequence and reordering entries by collection date.
2. Optionally uncomment the duplicate-removal block if you need to deduplicate
   sequences before analysis.
3. Run the script:

   ```bash
   python distinctiveness_analysis_protein_final.py
   ```

4. The script saves `japan_mutations.xlsx` (rename `excel_file` as needed)
   containing per-sequence mutation totals and averages relative to later-dated
   samples.

Dependencies: Biopython, pandas, matplotlib (configured to use the non-GUI
`Agg` backend).

### `hypothetical_distinctiveness_value_unique_variant.py`

This script estimates the distinctiveness value a unique sequence would have had
if it appeared in each country's timeline.

```bash
python hypothetical_distinctiveness_value_unique_variant.py <country_fasta_dir> <unique_sequence.fasta>
```

* `<country_fasta_dir>` – directory containing per-country aligned FASTA files.
* `<unique_sequence.fasta>` – FASTA file with the unique sequence of interest
  (only the first record is used).

The script writes `<unique_sequence>.tsv`, listing the distinctiveness value it
would attain in each country file.

Dependencies: Biopython, NumPy, pandas.

### `dist_value_pandemic_timeline.R`

Generates a jitter plot comparing distinctiveness distributions from spike,
RBD, and antigenic sites:

1. Load `ggplot2`, `readxl`, and `purrr`/`dplyr` (via tidyverse) if you plan to
   use the helper function.
2. Use `dataframe_from_excel_files("plot")` to read all `.xlsx` files in a
   directory into a single tibble named `plot`. The files must include columns
   `Date.x`, `dist_value`, and `protein_region`.
3. Run the plotting block at the bottom of the script to render the figure.

### `scatterplot_pandemic-timeline_v1.R`

An extended version of the previous visualization that joins antigenic, RBD, and
spike distinctiveness tables:

1. Load `ggplot2`, `readxl`, and `tidyverse`.
2. Ensure the objects `antigen`, `rbd`, and `final_dist_combined_all` are loaded
   (for example, by calling `dataframe_from_excel_files()` per dataset).
3. Source the script or run it line by line to create the combined dataframe and
   render the faceted jitter plot.

### `Prevalence-based_Violin-plot_v1.R`

Produces violin plots showing how distinctiveness values distribute across
prevalence trend categories:

1. Load `ggplot2`, `dplyr`, and `tidyverse`.
2. Prepare a dataframe `df` containing `Sequence_ID`, `Lineage`, `country`,
   `Distinctiveness_value`, and prevalence columns such as `prev42_28`.
3. Optionally define vectors like `country_high_seq_rate` for filtering.
4. Run the script to create the violin plots and (optionally) export Tukey HSD
   comparison tables.

### `correlation_analysis.R`

Explores Pearson correlations between normalized distinctiveness values and
relative prevalence deltas:

1. Load `tidyverse` and `ggpubr`.
2. Provide a dataframe `final` that includes prevalence counts (`prevalence_14days`,
   etc.) and `normalized_dist_value`.
3. Execute the script to create a scatter plot with regression line and compute
   correlations.

## Testing

Because the scripts depend on user-provided FASTA/Excel inputs, no automated
unit tests are bundled with the repository. Validate each workflow using the
provided instructions and your local datasets.
