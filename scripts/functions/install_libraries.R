#!/usr/bin/env Rscript --vanilla

gitcreds_get(url = "https://github.com", use_cache = TRUE, set_cache = TRUE)
git config --global user.email homer.fogle@gmail.com
git config --global user.name "hfogle"
git commit --amend --reset-author
### Library Installation RScript for CCCUPR_bulkRNAseq Pipeline



### R LIBRARIES