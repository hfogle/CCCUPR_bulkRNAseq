# CCCUPR_bulkRNAseq
Data Processing Pipeline for Bulk RNA-Seq Datasets

### Summary

### Installation Instructions

### Data Staging

1. Build study metadata ISATAB
2. Transfer ${STUDY_NAME}.isa.zip file to server staging directory: /opt/data/bulk_rnaseq/${STUDY_NAME}/metadata/
3. Transfer raw FASTQ data files to server staging directory: /opt/data/bulk_rnaseq/${STUDY_NAME}/raw_data_original/

### Running CCCUPR_bulkRNAseq Pipeline via Slurm Scheduler

On server shell command line run:

1. cd ~/CCCUPR_bulkRNAseq
2. sbatch code/new_study.sh ${STUDY_NAME}
3. sbatch code/primary_processing_genes.sh ${STUDY_NAME}
4. sbatch code/primary_processing_transcripts.sh ${STUDY_NAME}
5. sbatch code/secondary_processing.sh ${STUDY_NAME}

### Directory Structure
- data
  - [STUDY_ID]
    - reports
      - individual_sample_reports
        - sample_read_quality_raw
        - sample_read_quality_trimmed
        - sample_genome_alignment
        - sample_transcriptome_alignment
        - sample_analysis
        - sample_figures
      - read_quality_report_raw.html
      - read_quality_report_trimmed.html
      - analysis_report.html
      - figures
    - metadata
      - metadata.isa.zip
      - samplesheet.tsv
      - assay_parameters.json
    - logs
      - individual_sample_logs
      - secondary_processing_genes.log
      - secondary_processing_transcripts.log
      - primary_processing_genes.log
      - primary_processing_transcripts.log
      - new_study_validation.log
      - analysis_report.log
    - primary_processing
      -   trimmed_reads
      -   genome_alignment
      -   transcriptome_alignment
    - secondary_processing
      - gene_counts_raw.tsv
      - gene_counts_normalized.tsv
      - contrasts.tsv
      - gene_contrast_matrix.tsv
      - gene_differential_expression_table.tsv
      - transcript_counts_raw.tsv
      - transcript_counts_normalized.tsv
      - isoform_differential_expression_table.tsv
    - raw_data_exchange
- reference_data
  - [REFERENCE_ID]  
- code
  - functions.R
  - secondary_processing_genes.R
  - secondary_processing_transcripts.R
  - primary_processing_genes.sh
  - primary_processing_transcripts.sh
  - make_genome_reference_index.sh
  - make_transcriptome_reference_index.sh
  - get_reference_data.sh
  - new_study.sh
- config
  - metadata_template.tsv
  - metadata_model.json
  - computational_config.json
  - bulkRNAseq_conda_environment.yml
