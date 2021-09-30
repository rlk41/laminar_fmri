#!/bin/bash 


for EPI in $VASO_func_dir/*VASO.nii
do 
    echo $EPI 
    source /home/kleinrl/projects/laminar_fmri/paths_biowulf 
    
    base=$(basename $EPI .nii)
    job_name="runANTS-CC-${base}"
    log="/home/kleinrl/projects/laminar_fmri/logs/${job_name}.log"

    ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=40
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS

    sbatch --mem=40g --cpus-per-task=30 \
    --partition=norm \
    --output=$log \
    --time 50:00:00 \
    --job-name=$job_name \
    "${scripts_dir}/main_EPI.sh" "${EPI}"


done 
# EPI="/data/kleinrl/ds003216/derivatives/sub-01/VASO_func/sub-01_ses-04_task-movie_run-04_VASO.nii"
    #/home/kleinrl/projects/laminar_fmri/tools/ANTs_job.sh
#    --mail-type=BEGIN,TIME_LIMIT_90,END \
