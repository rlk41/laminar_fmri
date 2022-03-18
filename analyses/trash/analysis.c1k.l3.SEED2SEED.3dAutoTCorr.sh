


#${tools_dir}/build_graph.py --df $ROIs_columns_df


# 3dAutoTcorrelate
OMP_NUM_THREADS=40


rm -rf $corrs_3dAutoT_hcpl3 && mkdir $corrs_3dAutoT_hcpl3



rois=(

"$rois_hcpl3/2001.R_V1.1.nii"
"$rois_hcpl3/2001.R_V1.2.nii"
"$rois_hcpl3/2001.R_V1.3.nii"

"$rois_hcpl3/2023.R_MT.1.nii"
"$rois_hcpl3/2023.R_MT.2.nii"
"$rois_hcpl3/2023.R_MT.3.nii"

"$rois_thalamic/8209.Right-LGN.nii"

)

rm $cmds_3dAutoT_hcpl3 && touch $cmds_3dAutoT_hcpl3
rm $cmds_3dAutoT_hcpl3_mean && touch $cmds_3dAutoT_hcpl3_mean



for epi in ${VASO_func_dir}/${EPI_base}.N4bias.detrend.pol*.nii
do
  for roi in ${rois[@]}
    do
      base_name=$(basename $roi .nii)
      epi_base=$(basename $epi .nii)
      for layer in $rois_leakylayers3/*.nii
      do
        layer_base=$(basename $layer .nii)

        echo "$base_name $epi_base $layer_base"
        echo "3dAutoTcorrelate -mask_source $layer -mask $roi -prefix '${corrs_3dAutoT_hcpl3}/${base_name}.${layer_base}.${epi_base}.3dAutoT.nii' $epi -mmap" >> $cmds_3dAutoT_hcpl3
        echo "3dTstat -prefix '${corrs_3dAutoT_hcpl3}/${base_name}.${layer_base}.${epi_base}.3dAutoT.max.nii' -max '${corrs_3dAutoT_hcpl3}/${base_name}.${layer_base}.${epi_base}.3dAutoT.nii' " >> $cmds_3dAutoT_hcpl3_mean
        echo "3dTstat -prefix '${corrs_3dAutoT_hcpl3}/${base_name}.${layer_base}.${epi_base}.3dAutoT.mean.nii' -mean '${corrs_3dAutoT_hcpl3}/${base_name}.${layer_base}.${epi_base}.3dAutoT.nii' " >> $cmds_3dAutoT_hcpl3_mean

      done
    done
done

wc $cmds_3dAutoT_hcpl3

parallel --jobs 3 < $cmds_3dAutoT_hcpl3

parallel --jobs 10 < $cmds_3dAutoT_hcpl3_mean




#for pol in $(seq 0 4)
#do
#  for roi in ${rois[@]}
#    do
#      base_name=$(basename $roi .nii)
#      epi_base=$(basename $EPI_detrend .nii)
#      for layer in $rois_leakylayers3/*.nii
#      do
#        layer_base=$(basename $layer .nii)
#        #filename=
#        echo "$base_name $layer_base"
#        echo "3dAutoTcorrelate -mask_source $layer -mask $roi -polort $pol -prefix '${corrs_3dAutoT_hcpl3}/${base_name}.${layer_base}.pol${pol}.${epi_base}.3dAutoT.nii' $EPI_N4bias -mmap" >> $cmds_3dAutoT_hcpl3
#        echo "3dTstat -prefix '${corrs_3dAutoT_hcpl3}/${base_name}.${layer_base}.${pol}.${epi_base}.3dAutoT.max.nii' -max '${corrs_3dAutoT_hcpl3}/${base_name}.${layer_base}.pol${pol}.${epi_base}.3dAutoT.nii' " >> $cmds_3dAutoT_hcpl3_mean
#        echo "3dTstat -prefix '${corrs_3dAutoT_hcpl3}/${base_name}.${layer_base}.${pol}.${epi_base}.3dAutoT.mean.nii' -mean '${corrs_3dAutoT_hcpl3}/${base_name}.${layer_base}.pol${pol}.${epi_base}.3dAutoT.nii' " >> $cmds_3dAutoT_hcpl3_mean
#
#      done
#    done
#done


3dTcorrMap -input $EPI_N4bias -polort $pol -Mean ${corrs_3dAutoT_hcpl3}/${base_name}.${layer_base}.${pol}.${epi_base}.3dTcorrMap.nii







rois=(
"$rois_hcpl3/2051.R_1.1.nii"
"$rois_hcpl3/2051.R_1.2.nii"
"$rois_hcpl3/2051.R_1.3.nii"

"$rois_hcpl3/1051.L_1.1.nii"
"$rois_hcpl3/1051.L_1.2.nii"
"$rois_hcpl3/1051.L_1.3.nii"

"$rois_hcpl3/1009.L_3b.1.nii"
"$rois_hcpl3/1009.L_3b.2.nii"
"$rois_hcpl3/1009.L_3b.3.nii"

"$rois_hcpl3/2009.R_3b.1.nii"
"$rois_hcpl3/2009.R_3b.2.nii"
"$rois_hcpl3/2009.R_3b.3.nii"

"$rois_hcpl3/1008.L_4.1.nii"
"$rois_hcpl3/1008.L_4.2.nii"
"$rois_hcpl3/1008.L_4.3.nii"

"$rois_hcpl3/2008.R_4.1.nii"
"$rois_hcpl3/2008.R_4.2.nii"
"$rois_hcpl3/2008.R_4.3.nii"
)



rm  $cmds_3dAutoT_hcpl3_mean& touch  $cmds_3dAutoT_hcpl3_mean

for f in $corrs_3dAutoT_hcpl3/*
do
  base_name=$(basename $f .nii)
  dir_name=$(dirname $f)
  out="${dir_name}/${base_name}.mean.nii"
  echo "out: $out"

  echo "3dTstat -mean -prefix $out $f" >> $cmds_3dAutoT_hcpl3_mean

done

parallel --jobs 5 <  $cmds_3dAutoT_hcpl3_mean


################################################

#freeview $EPI_bias $warp_columns_ev_1000 $warp_leakylayers3

#freeview $ANAT $columns_ev_1000 $leakylayers3  -f ../surf/lh.pial -f ../surf/lh.white -f ../surf/rh.pial -f ../surf/rh.white

