#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Define parameters
params.input_vcf = '/home/akshay/Akshay/Annovar/input/akj.vcf'
params.output_dir = '/home/akshay/Akshay/Annovar/output/'
params.humandb_dir = '/home/akshay/Akshay/Annovar/humandb/'
params.annovar_dir = '/home/akshay/Akshay/Annovar/'

// Define the workflow
process install_annovar {
    output:
    path 'annovar_installed.txt'

    script:
    """
    # Step 1: Download ANNOVAR
    wget http://annovar.openbioinformatics.org/en/latest/annovar.zip -P ${params.annovar_dir}
    unzip ${params.annovar_dir}/annovar.zip -d ${params.annovar_dir}

    # Step 2: Prepare the humandb directory
    mkdir -p ${params.humandb_dir}

    # Step 3: Download necessary databases
    cd ${params.annovar_dir}
    ./annotate_variation.pl -buildver hg19 -downdb -webfrom annovar refGene humandb/
    ./annotate_variation.pl -buildver hg19 -downdb cytoBand humandb/
    ./annotate_variation.pl -buildver hg19 -downdb -webfrom annovar exac03 humandb/
    ./annotate_variation.pl -buildver hg19 -downdb -webfrom annovar avsnp147 humandb/
    ./annotate_variation.pl -buildver hg19 -downdb -webfrom annovar dbnsfp30a humandb/

    # Mark installation complete
    echo "ANNOVAR installed successfully" > annovar_installed.txt
    """
}

process prepare_vcf {
    input:
    path vcf_file from params.input_vcf

    output:
    path "${params.output_dir}/akj_input.avinput"

    script:
    """
    perl ${params.annovar_dir}/convert2annovar.pl -format vcf4 ${vcf_file} > ${params.output_dir}/akj_input.avinput
    """
}

process annotate_variants {
    input:
    path avinput_file from "${params.output_dir}/akj_input.avinput"

    output:
    path "${params.output_dir}/akj_anno.hg19_multianno.csv"

    script:
    """
    perl ${params.annovar_dir}/table_annovar.pl ${avinput_file} ${params.humandb_dir} \
    --buildver hg19 --out ${params.output_dir}/akj_anno --remove \
    --protocol refgene,cytoBand,exac03,avsnp147,dbnsfp30a \
    --operation gx,r,f,f,f --nastring . --csvout --polish \
    --xref ${params.annovar_dir}/example/gene_xref.txt
    """
}

process gene_annotation {
    input:
    path avinput_file from "${params.output_dir}/akj_input.avinput"

    output:
    path "${params.output_dir}/akj_input.avinput.exonic_variant_function",
         path "${params.output_dir}/akj_input.avinput.variant_function"

    script:
    """
    perl ${params.annovar_dir}/annotate_variation.pl -geneanno -dbtype refGene \
    -buildver hg19 ${avinput_file} ${params.humandb_dir}
    """
}

process region_annotation {
    input:
    path avinput_file from "${params.output_dir}/akj_input.avinput"

    output:
    path "${params.output_dir}/akj_input.avinput.hg19_cytoBand"

    script:
    """
    perl ${params.annovar_dir}/annotate_variation.pl -regionanno -dbtype cytoBand \
    -buildver hg19 ${avinput_file} ${params.humandb_dir}
    """
}

process filter_annotation {
    input:
    path avinput_file from "${params.output_dir}/akj_input.avinput"

    output:
    path "${params.output_dir}/akj_input.avinput.hg19_exac03_dropped",
         path "${params.output_dir}/akj_input.avinput.hg19_exac03_filtered"

    script:
    """
    perl ${params.annovar_dir}/annotate_variation.pl -filter -dbtype exac03 \
    -buildver hg19 ${avinput_file} ${params.humandb_dir}
    """
}

// Define the main workflow
workflow {
    install_annovar()
    prepare_vcf()
    annotate_variants()
    gene_annotation()
    region_annotation()
    filter_annotation()
}

