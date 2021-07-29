#!/bin/bash

while getopts ":r:e:m:j:o:c:" flag
do
    case "${flag}" in
        r) roi_dir=${OPTARG};;
        e) EPI=${OPTARG};;
        j) jobs=${OPTARG};;
        o) out=${OPTARG};;
        c) cmds=${OPTARG};;
    esac
done


# extract_layerxROI_ts -r $ROIs_columns -e $EPI -j 60 -o -c

# out
# roi_dir
# EPI
# cmds_file
# jobs

#cmds="./cmds.extract_ts.$(basename $roi_dir).$(basename $EPI .nii).txt"

#extracted_ts="${roi_dir}_ts"
echo "cmds: $cmds"

rm $cmds
touch $cmds

rm -rf $out
mkdir $out

EPI_base=$(basename $EPI .nii)

for roi in $roi_dir/*; do
  ROI_base=$(basename $roi .nii)
  o=$out/${EPI_base}.${ROI_base}.1D
  #cmd="3dmaskdump -mask $roi -noijk -o $o $EPI"
  #cmd="fslmeants -i $EPI -m $roi -o $o"
  cmd="3dmaskave -quiet -mask $roi $EPI > $o"
  echo $cmd
  echo $cmd >> $cmds
done

parallel --jobs 50 < $cmds
