#!/bin/bash 
set -e 


EPI=$1
source /home/kleinrl/projects/laminar_fmri/paths_biowulf 



function check_if_file_exists () {
    if [ -e "$1" ]; then
        echo "exists"
    else 
        echo "DOES NOT EXIST" 
        echo "      $(basename $1 )"

    fi 
}



# resample all VASO runs 
#resampleEPI.submitjobs 
#resampleEPI.job



echo "main_EPI_upsample.job: $EPI"

if [ ! -f $scaled_EPI ]; then
    echo "scaled_EPI doesn't exist "
    resample_EPI.sh 
fi

if [ ! -f $scaled_EPI_mean ]; then
    echo "scaled_EPI_mean doesn't exist "
    3dTstat -mean -prefix $scaled_EPI_mean $scaled_EPI
fi

if [ ! -f $scaled_EPI_gsr ]; then
    echo "scaled_EPI_gsr doesn't exist "
    resample_4x.sh $EPI_gsr
    
fi

if [ ! -f $scaled_EPI_gsr_mean ]; then
    echo "scaled_EPI_gsr_mean doesn't exist "

    3dTstat -mean -prefix $scaled_EPI_gsr_mean $scaled_EPI_gsr

fi


3dinfo $scaled_EPI_gsr

# if [ ! -f $scaled_EPI_mean ]; then

#     echo "regressing out global signal"
    
#     cd $VASO_func_dir

#     3dmaskave -mask $warp_scaled_brain_bin $scaled_EPI > $global_signal_1D

#     3dDeconvolve -input $scaled_EPI 

# fi




echo "applying tranforms"
# scaled 
cd $layer4EPI 

antsApplyTransforms -d 3 -i $layers_ed_n10      -o $warp_scaled_layers_ed_n10   \
-r $scaled_EPI_mean -t $ANTs_reg_1warp -t $ANTs_reg_0GenAffine  \
-n NearestNeighbor || fail "fail on ANTs layers_ed "

antsApplyTransforms -d 3 -i $columns_ev_10000   -o $warp_scaled_columns_ev_10000 \
-r $scaled_EPI_mean -t $ANTs_reg_1warp -t $ANTs_reg_0GenAffine  \
-n NearestNeighbor || fail "fail on ANTS col ev 10000"

antsApplyTransforms -d 3 -i $columns_ev_10000_borders -o $warp_scaled_columns_ev_10000_borders \
-r $scaled_EPI_mean -t $ANTs_reg_1warp -t $ANTs_reg_0GenAffine  \
-n NearestNeighbor || fail "fail on ANTS col ev 10000 borders"

antsApplyTransforms -d 3 -i $parc_hcp -o $warp_scaled_parc_hcp \
-r $scaled_EPI_mean -t $ANTs_reg_1warp -t $ANTs_reg_0GenAffine  \
-n NearestNeighbor || fail "fail on ANTS  parc hcp "

antsApplyTransforms -d 3 -i $parc_thalamic      -o $warp_scaled_parc_thalamic \
-r $scaled_EPI_mean -t $ANTs_reg_1warp -t $ANTs_reg_0GenAffine  \
-n NearestNeighbor || fail "fail on ANTS thalamic"

antsApplyTransforms -d 3 -i $rim   -o $warp_scaled_rim -r $scaled_EPI_mean \
-t $ANTs_reg_1warp -t $ANTs_reg_0GenAffine  \
-n NearestNeighbor || fail "fail on ANTS rim"


antsApplyTransforms -d 3 -i $seg_brain   -o $warp_scaled_brain -r $scaled_EPI_mean \
-t $ANTs_reg_1warp -t $ANTs_reg_0GenAffine  \
-n NearestNeighbor || fail "fail on ANTS rim"

3dcalc -a $warp_scaled_brain -expr 'ispositive(a-1)' -prefix $warp_scaled_brain_bin -overwrite 


# for EPI in $VASO_func_dir/*movie*VASO.nii
# do 
#     echo $EPI 
#     source /home/kleinrl/projects/laminar_fmri/paths_biowulf 
#     cd $layer4EPI
#     echo "PWD: $(pwd)"
#     echo "brain: $seg_brain"
#     echo "EPI_bias: $EPI_bias"

#     antsApplyTransforms -d 3 -i $seg_brain   -o $warp_scaled_brain -r $scaled_EPI_mean \
#     -t $ANTs_reg_1warp -t $ANTs_reg_0GenAffine  \
#     -n NearestNeighbor || fail "fail on ANTS rim"

#     3dcalc -a $warp_scaled_brain -expr 'ispositive(a-1)' -prefix $warp_scaled_brain_bin -overwrite 

# done 






