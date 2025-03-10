### Secondary data processing (feature count data)


### Libraries

### Options
args <- list(RUN_BATCH_CORRECTION=TRUE,
             RUN_BATCH_CORRECTION=TRUE,
             EXCLUDE_OUTLIER_SAMPLES=TRUE,
             FEATUER_COUNT_MINIMUM=2,
             MODEL_INTERACTION_VARIABLES=FALSE,
             
                
                STUDY=""
)
### Parameters
params <- list(FREE_MEM=1000000,
               FREE_CORES=1
               )

### IO Paths
paths <- list(wdir="",
              meta="",
              data="",
              output="",
              figures="",
              reports="",
              reference=""
              )

### Test Values
options$STUDY <- "test"
paths$wdir <- "~/proj/CCCUPR_bulkRNAseq"
paths$meta <- file.path(paths$wdir,"data",options$STUDY,"meta_data")
paths$data <- file.path(paths$wdir,"data",options$STUDY,"processed_data","transcript_quantification")
paths$output <- file.path(paths$wdir,"data",options$STUDY,"processed_data")

### Metadata Import
studydesign <- jsonlite::read_json(path = file.path(paths$meta, "studydesign.json"), simplifyVector = FALSE)
samplesheet <- read.delim(file = file.path(paths$meta, "samplesheet.tsv"), header = TRUE)
factors <- as.data.frame(samplesheet[,grep("FACTOR", colnames(samplesheet))])
interactions <- as.data.frame(samplesheet[,grep("INTERACTION", colnames(samplesheet))])
attributes <- as.data.frame(samplesheet[,grep("ATTRIBUTE", colnames(samplesheet))])
modelsheet <- read.delim(file = file.path(paths$meta, "modelsheet.tsv"), header = TRUE)

### Model Definition
# build model matrix (allow multiple as list)
# validate models
# annotate models
# build contrast matrix (allow multiple as list)

### Data Import

### Batch Correction

### Normalization

### Quality Assessment

### Transcript Aggregation

### Dimensional Reduction

### Celltype, PAM50 Subtype Inference

### Differential Gene Expression
library(Deseq2)

### Differential Isoforms

### Session Info
devtools::session_info()