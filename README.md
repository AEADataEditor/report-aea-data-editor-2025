# 2025 Report by the Data Editor

> This deposit was made late, because just before publication, a hard-drive failure lead to the loss of the ready-to-publish files. A warning note to keep copies of all data in redundant locations.

## Overview

The code in this replication package constructs analysis files from four data sources (JIRA process data, openICPSR deposit data, ScholarOne processing-time data, and Zenodo metadata) using R and Python, and generates all tables and figures in the paper. Most intermediate derived files are provided, so the majority of table-generating programs can be run directly without re-running the data-preparation steps.

## Data Availability and Provenance Statements

Raw data come from the JIRA system used by the AEA Data Editor and cannot be made available outside of the organization, as it contains names of replicators, manuscript numbers, and verbatim email correspondence. Anonymized data is publicly available at Vilhuber (2025).

### Statement about Rights

- [X] I certify that the author(s) of the manuscript have legitimate access to and permission to use the data used in this manuscript.
- [X] I certify that the author(s) of the manuscript have documented permission to redistribute/publish the data contained within this replication package. Appropriate permissions are documented in the ``LICENSE.txt`` file.

### Summary of Availability

- [ ] All data **are** publicly available.
- [X] Some data **cannot be made** publicly available.
- [ ] **No data can be made** publicly available.

### Dataset list

| Data file | Source | Notes | Provided |
| --------- | ------ | ----- | -------- |
| `data/jira/anon/jira.anon.RDS` | Vilhuber (2025) | Anonymized JIRA process data | Yes |
| `data/jira/anon/jira_access_cleaned.RDS` | Vilhuber (2025) | Anonymized JIRA access-category data | Yes |
| `data/jira/raw/jira-search-external.xlsx` | JIRA system | Confidential raw JIRA extract | No |
| `data/jira/raw/jira-search-nda.xlsx` | JIRA system | Confidential raw JIRA extract | No |
| `data/jira/raw/jira-search-non-compliant.xlsx` | JIRA system | Confidential raw JIRA extract | No |
| `data/jira/raw/jira-search-updates.xlsx` | JIRA system | Confidential raw JIRA extract | No |
| `data/confidential/icpsr/utilizationReport-2025-12-08.csv` | ICPSR (2025a) | Confidential raw utilization report | No |
| `data/confidential/icpsr/AEA_Report_20251205_edited.csv` | ICPSR (2025b) | Confidential deposit-size report | No |
| `data/icpsr/anonUtilizationReport.Rds` | ICPSR (2025a) | Processed utilization data | Yes |
| `data/icpsr/anonUtilizationReport.csv` | ICPSR (2025a) | Processed utilization data (CSV) | Yes |
| `data/icpsr/icpsr.file.size.Rds` | ICPSR (2025b) | Processed deposit-size data | Yes |
| `data/icpsr/icpsr.stats.mb.Rds` | ICPSR (2025b) | Deposit-size summary (MB) | Yes |
| `data/icpsr/icpsr.stats.gb.Rds` | ICPSR (2025b) | Deposit-size summary (GB) | Yes |
| `data/scholarone/dataEditorReport_20241111-20251110.xlsx` | AEA (2025) | Processing-time summary from ScholarOne | Yes |
| `data/zenodo/zenodo_data_2025.csv` | Zenodo (2025) | Per-deposit metadata for AEA Zenodo community | Yes |
| `data/zenodo/zenodo_data_2025_summary.csv` | Zenodo (2025) | Summary statistics from Zenodo API | Yes |

### Preservation of confidential data

All confidential files used by the programs in this package but not included in it (marked "No" in the table above) are preserved by the author in a secure internal archive, together with the code and outputs, and will be kept for at least five years after publication of the report.

### Details on each Data Source

#### Data for pre-production verification (Vilhuber, 2025)

Anonymized files from the internal production system are provided in this repository, sourced from Vilhuber (2025).

```
data/jira/anon/jira.anon.RDS
data/jira/anon/jira_access_cleaned.RDS
data/jira/anon/README.Rmd
```

