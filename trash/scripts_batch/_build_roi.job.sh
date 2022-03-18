#!/bin/bash 

EPI=$1

source /home/kleinrl/projects/laminar_fmri/paths_biowulf 



mkdir -p $layer4EPI
cd $layer4EPI

# LAYERS 3
warp_ANTS_resampleNN.sh $layers_ev_n3  $EPI_bias || fail "fail on warp_ANTs ev_layers_n3"

warp_ANTS_resampleNN.sh $layers_ev_n10  $EPI_bias || fail "fail on warp_ANTs ev_layers_n10"

# RIM
warp_ANTS_resampleNN.sh $rim $EPI_bias || fail "fail on warp_ANTs rim"


# columns_ev_1000
warp_ANTS_resampleNN.sh $columns_ev_1000 $EPI_bias || fail "fail on warp_ANTs columns_ev_1000"

# columns_ev_10000
warp_ANTS_resampleNN.sh $columns_ev_10000 $EPI_bias || fail "fail on warp_ANTs columns_ev_10000"



#todo: the columns are a lot thinner fix

# THALAMIC NUCLEI
#warp_ANTS_resampleNN.sh "$layer4EPI/ThalamicNuclei.v12.T1.mgz" $EPI_bias
warp_ANTS_resampleNN.sh $parc_thalamic $EPI_bias || fail "fail on warp_ANTs parc_thalamic"

warp_ANTS_resampleNN.sh $parc_hcp $EPI_bias || fail "fail on warp_ANTs parc_hcp"


#freeview warped_leaky_layers_n3.nii $EPI_bias $ANAT_warped warped_ThalamicNuclei.v12.T1.nii warped_hcp-mmp-b.nii
# creating EPI_scaled_mean for comparison to scaled_columns, scaled_layers, scaled_hcp
#3dTstat -nzmean -prefix $EPI_scaled_mean $EPI_scaled


# #todo: unpack_parc.sh - extract single ROIs from the parc files then find the intersections create_intersecting_rois.sh
# # build ROIs - no layer interseciton for thalamic

unpack_parc.sh -r $warp_parc_thalamic \
    -m $LUT_thalamic -o $rois_thalamic || fail "fail on unpack parc_thalmic "

unpack_parc.sh -r $warp_parc_hcp \
    -m $LUT_hcp -o $rois_hcp || fail "fail on unpack parc_hcp"


# TODO change "leaklayers" naming not accurate 

unpack_parc.sh -r $warp_layers_ev_n3 \
    -m $LUT_leakylayers3 -o $rois_leakylayers3 || fail "fail on unpack layers_ev_3"

unpack_parc.sh -r $warp_layers_ev_n10 \
    -m $LUT_leakylayers10 -o $rois_leakylayers10 || fail "fail on layers_ev_10" 


# #todo: build_intersecting_rois.sh - change this to use roi files not parc file

# build_layerxROIs.sh -f $warp_layers_ev_n3 \
#     -l 3 -r $warp_columns -m $LUT_columns \
#     -j 60 -o $rois_c1kl3 -c $cmds_buildROIs_c1kl3

build_layerxROIs.sh -f $warp_layers_ev_n3 \
    -l 3 -r $warp_parc_hcp -m $LUT_hcp -j 10 \
    -o $rois_hcpl3 -c $cmds_buildROIs_hcpl3

