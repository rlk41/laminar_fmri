#!/bin/bash 
set -e 



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



echo "resampleEPI.job: $EPI"

resample_EPI.sh 

3dTstat -mean -prefix $scaled_EPI_mean $scaled_EPI




# warping and then resampling works but then in in run-space 
# need to appply inverse then forward into toher subject spaces. 
cd $layer4EPI 
warp_ANTS_resampleNN.sh $rim $scaled_EPI || fail "fail on warp_ANTs rim"
export warp_scaled_rim="$layer4EPI/warped_rim.resample2$EPI_base.scaled.nii"


# other option might be to copy header info from 
# $ANAT to $rim then rescaling and xfm to run-space 
export rim_fixheader="$layer_dir/rim.fixheader.nii"
export rim_fixheader_scaled="$layer_dir/rim.fixheader.scaled.nii"


transfer_header_to_file.py --from_file $ANAT --to_file $rim --prefix $rim_fixheader

3dresample -master $scaled_EPI -rmode NN -overwrite -prefix $rim_fixheader_scaled  -input $rim_fixheader



cd $layer4EPI

antsApplyTransforms -d 3 -i $layers_ed_n10 -o $warp_scaled_layers_ed_n10 -r $scaled_EPI_mean -t $ANTs_reg_1warp -t $ANTs_reg_0GenAffine  -n NearestNeighbor

antsApplyTransforms -d 3 -i $columns_ev_10000  -o $warp_scaled_columns_ev_10000 -r $scaled_EPI_mean -t $ANTs_reg_1warp -t $ANTs_reg_0GenAffine  -n NearestNeighbor



# # apply inverse
# antsApplyTransforms -d 3 -i $warp_scaled_rim -o test.inverse.nii.gz -r $scaled_EPI_mean -t "$ANTs_dir/registered_1InverseWarp.nii.gz" -t [ $ANTs_reg_0GenAffine, 1]  -n NearestNeighbor

# # apply forward into sub space 
# for EPI in $VASO_func_dir/*movie*VASO.nii; do 

#     source_laminar_fmri 
#     echo 
#     antsApplyTransforms -d 3 -i $f -o $f_out -r $EPI_bias -t $ANTs_reg_1warp -t $ANTs_reg_0GenAffine  -n NearestNeighbor






# build columns 


  LN2_COLUMNS -rim $warp_scaled_rim \
   -midgm rim_midGM_${col_type}.nii \
   -nr_columns 10000

# build layers 


# apply inverse warp









#warp_ANTS_resampleNN.sh $scaled_layers_ed_n10  $scaled_EPI || fail "fail on warp_ANTs ev_layers_n3"

warp_ANTS_resampleNN.sh $layers_ed_n10  $scaled_EPI || fail "fail on warp_ANTs ed_layers_n10"


warp_ANTS_resampleNN.sh $columns_ev_1000 $scaled_EPI || fail "fail on warp_ANTs columns_ev_1000"

warp_ANTS_resampleNN.sh $columns_ev_10000 $scaled_EPI || fail "fail on warp_ANTs columns_ev_10000"

warp_ANTS_resampleNN.sh $parc_thalamic $scaled_EPI || fail "fail on warp_ANTs parc_thalamic"

warp_ANTS_resampleNN.sh $parc_hcp $scaled_EPI || fail "fail on warp_ANTs parc_hcp"



unpack_parc.sh -r $warp_scaled_parc_thalamic \
    -m $LUT_thalamic -o $rois_scaled_thalamic || fail "fail on unpack parc_thalmic "

unpack_parc.sh -r $warp_scaled_parc_hcp \
    -m $LUT_hcp -o $rois_scaled_hcp || fail "fail on unpack parc_hcp"


# TODO change "leaklayers" naming not accurate 

unpack_parc.sh -r $warp_scaled_layers_ev_n3 \
    -m $LUT_leakylayers3 -o $rois_scaled_leakylayers3 || fail "fail on unpack layers_ev_3"

unpack_parc.sh -r $warp_scaled_layers_ev_n10 \
    -m $LUT_leakylayers10 -o $rois_scaled_leakylayers10 || fail "fail on layers_ev_10" 


# #todo: build_intersecting_rois.sh - change this to use roi files not parc file

# build_layerxROIs.sh -f $warp_layers_ev_n3 \
#     -l 3 -r $warp_columns -m $LUT_columns \
#     -j 60 -o $rois_c1kl3 -c $cmds_buildROIs_c1kl3

build_layerxROIs.sh -f $warp_scaled_layers_ev_n3 \
    -l 3 -r $warp_scaled_parc_hcp -m $LUT_hcp -j 60 \
    -o $rois_scaled_hcpl3 -c $cmds_buildROIs_scaled_hcpl3





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









# upsample2scaledEPI_NN.sh $warp_layers_ev_n3              || fail "fail on upsample2scaledEPI_NN.sh ev_layers_n3"
# upsample2scaledEPI_NN.sh $warp_layers_ev_n10             || fail "fail on upsample2scaledEPI_NN.sh ev_layers_n10"
# upsample2scaledEPI_NN.sh $warp_rim                       || fail "fail on upsample2scaledEPI_NN.sh rim"
# upsample2scaledEPI_NN.sh $warp_columns_ev_1000           || fail "fail on upsample2scaledEPI_NN.sh columns_ev_1000"
# upsample2scaledEPI_NN.sh $warp_columns_ev_10000          || fail "fail on upsample2scaledEPI_NN.sh columns_ev_10000"
# upsample2scaledEPI_NN.sh $warp_parc_thalamic             || fail "fail on upsample2scaledEPI_NN.sh parc_thalamic"
# upsample2scaledEPI_NN.sh $warp_parc_hcp                  || fail "fail on upsample2scaledEPI_NN.sh parc_hcp"



# check_if_file_exists $warp_layers_ev_n3              
# check_if_file_exists $warp_layers_ev_n10           
# check_if_file_exists $warp_rim                      
# check_if_file_exists $warp_columns_ev_1000           
# check_if_file_exists $warp_columns_ev_10000         
# check_if_file_exists $warp_parc_thalamic             
# check_if_file_exists $warp_parc_hcp                 

# check_if_file_exists $warp_layers_ev_n3              
# check_if_file_exists $warp_layers_ev_n10           
# check_if_file_exists $warp_rim                      
# check_if_file_exists $warp_columns_ev_1000           
# check_if_file_exists $warp_columns_ev_10000         
# check_if_file_exists $warp_parc_thalamic             
# check_if_file_exists $warp_parc_hcp        

# check_if_file_exists $warp_scaled_parc_hcp
# check_if_file_exists $warp_scaled_parc_thalamic
# check_if_file_exists $warp_scaled_layers_ev_n10
# check_if_file_exists $warp_scaled_layers_ev_n3
# check_if_file_exists $warp_scaled_rim
# check_if_file_exists $warp_scaled_columns_ev_1000
# check_if_file_exists $warp_scaled_columns_ev_10000
