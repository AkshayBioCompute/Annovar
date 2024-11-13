# ANNOVAR Project Workflow

This repository provides workflows for processing and annotating VCF files using ANNOVAR, compatible with Nextflow, Snakemake, and WDL.

## Prerequisites
- [ANNOVAR](https://annovar.openbioinformatics.org/en/latest/)
- Python packages listed in `requirements.txt` (use `pip install -r requirements.txt` to install)
- Perl for executing ANNOVAR scripts

## Folder Structure
Annovar_Project/
├── InputWDL.json         # JSON input file for WDL
├── README.md             # Documentation
├── nexflow.nf            # Nextflow script
├── snakefile             # Snakemake script
├── workflow.wdl          # WDL workflow
├── requirements.txt      # Python dependencies
└── src/                  # Contains auxiliary scripts and configurations
    ├── convert_to_avinput.sh      # Conversion script
    ├── annotate_variants.sh       # Annotation script
    ├── download_annovar.sh        # Download ANNOVAR and databases
    ├── gene_annotation.sh         # Gene-based annotation script
    ├── region_annotation.sh       # Region-based annotation script
    └── filter_annotation.sh       # Filter-based annotation script

## Usage

1. **Install Python dependencies**:
   ```bash
   pip install -r requirements.txt

2. Run the workflow:

  For Nextflow:
    nextflow run nexflow.nf
    
  For Snakemake:
    snakemake --snakefile snakefile
    
  For WDL: Ensure your WDL runner (e.g., Cromwell) is installed, and then execute the workflow:
    java -jar cromwell.jar run workflow.wdl -i InputWDL.json
