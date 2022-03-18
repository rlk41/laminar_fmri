#!/bin/bash 
set -e 


for EPI in $VASO_func_dir/*VASO.nii
do 
    echo $EPI 
    source /home/kleinrl/projects/laminar_fmri/paths_biowulf 
    log=$logs/buildROIs-${EPI_base}.log

    echo "  "
    echo "EPI: ${EPI}"
    echo "  "
    echo "LOG: ${log}"
    echo "  "

    sbatch --mem=20g --cpus-per-task=10 \
    --partition=norm \
    --mail-type=BEGIN,TIME_LIMIT_90,END \
    --output=$log \
    --time 10:00:00 \
    /home/kleinrl/projects/laminar_fmri/scripts_batch/build_roi.submitjobs.sh $EPI 


    #/home/kleinrl/projects/laminar_fmri/tools/ANTs_job.sh

done 