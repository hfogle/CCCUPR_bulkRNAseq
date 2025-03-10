# CCCUPR_bulkRNAseq

Data Processing Pipeline for Bulk RNA-Seq Datasets

### Summary

### Installation Instructions

### Data Staging

1.  Build study metadata files (samplesheet.tsv, modelsheet.tsv, studydesign.json) according to template formatting.
2.  Transfer raw FASTQ data files to server staging directory: /opt/data/bulkRNAseq_studies/\${STUDY_ID}/raw_data/
3.  Transfer metadata files to: /opt/data/bulkRNAseq_studies/\${STUDY_ID}/meta_data/

### Running CCCUPR_bulkRNAseq Pipeline via Slurm Scheduler

On server shell command line run:

1.  cd \~/CCCUPR_bulkRNAseq
2.  sbatch scripts/new.sh -s samplesheet.tsv –d studydesign.json -m modelsheet.tsv
3.  sbatch scripts/primary.sh \${STUDY_ID}
4.  sbatch scripts/secondary.sh \${STUDY_ID}

### Directory Structure

-   data/
    -   [STUDY_ID]/
        -   reports/
        -   figures/
        -   meta_data/
            -   metadata.isa.zip
            -   samplesheet.tsv
            -   modelsheet.tsv
            -   studydesign.json
        -   standardized_data/
        -   reference_data/
        -   processed_data/
        -   logs/
-   scripts/
    -   functions/
    -   new.sh
    -   primary.sh
    -   secondary.sh
-   config/
    -   studydesign_template.json
    -   samplesheet_template.json
    -   modelsheet_template.json
    -   metadata_model.json
    -   bulkRNAseq_conda_environment.yml
