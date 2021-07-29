#!/usr/bin/env Rscript

# Title     : DensParcorr
# Objective : TODO
# Created by: richard
# Created on: 6/30/21

# Rscript --vanilla ${tools_dir}/gen_DensParcorr.R $dataframe_hcpl3_mean_matrix_t $dens_dir

# https://cran.r-project.org/web/packages/DensParcorr/DensParcorr.pdf
library('DensParcorr')

args <- commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied (input dir)\n", call=FALSE)
} else if (length(args)==1) {
  # default output file
  # args[2] = "out.txt"
}

data_path <- args[1]
dens_dir <- args[2]

# data_path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/dataframe.hcpl3.mean/data.mean.t.txt'
# dens_dir='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/dens_hcpl3'
data <- read.table(data_path)

# started: 6/30 12:20
dens.est = DensParcorr(data, directory=dens_dir) # select=FALSE,dens.level="plateau",plateau.thresh=0.01, Parcorr.est=NULL, ,lambda=NULL

partial.dens.est =  DensParcorr(data, dens.level =.4, select=True, directory=dens_dir)

partial.dens.est2 =  DensParcorr(data, Parcorr.est=partial.dens.est, dens.level=.6, select=True, directory=dens_dir)
