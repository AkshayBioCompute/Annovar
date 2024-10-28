version 1.0

workflow AnnovarWorkflow {
    input {
        String input_vcf
        String output_dir
        String humandb_dir
        String annovar_dir
    }

    call InstallAnnovar
    call PrepareVcf {
        input: vcf_file = input_vcf
    }
    call AnnotateVariants {
        input: avinput_file = PrepareVcf.avinput_file
    }
    call GeneAnnotation {
        input: avinput_file = PrepareVcf.avinput_file
    }
    call RegionAnnotation {
        input: avinput_file = PrepareVcf.avinput_file
    }
    call FilterAnnotation {
        input: avinput_file = PrepareVcf.avinput_file
    }

    output {
        File annotated_variants = AnnotateVariants.annotated_output
        File gene_annotations = GeneAnnotation.gene_annotation_output
        File region_annotations = RegionAnnotation.region_annotation_output
        File filtered_variants = FilterAnnotation.filtered_variants
    }
}

task InstallAnnovar {
    command {
        # Step 1: Download ANNOVAR
        wget http://annovar.openbioinformatics.org/en/latest/annovar.zip -P ~/{annovar_dir}
        unzip ~/{annovar_dir}/annovar.zip -d ~/{annovar_dir}

        # Step 2: Prepare the humandb directory
        mkdir -p ~/{humandb_dir}

        # Step 3: Download necessary databases
        cd ~/{annovar_dir}
        ./annotate_variation.pl -buildver hg19 -downdb -webfrom annovar refGene humandb/
        ./annotate_variation.pl -buildver hg19 -downdb cytoBand humandb/
        ./annotate_variation.pl -buildver hg19 -downdb -webfrom annovar exac03 humandb/
        ./annotate_variation.pl -buildver hg19 -downdb -webfrom annovar avsnp147 humandb/
        ./annotate_variation.pl -buildver hg19 -downdb -webfrom annovar dbnsfp30a humandb/

        echo "ANNOVAR installed successfully" > annovar_installed.txt
    }

    output {
        File installed_file = "annovar_installed.txt"
    }
}

task PrepareVcf {
    input {
        File vcf_file
    }

    command {
        perl ~/{annovar_dir}/convert2annovar.pl -format vcf4 ~{vcf_file} > ~{output_dir}/akj_input.avinput
    }

    output {
        File avinput_file = "~{output_dir}/akj_input.avinput"
    }
}

task AnnotateVariants {
    input {
        File avinput_file
    }

    command {
        perl ~/{annovar_dir}/table_annovar.pl ~{avinput_file} ~/{humandb_dir} \
        --buildver hg19 --out ~{output_dir}/akj_anno --remove \
        --protocol refgene,cytoBand,exac03,avsnp147,dbnsfp30a \
        --operation gx,r,f,f,f --nastring . --csvout --polish \
        --xref ~/{annovar_dir}/example/gene_xref.txt
    }

    output {
        File annotated_output = "~{output_dir}/akj_anno.hg19_multianno.csv"
    }
}

task GeneAnnotation {
    input {
        File avinput_file
    }

    command {
        perl ~/{annovar_dir}/annotate_variation.pl -geneanno -dbtype refGene \
        -buildver hg19 ~{avinput_file} ~/{humandb_dir}
    }

    output {
        File gene_annotation_output = "~{output_dir}/akj_input.avinput.exonic_variant_function"
        File variant_function_output = "~{output_dir}/akj_input.avinput.variant_function"
    }
}

task RegionAnnotation {
    input {
        File avinput_file
    }

    command {
        perl ~/{annovar_dir}/annotate_variation.pl -regionanno -dbtype cytoBand \
        -buildver hg19 ~{avinput_file} ~/{humandb_dir}
    }

    output {
        File region_annotation_output = "~{output_dir}/akj_input.avinput.hg19_cytoBand"
    }
}

task FilterAnnotation {
    input {
        File avinput_file
    }

    command {
        perl ~/{annovar_dir}/annotate_variation.pl -filter -dbtype exac03 \
        -buildver hg19 ~{avinput_file} ~/{humandb_dir}
    }

    output {
        File filtered_variants = "~{output_dir}/akj_input.avinput.hg19_exac03_filtered"
    }
}

