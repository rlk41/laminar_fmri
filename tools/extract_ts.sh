#!/usr/bin/env bash

#source ~/.bashrc
#conda activate openneuro
#source activate openneuro

#optargs
while getopts ":e:f:l:r:m:j:o:" flag
do
    case "${flag}" in
        e) EPI=${OPTARG};;
        f) layer_file=${OPTARG};;
        l) layers=${OPTARG};;
        r) roi_file=${OPTARG};;
        m) roi_list=${OPTARG};;
        j) jobs=${OPTARG};;
        o) out=${OPTARG};;
        c) cmd_out=${OPTARG};;
    esac
done

echo $EPI
echo $layer_file
echo $layers
echo $roi_file

echo $roi_list
echo $jobs
echo $out
echo $cmd_out

#####################################
# EXAMPLE CALL TO RUN THIS FILE
###################################
# extract_ts.sh -e $EPI_scaled -r $warp_hcp_scaled -l $warp_leakylayers10_scaled \
#  -u $LUT_hcp -j 20 -o  $ROIs_hcpl10_scaled_ts -c $ROIs_hcpl10_scaled_ts_cmds




# this will build the extraction cmds
extract_ts.py --build_cmds --epi_file $EPI --layers_file $layer_file --parc_file $roi_file \
         --LUT_file $roi_list --save_path $out --layers $layers --cmd_path $cmd_out

# this will execute the cmds jobs=20
parallel --jobs $jobs < $cmd_out


