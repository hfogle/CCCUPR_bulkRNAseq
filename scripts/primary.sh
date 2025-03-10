#!/usr/bin/env bash
#SBATCH --job-name=primary
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=7
#SBATCH --array=1-16
#SBATCH --out /home/hfogle/proj/CCCUPR_bulkRNAseq/data/hfranco-240722-OVCAR3/logs/primary_data_processing.log
#SBATCH --open-mode=append

### IO PATHS
source activate bulkRNAseq

PROJ_DIR="/home/hfogle/proj/CCCUPR_bulkRNAseq"
SAMPLESHEET="/opt/data/bulk-RNA-seq/hfranco-240722-OVCAR3/meta_data/samplesheet.tsv"
STUDYDESIGN="/opt/data/bulk-RNA-seq/hfranco-240722-OVCAR3/meta_data/studydesign.json"

#STUDY_ID=jq '.study.study_id' $STUDYDESIGN
#STUDY_ID=jq '.study.study_id' $STUDYDESIGN
STUDY_ID="hfranco-240722-OVCAR3"
#DATA_DIR=jq '.data_processing.raw_data_path' $STUDYDESIGN
OUT_DIR=${PROJ_DIR}/data/${STUDY_ID}
REPORT_DIR=${OUT_DIR}/reports/read_processing
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
# IS_FASTQ=[["$(jq '.data_processing.data_format' $STUDYDESIGN)" == "FASTQ"]]
# IS_SEPARATED=jq '.data_processing.files_lane_separated' $STUDYDESIGN
# IS_INTERLEAVED=jq '.data_processing.files_pair_interleaved' $STUDYDESIGN

### Read trim and filter
file1=${OUT_DIR}/standardized_data/${FILE_NAME}_R1.fq.gz
file2=${OUT_DIR}/standardized_data/${FILE_NAME}_R2.fq.gz
file1out=${OUT_DIR}/processed_data/processed_reads/${FILE_NAME}_R1.fq.gz
file2out=${OUT_DIR}/processed_data/processed_reads/${FILE_NAME}_R2.fq.gz

# fastp -i $file1 -I $file2 -o $file1out -O $file2out -D -x -p -h ${FILE_NAME}_read_processing_report.html

### Salmon quantification
index=${OUT_DIR}/reference_data/salmon_index_gencode
genes=${OUT_DIR}/reference_data/gencode.v47.basic_annotation.gtf.gz
salmon_out=${OUT_DIR}/processed_data/transcript_quantification/$SAMPLE_ID

salmon quant -p 15 -i index=${OUT_DIR}/reference_data/salmon_index_gencode -l A --gcBias -o $salmon_out -1 $file1out -2 $file2out