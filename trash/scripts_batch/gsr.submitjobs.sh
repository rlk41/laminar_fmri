#!/bin/bash 

set -e 

job_name="gsr"
job_list="/home/kleinrl/projects/laminar_fmri/logs/${job_name}-joblist.log"
touch $job_list 

for EPI in $VASO_func_dir/*movie*VASO.nii
do 
    echo $EPI 
    source /home/kleinrl/projects/laminar_fmri/paths_biowulf
    
    log="/home/kleinrl/projects/laminar_fmri/logs/${job_name}-${EPI_base}.log"

    echo "  "
    echo "EPI: ${EPI}"
    echo "  "
    echo "LOG: ${log}"
    echo "  "

    sbatch --mem=140g --cpus-per-task=5 \
    --partition=norm \
    --output=$log \
    --time 12:00:00 \
    --job-name=$job_name \
    gsr.job.sh $EPI >> $job_list

done 