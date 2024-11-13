#!/bin/bash
# Usage: ./gene_annotation.sh input.avinput humandb_dir annovar_dir

avinput_file="$1"
humandb_dir="$2"
annovar_dir="$3"

perl "${annovar_dir}/annotate_variation.pl" -geneanno -dbtype refGene \
-buildver hg19 "${avinput_file}" "${humandb_dir}"
