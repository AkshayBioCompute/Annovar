#!/bin/bash
# Usage: ./annotate_variants.sh input.avinput output_dir humandb_dir annovar_dir

avinput_file="$1"
output_dir="$2"
humandb_dir="$3"
annovar_dir="$4"

perl "${annovar_dir}/table_annovar.pl" "${avinput_file}" "${humandb_dir}" \
--buildver hg19 --out "${output_dir}/output" --remove \
--protocol refgene,cytoBand,exac03,avsnp147,dbnsfp30a \
--operation gx,r,f,f,f --nastring . --csvout --polish \
--xref "${annovar_dir}/example/gene_xref.txt"
