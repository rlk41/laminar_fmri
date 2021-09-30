#!/bin/bash

while getopts ":f:l:r:m:j:o:c:" flag
do
    case "${flag}" in
        f) layer_file=${OPTARG};;
        l) layers=${OPTARG};;
        r) roi_file=${OPTARG};;
        m) roi_list=${OPTARG};;
        j) jobs=${OPTARG};;
        o) out=${OPTARG};;
        c) cmds=${OPTARG};;
    esac
done

# USAGE: build_layerxROIs -f $warp_leakylayers3 -l 3 -r $warp_columns -m $LUT_columns -j 60 -o $rois_c1kl3 -c $cmds_buildROIs_c1kl3

#cmds='./cmds.build_layerxROIs.txt'
#out=''
mkdir -p $(dirname $cmds)

rm $cmds
touch $cmds

rm -rf $out
mkdir -p $out

echo "layer_file: $layer_file"
echo "layers: $layers"
echo "roi_file: $roi_file"
echo "roi_list: $roi_list"
echo "jobs: $j"
echo "out: $out"


while IFS= read -r line; do
  line=($line)
  for l in $(seq $layers); do
    ID=${line[0]};
    ROI_name=${line[1]}
    echo "layer: $l ROI: $roi ID: $ID "
    echo "3dcalc -a ${layer_file} -b ${roi_file} -prefix $out/$ID.$ROI_name.$l.nii -expr 'and(equals(a,$l), equals(b,$ID))' " >> $cmds
  done
done < $roi_list

parallel --jobs ${jobs} < $cmds


