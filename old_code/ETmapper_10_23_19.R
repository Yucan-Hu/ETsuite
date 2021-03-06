#! /usr/local/bin/Rscript

## TO DO
## 1. Create ReadTheDocs
## 2. 
## 3. 
## 4. 
## 5. 


### Check and Load Libraries
if("data.table" %in% installed.packages() == F){
  print("Please install R package data.table. Program quitting...")
  q(save="no")
}

library(data.table)




### Set up path variables for associated scripts and databases

# Get relative path of ETmapper install directory
initial.options <- commandArgs(trailingOnly = F)
file.arg.name <- "--file="
script.name <- sub(file.arg.name, "", initial.options[grep(file.arg.name, initial.options)])
script.basename <- dirname(script.name)

# Set up default database paths (note: normalizePath creates a full path from relative path)
ad <- normalizePath(paste0(script.basename,"/../db/ETseq_2_4_adap.fa")) #adapter sequences
md <- normalizePath(paste0(script.basename,"/../db/models.fa")) #model sequences


# Testing directory stuff above
print(normalizePath(script.basename))
print(ad)




### Collect and Parse arguments
args <- commandArgs(trailingOnly = T)

# Display help if no args or -h
if("-h" %in% args | !("-w" %in% args) | !("-d" %in% args) | !("-b" %in% args) | length(args) == 0) {
  cat("
  
    ####### #######                                           
    #          #    #    #   ##   #####  #####  ###### #####  
    #          #    ##  ##  #  #  #    # #    # #      #    # 
    #####      #    # ## # #    # #    # #    # #####  #    # 
    #          #    #    # ###### #####  #####  #      #####  
    #          #    #    # #    # #      #      #      #   #  
    #######    #    #    # #    # #      #      ###### #    # 
      
    Usage: ETmapper.R -w [workflow] -d [read_dir] -b [batch_file] -g [genome_db] [Additonal_Options]

    Mandatory Arguments:
      
      -w: Workflow type (No Default)
          jm - Junction mapping
          lm - Lite metagenomics coverage
      -d: Directory containing read files (No Default)
      -b: Batch file with sample information (No Default)
      -g: Directory containing genome database

    Adapter Filtering Options:

      -ad: Adapter sequence file (Default: db/adap_small.fa)
      -am: Min length of adapter match (Default: 5)
      -qs: Min base quality (Default: 20)

    Model Identification Options:
    
      -md: Junction model sequence file (Default: db/models.fa)
      -mm: Min length of model match (Default: 25)
      -et: Model match error (Default: 0.02)
      
    Program Control:
    
      -o: Output directory (Will be created if not specified)
      -cpu: Number of cores (Default: 1)
      -h: Bring up this help menu\n\n")
  
  
  q(save="no")
}


### Arg Testing

## Mandatory Arguments
# Work Flow Type
wf <- args[which(args == "-w") + 1]
print(paste0("workflow type is: ", wf))

# Read Directory
rd <- args[which(args == "-d") + 1]
print(paste0("read directory is: ", rd))

# Batch File
bf <- args[which(args == "-b") + 1]
print(paste0("batch file is: ", bf))
batch_file <- read.table(bf, sep = "\t", header = F)


## Adapter Filtering Arguments
# Adapter Database File
ad <- ad
if("-ad" %in% args){
  ad <- args[which(args == "-ad") + 1]
  ad <- normalizePath(ad)
}
print(paste0("Adapter Database is: ", ad))

# MMin Length of Adapter Match (Default: 5)
am <- 5
if("-m" %in% args){
  am <- as.numeric(args[which(args == "-am") + 1])
}

# Min base quality score (Default: 20)
qs <- 20
if("-q" %in% args){
  qs <- as.numeric(args[which(args == "-qs") + 1])
}


## Model Identification Options
# Model Database File
md <- md
if("-md" %in% args){
  md <- args[which(args == "-md") + 1]
  md <- normalizePath(md)
}
print(paste0("Adapter Database is: ", md))

# Min length of model match  (Default: 25)
mm <- 25
if("-m" %in% args){
  mm <- as.numeric(args[which(args == "-mm") + 1])
}

# Max model match error (Default: 0.02)
et <- 0.02
if("-q" %in% args){
  et <- as.numeric(args[which(args == "-et") + 1])
}


## Junction Mapping Options









#### BEGIN WORKFLOWS ####


### Junction Mapping Workflow 
if (wf == "jm"){

  ### Create Log File - WORKING!
  cat(
  paste0("ETmapper Log    Created: ", date()),"\n\n",
  "Program Parameters:\n\n",
  paste0("Workflow type is: ", wf),"\n",
  paste0("Total Samples: ",nrow(batch_file)),"\n",
  paste0("Adapter Trim DB: ", ad,"\n"),
  file = "ETmapper.log")
  
  
  
  ### Trimming and filtering paired reads
  
  # Run adapter/flanking sequence trimming for loop
  for (i in 1:nrow(batch_file)){

    system(paste0("cutadapt -a file:",ad," -A file:",ad, # specify adapter types and file
                  " -j 4 -O ",am," -q ",qs, # specify trimming params
                  " -o ",batch_file[i,3],".trim", # fwd output
                  " -p ",batch_file[i,4],".trim", # rev output
                  " ",rd,batch_file[i,3], # fwd read
                  " ",rd,batch_file[i,4], # rev read
                  " > ",batch_file[i,1],".trim.log")) # log files

  }
  
  ####### TO DO HERE ###### 
  
  # Put trim metadata into spreadsheet
  # for loop for pulling cutadapt.log files 
  
  ####### TO DO HERE ###### 
  
  
  
  ### Identifying and Trimming Models
  
  # Run model finding for loop on fwd reads but include reverse 
  for (i in 1:nrow(batch_file)){
    
    system(paste0("cutadapt -g file:",md, # specify model file
                  " -O ",mm," -e ",et, # specify trimming params
                  " --discard-untrimmed",
                  paste0(" --info-file",
                  " -o ",batch_file[i,3],".trim", # fwd output
                  " ",rd,batch_file[i,3], # fwd read
                  " ",rd,batch_file[i,4], # rev read
                  " > ",batch_file[i,1],".trim.log")) # log files
    
  }
  
  
  
  
  
  
  
  # cutadapt -g file:/Users/Spencer/Dropbox/Banfield_Lab_Files/Projects/mCAFE/mCAFE_Project/ET_Mapper/db/models.fa -e 0.02 -O 25 --discard-untrimmed --info-file tmp.txt -o JD_ZZ_2ndcycle_5_S5_L001_R1_001.fastq.clean -p JD_ZZ_2ndcycle_5_S5_L001_R2_001.fastq.clean JD_ZZ_2ndcycle_5_S5_L001_R1_001.fastq.trim JD_ZZ_2ndcycle_5_S5_L001_R2_001.fastq.trim
  
  # # Filter cutadapt info file for reads with model
  # system(paste0("awk '{if ($3!=-1) print}' ","test_data/ETmapper_test_data/reads/tmp.txt > test_data/ETmapper_test_data/reads/tmp_filt.txt"))
  # 
  # 
  # # Identify flanking region to use as barcode query
  # bc_flank <- system("grep -o \"NN.*.NN\" /Users/Spencer/Dropbox/Banfield_Lab_Files/Projects/mCAFE/mCAFE_Project/ET_Mapper/db/models.fa | sed 's/N//g'", intern = T)
  # bc_flank <- unique(bc_flank)
  # 
  # # pull filtered model hit file
  # ca_info <- fread("test_data/ETmapper_test_data/reads/tmp_filt.txt", header = F)
  # 
  # # create barcode output file
  # bc_out <- data.frame(read = ca_info$V1, model = ca_info$V8, mod_len = ca_info$V4)
  # 
  # # create tmp barcode storage frame and loop finding barcodes  
  # bc_tmp_store <- data.frame()
  # for (i in 1:length(bc_flank)){
  # 
  #   # parse ca_info for those with exact primer match
  #   bc_flank_i_matches <- ca_info[grep(bc_flank[i], ca_info$V6),c(1,6)]
  # 
  #   # Find upstream 20bp of target sequence and sub out target for nothing
  #   matches <- regexpr(paste0(bc_flank[i],".{0,20}"), bc_flank_i_matches$V6, perl = T)
  #   bc_flank_i_matches$barcodes <- sub(bc_flank[i], "", regmatches(bc_flank_i_matches$V6, matches))
  #   
  #   # Create final data frame w/ column for flank and match and cbind to outupt
  #   bc_flank_i_matches <- data.frame(bc_flank_i_matches[,-2], flank_seq = bc_flank[i])
  #   bc_tmp_store <- rbind(bc_tmp_store, bc_flank_i_matches)
  # 
  # }
  #   
  # # merge barcodes to output file
  # bc_out <- merge(bc_out, bc_tmp_store, by.x = "read", by.y = "V1", all.x = T)
  # 
  # 
  # # step 3: output read barcodes to file as well as log number of barcodes per samples

} else {
  print("MetaG workflow not ready yet!")
}





