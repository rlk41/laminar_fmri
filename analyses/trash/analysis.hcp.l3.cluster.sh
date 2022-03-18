
source ../paths
# run main_ANAT.sh
# run main_EPI.sh - this should generate dataframe so
# $layer4EPI/dataframe.hcpl3_thalamic.preprocd should already exist

#hierarchical clustering - dissimilarity matrices
python $tools_dir/build_hierarchical_agglomerative_cluster.py --path $layer4EPI/dataframe.hcpl3_thalamic.preprocd \
--rois L_Thalamus L_V1 L_V2 L_V3 L_V3A L_V3B L_V3CD L_V4 L_V4t L_V6






#
## build rois
#build_layerxROIs -f $warp_leakylayers3 -l 3 -r $warp_columns_ev_1000 -m $LUT_columns -j 60 -o $rois_c1kl3 -c $cmds_buildROIs_c1kl3
#
##extract_columns
#extract_layerxROI_ts -r $rois_c1kl3 -e $EPI -j 60 -o $timeseries_c1k_l3 -c $cmds_extract_c1kl3
#
## build dataframe
#${tools_dir}/build_dataframe.py --path $timeseries_c1k_l3 --type 'mean' --savedir $dataframe_c1kl3_mean
#
##${tools_dir}/build_dataframe.py --path $timeseries_c1k_l3 --type 'cosine' --savedir $dataframe_c1kl3_cosine
#
## build column dissimilarity matrices
#for roi in $rois_c1kl3/*; do
#  roi=$(basename $roi .nii | cut -d. -f1 )
#  # quick method
#  python $tools_dir/generate_fc_from_df.py --quick --path  $dataframe_c1kl3_mean --rois $roi  --plot True &
#  #python $tools_dir/generate_fc_from_df.py --path  $dataframe_c1kl3_mean --rois $roi  --plot True &
#
#done



#insert_correlation matrices back into colume



#mri_vol2surf to visualize



