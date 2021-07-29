"""
This script extracts timeseries data using the upscaled VASO data, warped_upscaled_hcp_parc, and warped_upscaled_leakylayers_10 files.
Builds the dataframe

"""

source ../paths

rm $ROIs_hcpl10_scaled_ts_cmds

#  freeview $EPI_scaled_mean $warp_leakylayers10_scaled $warp_columns_ev_1000_scaled $warp_hcp_scaled

# todo: this isn't quite working... optargs
${tools_dir}/extract_ts.sh -e $EPI_scaled -r $warp_hcp_scaled -l 10 -f $warp_leakylayers10_scaled -u $LUT_hcp -j 20 -o  $ROIs_hcpl10_scaled_ts -c $ROIs_hcpl10_scaled_ts_cmds

${tools_dir}/build_dataframe.py --path $ROIs_hcpl10_scaled_ts --type 'mean' --savedir $ROIs_hcpl10_scaled_df



python $tools_dir/generate_fc_from_df.py --path $ROIs_hcpl10_scaled_df \
--rois L_V1 L_V2 L_V3 L_V3A L_V3B L_V3CD L_V4 L_V4t L_V6 &

python $tools_dir/generate_fc_from_df.py --path $ROIs_hcpl10_scaled_df \
--rois R_thalamus L_V1 L_V2 L_V3 L_V3A L_V3B L_V3CD L_V4 L_V4t L_V6 &

python $tools_dir/generate_fc_from_df.py --path $ROIs_hcpl10_scaled_df \
--rois L_MT L_V1 &

python $tools_dir/generate_fc_from_df.py --path $ROIs_hcpl10_scaled_df \
--rois R_thalamus L_MT L_V1 &

python $tools_dir/generate_fc_from_df.py --path $ROIs_hcpl10_scaled_df \
--rois L_4 L_3b L_3a L_1 L_2 &

python $tools_dir/generate_fc_from_df.py --path $ROIs_hcpl10_scaled_df \
--rois L_4 L_3b L_1 &

python $tools_dir/generate_fc_from_df.py --path $ROIs_hcpl10_scaled_df \
--rois L_33pr	L_p24pr L_a24pr L_p24 L_a24 L_p32pr L_a32pr L_d32 L_p32 L_s32 L_8BM L_9m L_10v L_10r L_25 &

python $tools_dir/generate_fc_from_df.py --path $ROIs_hcpl10_scaled_df \
--rois L_TGd L_TGv L_TE2a L_TE2p L_TE1a L_TE1m L_STSvp L_STSdp L_STSva L_STSda L_STGa L_TF &

python $tools_dir/generate_fc_from_df.py --path $ROIs_hcpl10_scaled_df \
--rois R_thalamus L_V1 L_V2 L_V3 L_V3A L_V3B L_V3CD L_V4 L_V4t L_V6 &

