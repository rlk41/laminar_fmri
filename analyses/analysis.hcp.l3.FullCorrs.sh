#!/bin/bash


source ../paths

fullCorrs_hcpl3="$layer4EPI/fullCorrs_hcpl3"
mkdir $fullCorrs_hcpl3


#build_matrix.sh -t $timeseries_hcpl3 -t $timeseries_thalamic -m $matrix_hcpl3_thalamic -l $labs_hcpl3_thalamic







#
#rm final.res temp
#touch final.res
#
#for file in $timeseries_hcpl3/*.txt
#  do
#    cat final.res | paste - $file > temp
#    cp temp final.res
#  done
#
#head -n1 temp | grep -o " " | wc -l
#
#rm temp
#
#
#
#paste -d' ' sub-01_ses-06_task-movie_run-05_VASO.1001.L_V1.1.txt sub-01_ses-06_task-movie_run-05_VASO.1001.L_V1.1.txt > $matrix_hcpl3_thalamic
#cat $matrix_hcpl3_thalamic
#
#paste -d' ' $matrix_hcpl3_thalamic sub-01_ses-06_task-movie_run-05_VASO.1001.L_V1.1.txt > $matrix_hcpl3_thalamic
#cat $matrix_hcpl3_thalamic


## we need to preprocess detrend, demean, whiten
#${tools_dir}/build_dataframe.py --path $extracted_ts --type 'mean' --savedir $dataframe_hcpl3_mean
#
#
#
## rotate the matrix for the partial corrs R script
#${tools_dir}/transpose.sh  $dataframe_hcpl3_mean_matrix > $dataframe_hcpl3_mean_matrix_t
