# Snakefile for ANNOVAR Workflow

# Define input and output file paths
input_vcf = "/home/akshay/Akshay/Annovar/input/akj.vcf"
output_dir = "/home/akshay/Akshay/Annovar/output/"
humandb_dir = "/home/akshay/Akshay/Annovar/humandb/"
annovar_dir = "/home/akshay/Akshay/Annovar/"

# Rule for installing ANNOVAR
rule install_annovar:
    output:
        "annovar_installed.txt"
    shell:
        """
        # Step 1: Download ANNOVAR
        wget http://annovar.openbioinformatics.org/en/latest/annovar.zip -P {annovar_dir}
        unzip {annovar_dir}/annovar.zip -d {annovar_dir}

        # Step 2: Prepare the humandb directory
        mkdir -p {humandb_dir}

        # Step 3: Download necessary databases
        cd {annovar_dir}
        ./annotate_variation.pl -buildver hg19 -downdb -webfrom annovar refGene humandb/
        ./annotate_variation.pl -buildver hg19 -downdb cytoBand humandb/
        ./annotate_variation.pl -buildver hg19 -downdb -webfrom annovar exac03 humandb/
        ./annotate_variation.pl -buildver hg19 -downdb -webfrom annovar avsnp147 humandb/
        ./annotate_variation.pl -buildver hg19 -downdb -webfrom annovar dbnsfp30a humandb/
        
        # Mark installation complete
        echo "ANNOVAR installed successfully" > ../annovar_installed.txt
        """

# Rule for preparing the input VCF file
rule prepare_vcf:
    input:
        input_vcf
    output:
        "{output_dir}/akj_input.avinput"
    shell:
        "perl {annovar_dir}/convert2annovar.pl -format vcf4 {input} > {output}"

# Rule for annotating variants
rule annotate_variants:
    input:
        "{output_dir}/akj_input.avinput"
    output:
        "{output_dir}/akj_anno.hg19_multianno.csv"
    params:
        humandb=humandb_dir
    shell:
        "perl {annovar_dir}/table_annovar.pl {input} {params.humandb} "
        "--buildver hg19 --out {output_dir}/akj_anno --remove "
        "--protocol refgene,cytoBand,exac03,avsnp147,dbnsfp30a "
        "--operation gx,r,f,f,f --nastring . --csvout --polish "
        "--xref {annovar_dir}/example/gene_xref.txt"

# Rule for gene-based annotation
rule gene_annotation:
    input:
        "{output_dir}/akj_input.avinput"
    output:
        "{output_dir}/akj_input.avinput.exonic_variant_function",
        "{output_dir}/akj_input.avinput.variant_function"
    params:
        humandb=humandb_dir
    shell:
        "perl {annovar_dir}/annotate_variation.pl -geneanno -dbtype refGene "
        "-buildver hg19 {input} {params.humandb}"

# Rule for region-based annotation
rule region_annotation:
    input:
        "{output_dir}/akj_input.avinput"
    output:
        "{output_dir}/akj_input.avinput.hg19_cytoBand"
    params:
        humandb=humandb_dir
    shell:
        "perl {annovar_dir}/annotate_variation.pl -regionanno -dbtype cytoBand "
        "-buildver hg19 {input} {params.humandb}"

# Rule for filter-based annotation
rule filter_annotation:
    input:
        "{output_dir}/akj_input.avinput"
    output:
        "{output_dir}/akj_input.avinput.hg19_exac03_dropped",
        "{output_dir}/akj_input.avinput.hg19_exac03_filtered"
    params:
        humandb=humandb_dir
    shell:
        "perl {annovar_dir}/annotate_variation.pl -filter -dbtype exac03 "
        "-buildver hg19 {input} {params.humandb}"

# Define the main workflow
rule all:
    input:
        "annovar_installed.txt",
        "{output_dir}/akj_input.avinput",
        "{output_dir}/akj_anno.hg19_multianno.csv",
        "{output_dir}/akj_input.avinput.exonic_variant_function",
        "{output_dir}/akj_input.avinput.variant_function",
        "{output_dir}/akj_input.avinput.hg19_cytoBand",
        "{output_dir}/akj_input.avinput.hg19_exac03_dropped",
        "{output_dir}/akj_input.avinput.hg19_exac03_filtered"

