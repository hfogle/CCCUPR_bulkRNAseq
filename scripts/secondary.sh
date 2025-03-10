#!/usr/bin/env bash
#SBATCH --job-name=secondary
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12

PROJ_DIR=$(PWD)
STUDY_ID=jq '.study.study_id' $STUDYDESIGN
LOGS_DIR=${PROJ_DIR}/data/${STUDY_ID}/logs

source activate bulkRNAseq

Rscript ./functions/secondary.R $STUDY_ID &> ${LOGS_DIR}/secondary_integrated_processing.log