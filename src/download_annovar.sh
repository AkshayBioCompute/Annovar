#!/bin/bash
# Usage: ./download_annovar.sh annovar_dir humandb_dir

annovar_dir="$1"
humandb_dir="$2"

wget http://annovar.openbioinformatics.org/en/latest/annovar.zip -P "${annovar_dir}"
unzip "${annovar_dir}/annovar.zip" -d "${annovar_dir}"

# Prepare the humandb directory and download necessary databases
mkdir -p "${humandb_dir}"
cd "${annovar_dir}"

./annotate_variation.pl -buildver hg19 -downdb -webfrom annovar refGene humandb/
./annotate_variation.pl -buildver hg19 -downdb cytoBand humandb/
./annotate_variation.pl -buildver hg19 -downdb -webfrom annovar exac03 humandb/
./annotate_variation.pl -buildver hg19 -downdb -webfrom annovar avsnp147 humandb/
./annotate_variation.pl -buildver hg19 -downdb -webfrom annovar dbnsfp30a humandb/

