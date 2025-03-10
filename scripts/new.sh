#!/usr/bin/env bash
#SBATCH --job-name=new
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo "Add description of the script functions here."
   echo
   echo "Syntax: scriptTemplate [-g|h|v|V]"
   echo "options:"
   echo "g     Print the GPL license notification."
   echo "h     Print this Help."
   echo "v     Verbose mode."
   echo "V     Print software version and exit."
   echo
}

############################################################
############################################################
# Main program                                             #
############################################################
############################################################

# Set variables
Name="world"

############################################################
# Process the input options. Add options as needed.        #
############################################################
# Get the options
while getopts ":hn:" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      n) # Enter a name
         Name=$OPTARG;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done


echo "hello $Name!"

### IO PATHS

PROJ_DIR="/home/hfogle/proj/CCCUPR_bulkRNAseq"
SAMPLESHEET="/opt/data/bulk-RNA-seq/hfranco-240722-OVCAR3/meta_data/samplesheet.tsv"
STUDYDESIGN="/opt/data/bulk-RNA-seq/hfranco-240722-OVCAR3/meta_data/studydesign.json"

STUDY_ID=jq '.study.study_id' $STUDYDESIGN
STUDY_ID="hfranco-240722-OVCAR3"
DATA_DIR=jq '.data_processing.raw_data_path' $STUDYDESIGN
DATA_DIR="/opt/data/bulk-RNA-seq/hfranco-240722-OVCAR3/raw_data"
OUT_DIR="${PROJ_DIR}/data/${STUDY_ID}"

### Create study directories, copy metadata files

if [ -w ${PROJ_DIR}/data/ ]; 
then 
echo "Creating work directories for new study....."
mkdir $OUT_DIR
mkdir ${OUT_DIR}/reference_data
mkdir ${OUT_DIR}/meta_data
mkdir ${OUT_DIR}/standardized_data
mkdir ${OUT_DIR}/reports
mkdir ${OUT_DIR}/figures
mkdir ${OUT_DIR}/logs
mkdir ${OUT_DIR}/processed_data
mkdir ${OUT_DIR}/processed_data/processed_reads
mkdir ${OUT_DIR}/processed_data/transcript_quantification
mkdir ${OUT_DIR}/processed_data/normalized_counts
mkdir ${OUT_DIR}/processed_data/differential_gene_expression
mkdir ${OUT_DIR}/processed_data/differential_transcript_usage
mkdir ${OUT_DIR}/reports/read_processing
mkdir ${OUT_DIR}/reports/transcript_quantification
else 
echo "NOT WRITABLE, Change Permissions"
fi




### Merge Lane/Run split data files and rename
IS_FASTQ=[["$(jq '.data_processing.data_format' $STUDYDESIGN)" == "FASTQ"]]



### Verify checksums, or perform initial checksums
# sha256
DATA_DIR=/opt/data/bulk-RNA-seq/hfranco-240722-OVCAR3/raw_data
for file in $(ls ${DATA_DIR}/*fastq.gz) 
do
if [ -f ${file}.sha256 ] 
then
sum=$(sha256sum --check ${file}.sha256 $file)
echo "$file file integrity status..... $sum"
else
echo "Creating sha256 checksum for $file"
sha256sum $file > ${file}.sha256
fi
done

### Validate fastq files (SeqFu)

### Interleave fastq files
IS_INTERLEAVED=jq '.data_processing.files_pair_interleaved' $STUDYDESIGN
R1=jq '.data_processing.r1_file_extension' $STUDYDESIGN
R2=jq '.data_processing.r2_file_extension' $STUDYDESIGN
R1="_R1_001.fastq.gz"
R2="_R2_001.fastq.gz"
OUT_DIR=/opt/data/bulk-RNA-seq/hfranco-240722-OVCAR3/processed_data/processed_reads
if [ $IS_INTERLEAVED = "FALSE"]
  then
  for file1 in $(ls ${DATA_DIR}/*$R1)
  do
  file2="${file1%$R1}"$R2
  echo "Interleaving files:"
  echo $file1     
  echo $file2
  seqfu ilv -v -1 $file1 -2 $file2 -o ${OUT_DIR}/"${file1%$R1}".ilv.fq.gz 
  done
fi
### Lane merge fastq files and rename
IS_SEPARATED=jq '.data_processing.files_lane_separated' $STUDYDESIGN

if [ $IS_SEPARATED ]; then
  for ID in (cut -f1 $SAMPLESHEET);
  do
  SAMPLE_ID=$(awk -v ArrayTaskID=$ID '$1==ArrayTaskID {print $5}' $SAMPLESHEET)
  GROUP_ID=$(awk -v ArrayTaskID=$ID '$1==ArrayTaskID {print $7}' $SAMPLESHEET)
  FILE_NAME=${GROUP_ID}_${SAMPLE_ID}
  merge=$(ls ${OUT_DIR}/exchange_data/*${ID}*.ilv.fq.gz) 
  seqfu -e .ilv.fq.gz -o ${OUT_DIR}/exchange_data/${ID}_merge.ilv.fq.gz
  done
fi

### Rename files, transfer to working directory

  for ID in $(cut -f1 $SAMPLESHEET | tail -n +2)
  do
  SAMPLE_ID=$(awk -v ArrayTaskID=$ID '$1==ArrayTaskID {print $5}' $SAMPLESHEET)
  GROUP_ID=$(awk -v ArrayTaskID=$ID '$1==ArrayTaskID {print $7}' $SAMPLESHEET)
  FILE_ID=$(awk -v ArrayTaskID=$ID '$1==ArrayTaskID {print $2}' $SAMPLESHEET)
  FILE_NAME=${GROUP_ID}_${SAMPLE_ID}
  file1=$(ls ${DATA_DIR}/*${FILE_ID}*$R1)
  file2=$(ls ${DATA_DIR}/*${FILE_ID}*$R2)
  #merge=$(ls ${OUT_DIR}/exchange_data/*${ID}*.ilv.fq.gz) 
  #seqfu -e .ilv.fq.gz -o ${OUT_DIR}/exchange_data/${ID}_merge.ilv.fq.gz
  echo $ID
  echo $FILE_NAME
  echo $file1
  echo $file2
  cp $file1 ${OUT_DIR}/standardized_data/${FILE_NAME}_R1.fq.gz
  cp $file2 ${OUT_DIR}/standardized_data/${FILE_NAME}_R2.fq.gz
  done
### Create required mapping indexes if not present
# https://www.gencodegenes.org/human/
path=/opt/data/bulk-RNA-seq/hfranco-240722-OVCAR3/reference_data
url=https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_47/gencode.v47.pc_transcripts.fa.gz
file_tran=gencode.v47.pc_transcripts.fa.gz
curl $url > ${path}/${file_tran}
url=https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_47/gencode.v47.basic.annotation.gtf.gz
file_gtf=gencode.v47.basic_annotation.gtf.gz
curl $url > ${path}/${file_gtf}
url=https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_47/GRCh38.primary_assembly.genome.fa.gz
file_pri=gencode.v47.primary_assembly.fa.gz
curl $url > ${path}/${file_pri}
# Prepare genome masking decoys file
grep "^>" <(gunzip -c $file_pri) | cut -d " " -f 1 > decoys.txt
sed -i.bak -e 's/>//g' decoys.txt
# Make reference genome-transcriptome file
cat $file_tran $file_pri > gentrome.fa.gz
# build salmon index
salmon index -t gentrome.fa.gz -d decoys.txt -p 12 -i salmon_index_gencode --gencode

