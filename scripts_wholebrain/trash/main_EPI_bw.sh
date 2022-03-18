#!/bin/bash

# to run single:
#     main_EPI.sh "/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/derivatives/sub-01/VASO_func/sub-01_ses-06_task-movie_run-05_VASO.nii"
# to loop:
#     main_EPI_looper.sh


parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"




export EPI=$1

# set required paths!
source ../paths


# RUNNING BIAS CORRECTION ON EPI output EPI_bias
# REQUIRES:  EPI (original), spm_path, tools_dir added to PATH
echo "Running spm_bias_field_correction on ${EPI}"
spm_bias_field_correct -i ${EPI};

# THIS SHOUDL ALREADY BE COMPLETED in main_ANAT.sh
# RUNNING BIAS CORECTION ON ANAT output is ANAT_bias
#echo "Running spm_bias_field_correction on ${ANAT}"
#spm_bias_field_correct -i ${ANAT};


#freeview ${ANAT_bias} ${EPI_bias}


mkdir ${ANTs_dir}

#itksnap -g ${EPI_bias} -o ${ANAT_bias}  --scale 1

# READ THIS: https://layerfmri.com/2017/11/26/getting-layers-in-epi-space/
# right click small images -> click "display as overlay"
# right click layer -> "auto-adjust contrast"
# tools > registration -> manual (click between using "w" key, and adjust)
# once you have good fit go to automatic tab use params:
#     Affine, Mutual Information, check "use segmentation as mask" coarse 4x, finest 2x
# might want to save the manually adjusted xfm before applying automatic.
# save in ...working_ANTs as initial_matrix.txt
# if the automatic looks good, save as "initial_matrix.txt" (overwrite the backup)


echo "RUNNING: run_ANTS this will calculate the xfm from ANAT to EPI_mean and"
echo "and apply the xfm producing warped_MP2RAGE.nii"
echo "'warp_ANTS_resampleNN.sh <input_nii> <master_file>' will "
echo "apply this xfm using nearestneighbor so only use with parcs"

echo ${EPI_bias}
echo ${ANAT_bias}
# REQUIRES: initial_matrix.txt (in working_ANTs), EPI_bias, ANAT_bias
# todo: i need to include initial_matrix.txt in git
run_ANTs -e ${EPI_bias} -a ${ANAT_bias}






# transform the ANAT file to current EPI space
############################################################
###############################################################
# COPYING THE ATLASES, ASEG, APARC INTO SESSION SPECIFIC LAYER FOLDER FOR WARPING TO SESSION EPI SPACE
cp -r $layer_dir $layer4EPI
cd $layer4EPI

cp $hcp_atlas .
cp "$recon_dir/mri/ThalamicNuclei.v12.T1.mgz" .




# TODO: !!!
# FOR EACH SESSION WE WANT TO TRANSFORM THE ANATOMICAL PARECELATIONS/LAYERS/ATLASES TO EPI SESSION SPACE

# LAYERS 3
warp_ANTS_resampleNN.sh $leaky_layers_n3 $EPI_bias

# RIM
warp_ANTS_resampleNN.sh $rim $EPI_bias

# columns_ev_1000
warp_ANTS_resampleNN.sh $columns_ev_1000 $EPI_bias

# columns_ev_10000
warp_ANTS_resampleNN.sh $columns_ev_10000 $EPI_bias


#todo: the columns are a lot thinner fix

# THALAMIC NUCLEI
warp_ANTS_resampleNN.sh "$layer4EPI/ThalamicNuclei.v12.T1.mgz" $EPI_bias



#freeview warped_leaky_layers_n3.nii $EPI_bias $ANAT_warped warped_ThalamicNuclei.v12.T1.nii warped_hcp-mmp-b.nii
# creating EPI_scaled_mean for comparison to scaled_columns, scaled_layers, scaled_hcp
#3dTstat -nzmean -prefix $EPI_scaled_mean $EPI_scaled


#todo: unpack_parc.sh - extract single ROIs from the parc files then find the intersections create_intersecting_rois.sh
# build ROIs - no layer interseciton for thalamic

unpack_parc.sh -r $warp_parc_thalamic -m $LUT_thalamic -o $rois_thalamic

unpack_parc.sh -r $warp_leakylayers3 -m $LUT_leakylayers3 -o $rois_leakylayers3


#todo: build_intersecting_rois.sh - change this to use roi files not parc file
build_layerxROIs -f $warp_leakylayers3 -l 3 -r $warp_columns -m $LUT_columns -j 60 -o $rois_c1kl3 -c $cmds_buildROIs_c1kl3

build_layerxROIs -f $warp_leakylayers3 -l 3 -r $warp_hcp -m $LUT_hcp -j 60 -o $rois_hcpl3 -c $cmds_buildROIs_hcpl3



#freeview $EPI_bias  ${ANAT_bias_dir}/c12uncorr.nii
N4BiasFieldCorrection -d 4 -i $EPI  -o $EPI_N4bias
#N4BiasFieldCorrection -d 4 -i $EPI -x ${ANAT_bias_dir}/c12uncorr.nii  -o $EPI_N4bias


#Detrend
3dDetrend -normalize -polort 1 -overwrite -prefix $EPI_detrend $EPI_N4bias
#3dDetrend -normalize -polort $pol -overwrite -prefix $EPI_detrend $EPI_N4bias

##demean
#3dTstat -prefix $EPI_detrend_mean -mean $EPI_detrend
#3dcalc -a $EPI_detrend -b $EPI_detrend_mean -expr "a-b" -prefix $EPI_detrend_demean


#freeview $EPI_detrend


# NEED TO FIX THE COLUMNS TOO THIN
extract_single_timeseries.sh -r $rois_c1kl3 -e $EPI_detrend -j 60 -o $timeseries_c1kl3 -c $cmds_extract_c1kl3

extract_single_timeseries.sh -r $rois_hcpl3 -e $EPI_detrend -j 60 -o $timeseries_hcpl3 -c $cmds_extract_hcpl3

extract_single_timeseries.sh -r $rois_thalamic -e $EPI_detrend -j 60 -o $timeseries_thalamic -c $cmds_extract_thalamic

#1dplot $timeseries_hcpl3/sub-01_ses-06_task-movie_run-05_VASO.N4bias.detrend.1004.L_V2.* &
#1dplot $timeseries_hcpl3/sub-01_ses-06_task-movie_run-05_VASO.N4bias.detrend.1001.L_V1.* &

###############################################
# todo: cortical ribbon smoothing
###############################################






###############################################
# BUILDING MATRICES -- TWO APPROACHES
###############################################
# BASH
build_matrix.sh -t $timeseries_hcpl3 -t $timeseries_thalamic -o $matrix_hcpl3_thalamic

# PYTHON
conda activate openneuro
$tools_dir/build_dataframe.py --paths $timeseries_hcpl3 $timeseries_thalamic --type 'none' --savedir $dataframe_hcpl3_thalamic_preprocd

