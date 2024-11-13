#!/bin/bash
# Usage: ./convert_to_avinput.sh input.vcf output.avinput annovar_dir

vcf_file="$1"
output_avinput="$2"
annovar_dir="$3"

perl "${annovar_dir}/convert2annovar.pl" -format vcf4 "${vcf_file}" > "${output_avinput}"
