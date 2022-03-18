



filename="/data/NIMH_scratch/kleinrl/analyses/FEF/1010.L_FEF_pca10/timeseries/DAY1_run1_VASO_LN.2D"





EPIs=($(find $ds_dir/DAY*/run* -name "VASO_LN.nii"))

#for EPI in EPIs
EPI=${EPIs[0]}


pca=($(ls /data/NIMH_scratch/kleinrl/analyses/FEF/1010.L_FEF_pca10/timeseries/DAY1_run1_VASO_LN*pca*))


echo ${pca[@]}
echo ${#pca[@]}

3dTcorr









