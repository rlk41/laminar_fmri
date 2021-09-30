#!/bin/bash 
set -e 


source /home/kleinrl/projects/laminar_fmri/paths_biowulf 
job_name='LNGROW_120g'
log="/home/kleinrl/projects/laminar_fmri/logs/${job_name}.log"

ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=20
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS

sbatch --mem=120g --cpus-per-task=10 \
--partition=norm \
--mail-type=TIME_LIMIT_90,END \
--output=$log \
--time 100:00:00 \
--job-name=$job_name \
"${tools_dir}/run_ANTs -e $EPI_bias -a $ANAT"


