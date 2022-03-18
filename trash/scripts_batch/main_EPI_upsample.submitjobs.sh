#!/bin/bash 
set -e 

for EPI in $VASO_func_dir/*movie*VASO.nii
do 
    echo $EPI 
    source /home/kleinrl/projects/laminar_fmri/paths_biowulf 
    log="/home/kleinrl/projects/laminar_fmri/logs/EPI_upsample-${EPI_base}.log"
    job_name="EPI_upsample"

    echo "  "
    echo "EPI: ${EPI}"
    echo "  "
    echo "LOG: ${log}"
    echo "  "
    
    # need mem for upsampling EPI and EPI_mean 

    sbatch --mem=140g --cpus-per-task=10 \
    --partition=norm \
    --output=$log \
    --time 10:00:00 \
    --job-name=$job_name \
    main_EPI_upsample.sh $EPI

done 


