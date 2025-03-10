#!/usr/bin/env bash
#SBATCH --job-name=primary
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --array=$1 

### IO PATHS

PROJ_DIR=$(PWD)
SAMPLESHEET=${PROJ_DIR}/metadata/samplesheet.tsv
STUDYDESIGN=${PROJ_DIR}/metadata/studydesign.json

STUDY_ID=jq '.study.study_id' $STUDYDESIGN
DATA_DIR=jq '.data_processing.raw_data_path' $STUDYDESIGN
OUT_DIR= ${PROJ_DIR}/data/${STUDY_ID}/

### Import samplesheet, studydesign

### Define exchange filename based on SOURCE_ID+SAMPLE_ID+GROUP_ID metadata


FILE_ID=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $2}' $SAMPLESHEET)
BATCH_ID=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $3}' $SAMPLESHEET)
SOURCE_ID=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $4}' $SAMPLESHEET)
SAMPLE_ID=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $5}' $SAMPLESHEET)
EXTRACT_ID=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $6}' $SAMPLESHEET)
GROUP_ID=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $7}' $SAMPLESHEET)

FILE_NAME=${GROUP_ID}_${SAMPLE_ID}

### Merge Lane/Run split data files and rename
IS_FASTQ=[["$(jq '.data_processing.data_format' $STUDYDESIGN)" == "FASTQ"]]
IS_SEPARATED=jq '.data_processing.files_lane_separated' $STUDYDESIGN
IS_INTERLEAVED=jq '.data_processing.files_pair_interleaved' $STUDYDESIGN

### Read trim and filter

fastp -i in.R1.fq.gz -I in.R2.fq.gz -o out.R1.fq.gz -O out.R2.fq.gz

### Salmon quantification
salmon quant -p 6 -i gencode.v28_salmon-0.10.0 -l A --gcBias -o sample -1 sample_1.fa.gz -2 sample_2.fa.gz