The main anonymized JIRA process file (`jira.anon.RDS`) is the version published at commit `91a673f` of the GitHub repository associated with Vilhuber (2025). If it is not present, `programs/03_jira_dataprep.R` downloads it from that repository; in either case, its checksum is verified against the value in `programs/config.R`.

Several non-anonymous files are also used, and not provided.

```
data/jira/raw/jira-search-external.xlsx
data/jira/raw/jira-search-nda.xlsx
data/jira/raw/jira-search-non-compliant.xlsx
data/jira/raw/jira-search-updates.xlsx
```

These files are used only in the public-deposit version of the compliance program and are not referenced by any program in this repository.

#### openICPSR data on deposits (ICPSR, 2025a)

The data are obtained on demand from the internal systems underlying the AEA Data and Code Repository. The internal systems are accessible only to ICPSR staff, and were provided to the AEA Data Editor upon request. They are not accessible to others. The data were lightly hand-edited to account for formatting errors (double double-quotes and other issues related to the conversion from internal database representation to CSV).

For those with access to the system:

> Go to https://www.openicpsr.org/openicpsr/tenant/openicpsr/module/aea/reports and download the CSV file. Save it with a date-stamp added.

Data were extracted on all published replication packages. The raw data are not provided.

```
data/confidential/icpsr/utilizationReport-2025-12-08.csv
```

The clean data files are provided in the folder `data/icpsr`. For additional use of the data, see the processing code.

```
data/icpsr/anonUtilizationReport.Rds
data/icpsr/anonUtilizationReport.csv
```

#### openICPSR data on deposit sizes (ICPSR, 2025b)

These data are provided by ICPSR staff upon request. They are usually not accessible to others, but could be scraped. Only aggregated statistics are computed from these files. Data file is not provided, as it contains information on unpublished deposits. The file was lightly hand-edited (removal of embedded double quotes, minor edits to titles) so that it imports cleanly; no numeric values were changed.

```
data/confidential/icpsr/AEA_Report_20251205_edited.csv
```

#### Data on processing time (AEA, 2025)

The data on processing times were extracted from the ScholarOne manuscript management system used by the AEA. Microdata are not available (even to the author), only summary statistics are provided as Excel sheets. These were simply reformatted for the report.

```
data/scholarone/dataEditorReport_20241111-20251110.xlsx
```

#### Zenodo data (Zenodo, 2025)

Data on AEA-related deposits in Zenodo are obtained through a call to the Zenodo API (see `01_zenodo_pull.py`) for the `aeajournals` community. Because data accessed via the API change over time, the data are provided in this repository. The script pulls both microdata (per deposit, `zenodo_data_YEAR.csv`) and computes summary statistics (`zenodo_data_YEAR_summary.csv`).

```
data/zenodo/zenodo_data_2025.csv
data/zenodo/zenodo_data_2025_summary.csv
```

## Locations

