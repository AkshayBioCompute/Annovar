# ANNOVAR Project Workflow

This repository provides workflows for processing and annotating VCF files using ANNOVAR, compatible with Nextflow, Snakemake, and WDL.

## Prerequisites
- [ANNOVAR](https://annovar.openbioinformatics.org/en/latest/)
- Python packages listed in `requirements.txt` (use `pip install -r requirements.txt` to install)
- Perl for executing ANNOVAR scripts

## Folder Structure
- `nexflow.nf`: Nextflow script to process VCF files with ANNOVAR
- `snakefile`: Snakemake script for the same workflow
- `workflow.wdl`: WDL workflow script
- `InputWDL.json`: Input parameters for the WDL workflow
- `src/`: Contains all shell scripts required for each process

## Usage

1. **Install Python dependencies**:
   ```bash
   pip install -r requirements.txt

2. Run the workflow:

  **For Nextflow**:
    ```bash
    nextflow run nexflow.nf
    
  **For Snakemake**:
    ```bash
    snakemake --snakefile snakefile
    
  **For WDL: Ensure your WDL runner (e.g., Cromwell) is installed, and then execute the workflow**:
      ```bash
    java -jar cromwell.jar run workflow.wdl -i InputWDL.json
