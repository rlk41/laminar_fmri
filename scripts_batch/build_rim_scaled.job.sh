#!/bin/bash 
set -e 


source /home/kleinrl/projects/laminar_fmri/paths_biowulf 
log="/home/kleinrl/projects/laminar_fmri/logs/build_rim_scaled.log"



sbatch --mem=20g --cpus-per-task=10 \
--partition=norm \
--mail-type=BEGIN,TIME_LIMIT_90,END \
--output=$log \
--time 10:00:00 \
build_rim_scaled.sh