The repository at [https://github.com/AEADataEditor/report-aea-data-editor-2025](https://github.com/AEADataEditor/report-aea-data-editor-2025) contains code, data, and output from running the code.

The deposit at [https://doi.org/10.3886/E247436V1](https://doi.org/10.3886/E247436V1) contains code and data, as well as output.

## Citing the report

> Vilhuber, Lars. 2026. "Report of the AEA Data Editor." AEA Papers and Proceedings 116: 890–904. DOI: [10.1257/pandp.116.890](https://doi.org/10.1257/pandp.116.890)

```
@article{ReportDE2026,
Author = {Vilhuber, Lars},
Title = {Report of the {AEA} Data Editor},
Journal = {AEA Papers and Proceedings},
Volume = {116},
Year = {2026},
Month = {May},
Pages = {890--904},
DOI = {10.1257/pandp.116.890},
URL = {https://doi.org/10.1257/pandp.116.890}}
```

## Citing the code and data

> Vilhuber, Lars. 2026. "Code and Data for: Report of the AEA Data Editor for 2025."  American Economic Association [publisher], Inter-university Consortium for Political and Social Research [distributor]. [https://doi.org/10.3886/E247436V1](https://doi.org/10.3886/E247436V1)

## Computational requirements

### Software Requirements

The code was run with the following software versions, though others are likely to also work:

- last run with [Docker image `aeadataeditor/report-aea-data-editor-2025:2025-12-02`](https://hub.docker.com/r/aeadataeditor/report-aea-data-editor-2025/tags) built from [`rocker/verse:4.5.1`](https://hub.docker.com/r/rocker/verse/tags)
- Docker version 28.5.1-ce, build f8215cc26


- R 4.5.1
  - Package versions set to as-of **2023-11-01**, using the Rstudio Package Manager, except for Github installed versions
  - dplyr
  - here
  - tidyr
  - tibble
  - stringr
  - readr
  - splitstackshape
  - digest
  - remotes
  - readxl
  - writexl
  - ggplot2
  - ggthemes
  - janitor
  - dataverse
  - xtable
  - github("markwestcott34/stargazer-booktabs") (overrides standard stargazer!)
- Python 3.10.12
  - requests==2.31.0
  - requests-oauthlib==1.3.1
  - requests-toolbelt==1.0.0

Packages are installed by `global-libraries.R` or defined in `requirements.txt`, and are sourced in the Dockerfile. For manual installation, the following may work (not tested). It is strongly suggested to use environments if not using the container (see below).

- if running on Linux, adjust the `repos` line in `global-libraries.R` to correspond to your Linux distribution.
- if running on Windows or macOS, or running an unsupported-version of Linux, choose the line above that (currently commented out). For more details, see [https://packagemanager.posit.co/client/#/repos/cran/setup](https://packagemanager.posit.co/client/#/repos/cran/setup).

```
R CMD BATCH global-libraries.R
pip install -r requirements.txt
```

#### Building the container (optional)

A container was built, using the following files in this deposit:

```
build/Dockerfile
global-libraries.R
requirements.txt
build/build.sh
.myconfig.sh
```

### Controlled Randomness

- [X] No pseudo-random number generator is used in the analysis described here.

### Memory, Runtime, Storage Requirements

#### Summary time to reproduce

Approximate time needed to reproduce the analyses on a standard (2025) desktop machine:

- [X] <10 minutes
- [ ] 10-60 minutes
- [ ] 1-2 hours
- [ ] 2-8 hours
- [ ] 8-24 hours
- [ ] 1-3 days
- [ ] 3-14 days
- [ ] > 14 days

#### Summary of required storage space

Approximate storage space needed:

- [X] < 25 MBytes
- [ ] 25 MB - 250 MB
- [ ] 250 MB - 2 GB
- [ ] 2 GB - 25 GB
- [ ] 25 GB - 250 GB
- [ ] > 250 GB

#### Hardware Requirements

Code was last run on the following environment:

- OS: "openSUSE Leap 15.6"
- Processor:  AMD Ryzen 9 3900X 12-Core Processor, 24 cores
- Memory available: 125GB memory

Memory requirements are minimal, and the code should run on any modern computer.

## Programs

All programs, except those processing the Registry data, are in the `programs` subdirectory:

```
programs/01_zenodo_pull.py
programs/02_lab_members.R
programs/03_jira_dataprep.R
programs/04_prepare_icpsr.R
programs/05_prepare_icpsr2.R
programs/06_prepare_access_categories.R
programs/11_table1_stats.R
programs/12_table2_stats.R
programs/13_table3.R
programs/14_table4_webstats.R
programs/15_table5_compliance_updates.R
programs/16_table_access_categories.R
programs/21_figure1_filesize.R
programs/99_write_nums.R
programs/config.R
programs/run_all.sh
```

### Auxiliary code

The following code is used to manage the repository and not necessary to reproduce the statistical results:

```
.myconfig.sh
build/build.sh
ls-tags.sh
prepare_deposit.sh
run.sh
make_readme_pdf.sh
send_paper.sh
start_rstudio.sh
```

### Instructions to Replicators

The provided code reproduces:

- [ ] All numbers provided in text in the paper
- [X] All tables and figures in the paper
- [ ] Selected tables and figures in the paper, as explained and justified below.

To reproduce all results:

1. Obtain access to the confidential data files (see Data section above) and place them in:
   - `data/confidential/icpsr/utilizationReport-2025-12-08.csv`
   - `data/confidential/icpsr/AEA_Report_20251205_edited.csv`
2. Install software dependencies (see Software Requirements above), or start the Docker container.
3. Run programs in numerical order. The script `run_all.sh` automates this from within the `programs` directory.

To reproduce only the tables and figures (skipping confidential data preparation):

- Skip programs `04_prepare_icpsr.R` and `05_prepare_icpsr2.R` (these require confidential ICPSR data; derived outputs are already provided).
- Run all remaining programs in numerical order starting from `01_zenodo_pull.py`.

NOTE: `jira.anon.RDS` is provided. Should it be missing, `03_jira_dataprep.R` downloads it automatically from the public GitHub repository (an internet connection is then required).

NOTE: The Python file `01_zenodo_pull.py` can be run as `python3 01_zenodo_pull.py`. Running this code again overwrites the provided Zenodo metadata, and **will** generate (slightly) different results. To obtain the same results, do not run this part of the code.

NOTE: The Python code may require the installation of `apt install python3.12-venv` within the container, and then running `python3 -m venv pyenv` and `source pyenv/bin/activate` before running the Python code, even in the current container.

### Running code

#### Using the container

> NOTE: this was the only way the code was run by the authors.

- The container can be started to serve RStudio, or to run from the shell. This has not been tested in a Windows/Docker environment nor on ARM Macs.
- If using Rstudio, all code was run from the embedded terminal, not the R console.
- Convenience bash scripts are provided for both options:  `start_rstudio.sh` (for RStudio) or `run.sh` (to simply produce all figures and tables not related to the registry).
- These scripts are known to work on multiple Linux workstations, and on Intel Macs.
- Alternatively, from a terminal, run Docker as follows to obtain a terminal with R, Python, and all configured packages:

```
WORKSPACE=$(pwd)
space=aeadataeditor
repo=report-aea-data-editor-2025
tag=2025-12-02
docker run -it  -v "$WORKSPACE/":/home/rstudio -w /home/rstudio --rm --entrypoint /bin/bash $space/$repo:$tag
```

- once at the shell, type

```bash
cd programs
bash -x ./run_all.sh
```

All results in the report were created by running the R and Python code within the container. Running in other environments is untested.

### Mapping tables and figures to article

Table and figure numbers in the paper do not map to program names, due to editorial decisions. The table below maps files, figures/tables, and the programs used to generate them. Some tables contain minor manual formatting edits, indicated by the suffix `_mod`. No numbers were edited.

| Name of file | Figure/Table in article | Program to create | Requires conf. data |
| ------------ | ----------------------- | ----------------- | ------------------- |
| `jira_response_options.tex` | Table 2 | `11_table1_stats.R` | No |
| `n_journal_numbers_mod.tex` | Table 3 | `12_table2_stats.R` | No |
| `n_rounds.tex` | Table 4 | `13_table3.R` | No |
| `table_access_provision_mod.tex` | Table 5 | `16_table_access_categories.R` | No |
| `n_ndas_manuscript_mod.tex` | Table 6 | `15_table5_compliance_updates.R` | No |
| `n_webstats.tex` | Table 7 | `14_table4_webstats.R` | No |
| `plot_filesize_dist.png` | Figure 1 | `21_figure1_filesize.R` | No |
| `n_updates_manuscript_mod.tex` | Table 8 | `15_table5_compliance_updates.R` | No |

In-text numbers are collected throughout all programs, and written out in `programs/99_write_nums.R` to `tables/latexnums.tex`.

## License

See [LICENSE.txt](LICENSE.txt) for data and code license.

## References

- American Economic Association. 2025. "Aggregated processing times by journal from ScholarOne". Received by email in December 2025.
- ICPSR. 2025a. "Utilization Report for the AEA Data and Code Repository." ICPSR [publisher]. Accessed December 2025.
- ICPSR. 2025b. "Deposit sizes for the AEA Data and Code Repository." ICPSR [publisher]. Received by email in December 2025.
- Vilhuber, Lars. 2025. "Process data for the AEA Pre-publication Verification Service." American Economic Association [publisher], [https://doi.org/10.3886/E117876V7](https://doi.org/10.3886/E117876V7)
- Zenodo. 2025. "Metadata on deposits in community 'aeajournals'", accessed via Zenodo API on December 6, 2025.