# freeview $scaled_EPI_mean $warp_scaled_layers_ed_n10 $warp_scaled_columns_ev_10000 $warp_scaled_parc_hcp $warp_scaled_parc_thalamic 



unpack_parc.sh -r $warp_scaled_parc_thalamic \
    -m $LUT_thalamic -o $rois_scaled_thalamic || fail "fail on unpack parc_thalmic "

unpack_parc.sh -r $warp_scaled_parc_hcp \
    -m $LUT_hcp -o $rois_scaled_hcp || fail "fail on unpack parc_hcp"


# TODO change "leaklayers" naming not accurate 

#unpack_parc.sh -r $warp_scaled_layers_ev_n3 \
#    -m $LUT_leakylayers3 -o $rois_scaled_leakylayers3 || fail "fail on unpack layers_ev_3"

unpack_parc.sh -r $warp_scaled_layers_ed_n10 \
    -m $LUT_leakylayers10 -o $rois_scaled_layers_ed_n10 || fail "fail on layers_ev_10" 

#unpack_parc.sh -r $warp_scaled_layers_ev_n10 \
#    -m $LUT_leakylayers10 -o $rois_scaled_leakylayers10 || fail "fail on layers_ev_10" 

# unpack_parc.sh -r $warp_scaled_layers_ev_n10 \
#     -m $LUT_leakylayers10 -o $rois_scaled_leakylayers10 || fail "fail on layers_ev_10" 

# unpack_parc.sh -r $warp_scaled_layers_ev_n10 \
#     -m $LUT_leakylayers10 -o $rois_scaled_leakylayers10 || fail "fail on layers_ev_10" 



# #todo: build_intersecting_rois.sh - change this to use roi files not parc file

# build_layerxROIs.sh -f $warp_layers_ev_n3 \
#     -l 3 -r $warp_columns -m $LUT_columns \
#     -j 60 -o $rois_c1kl3 -c $cmds_buildROIs_c1kl3

# build_layerxROIs.sh -f $warp_scaled_layers_ed_n10 \
#     -l 3 -r $warp_scaled_parc_hcp -m $LUT_hcp -j 60 \
#     -o $rois_scaled_hcp_layers_ed_n10 -c $cmds_buildROIs_scaled_hcpl10





# OLD 

# warp_ANTS_resampleNN.sh $layers_ev_n3  $scaled_EPI || fail "fail on warp_ANTs ev_layers_n3"

# warp_ANTS_resampleNN.sh $layers_ev_n10  $scaled_EPI || fail "fail on warp_ANTs ev_layers_n10"

# warp_ANTS_resampleNN.sh $rim $scaled_EPI || fail "fail on warp_ANTs rim"

# warp_ANTS_resampleNN.sh $columns_ev_1000 $scaled_EPI || fail "fail on warp_ANTs columns_ev_1000"

# warp_ANTS_resampleNN.sh $columns_ev_10000 $scaled_EPI || fail "fail on warp_ANTs columns_ev_10000"

# warp_ANTS_resampleNN.sh $parc_thalamic $scaled_EPI || fail "fail on warp_ANTs parc_thalamic"

# warp_ANTS_resampleNN.sh $parc_hcp $scaled_EPI || fail "fail on warp_ANTs parc_hcp"



# unpack_parc.sh -r $warp_scaled_parc_thalamic \
#     -m $LUT_thalamic -o $rois_scaled_thalamic || fail "fail on unpack parc_thalmic "

# unpack_parc.sh -r $warp_scaled_parc_hcp \
#     -m $LUT_hcp -o $rois_scaled_hcp || fail "fail on unpack parc_hcp"


# # TODO change "leaklayers" naming not accurate 

# unpack_parc.sh -r $warp_scaled_layers_ev_n3 \
#     -m $LUT_leakylayers3 -o $rois_scaled_leakylayers3 || fail "fail on unpack layers_ev_3"

# unpack_parc.sh -r $warp_scaled_layers_ev_n10 \
#     -m $LUT_leakylayers10 -o $rois_scaled_leakylayers10 || fail "fail on layers_ev_10" 


# # #todo: build_intersecting_rois.sh - change this to use roi files not parc file

# # build_layerxROIs.sh -f $warp_layers_ev_n3 \
# #     -l 3 -r $warp_columns -m $LUT_columns \
# #     -j 60 -o $rois_c1kl3 -c $cmds_buildROIs_c1kl3

# build_layerxROIs.sh -f $warp_scaled_layers_ev_n3 \
#     -l 3 -r $warp_scaled_parc_hcp -m $LUT_hcp -j 60 \
#     -o $rois_scaled_hcpl3 -c $cmds_buildROIs_scaled_hcpl3

