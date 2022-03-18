#!/bin/bash

source ../paths


python $tools_dir/build_dataframe.py --path $extracted_ts --type 'mean' --savedir $layer4EPI/dataframe_hcp-l3.mean

python $tools_dir/generate_fc_from_df.py --path $layer4EPI/dataframe.hcpl3_thalamic.preprocd \
--rois R_Thalamus R_V1 R_MT --quick &



python $tools_dir/generate_fc_from_df.py --path $layer4EPI/dataframe.hcpl3_thalamic.preprocd \
--rois L_V1 L_V2 --quick  &

python $tools_dir/generate_fc_from_df.py --path $layer4EPI/dataframe.hcpl3_thalamic.preprocd \
--rois L_V1 L_V2 L_V3 L_V3A L_V3B L_V3CD L_V4 L_V4t L_V6 --quick --show &

python $tools_dir/generate_fc_from_df.py --path $layer4EPI/dataframe.hcpl3_thalamic.preprocd \
--rois L_V1 L_V2 L_V3 L_V3A L_V3B L_V3CD L_V4 L_V4t L_V6 --quick --plot True &

python $tools_dir/generate_fc_from_df.py --path $layer4EPI/dataframe.hcpl3_thalamic.preprocd \
--rois R_Thalamus L_V1 L_V2 L_V3 L_V3A L_V3B L_V3CD L_V4 L_V4t L_V6 --quick &

python $tools_dir/generate_fc_from_df.py --path $layer4EPI/dataframe.hcpl3_thalamic.preprocd \
--rois L_MT L_V1 --quick &

python $tools_dir/generate_fc_from_df.py --path $layer4EPI/dataframe.hcpl3_thalamic.preprocd \
--rois R_Thalamus L_MT L_V1 --quick &

python $tools_dir/generate_fc_from_df.py --path $layer4EPI/dataframe.hcpl3_thalamic.preprocd \
--rois L_4 L_3b L_3a L_1 L_2 --quick &

python $tools_dir/generate_fc_from_df.py --path $layer4EPI/dataframe.hcpl3_thalamic.preprocd \
--rois L_4 L_3b L_1 --quick &

python $tools_dir/generate_fc_from_df.py --path $layer4EPI/dataframe.hcpl3_thalamic.preprocd \
--rois L_33pr	L_p24pr L_a24pr L_p24 L_a24 L_p32pr L_a32pr L_d32 L_p32 L_s32 L_8BM L_9m L_10v L_10r L_25 --quick &

python $tools_dir/generate_fc_from_df.py --path $layer4EPI/dataframe.hcpl3_thalamic.preprocd \
--rois L_TGd L_TGv L_TE2a L_TE2p L_TE1a L_TE1m L_STSvp L_STSdp L_STSva L_STSda L_STGa L_TF --quick &

python $tools_dir/generate_fc_from_df.py --path $layer4EPI/dataframe.hcpl3_thalamic.preprocd \
--rois L_Thalamus L_V1 L_V2 L_V3 L_V3A L_V3B L_V3CD L_V4 L_V4t L_V6 --quick &



python $tools_dir/generate_fc_from_df.py --path /mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/bandettini_data/ts_numpy_extract_n10_dataframe \
--rois L_Thalamus L_A1 L_MBelt L_PBelt L_LBelt L_A4 L_A5 L_STSda L_STSdp L_STSva L_STSvp --quick &
