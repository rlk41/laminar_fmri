#!/bin/bash 

for epi in $VASO_func_dir/*.nii; do 
sbatch 

in='sub-01_ses-02_task-movie_run-01_VASO.nii'
out="$(basename $in .nii).pc.nii"
3dpc -prefix $out -vmean -vnorm -reduce 10 $in 

3dpc -prefix $out -vmean -vnorm $in 

3dpc -prefix sub-01_ses-02_task-movie_run-01_VASO.pc.nii \
-vmean -vnorm sub-01_ses-02_task-movie_run-01_VASO.nii 