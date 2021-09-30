#!/bin/bash

while getopts ":f:l:r:m:j:o:c:" flag
do
    case "${flag}" in
        r) roi_file=${OPTARG};;
        m) roi_list=${OPTARG};;
        o) out=${OPTARG};;
    esac
done

# USAGE: unpack_parc.sh -r $warp_parc_thalamic -m $LUT_thalamic -o $rois_thalamic

rm -rf $out
mkdir -p $out

echo "roi_file: $roi_file"
echo "roi_list: $roi_list"
echo "out: $out"
#todo: use unq.sh to get all uniquw values in parc file. This instead of
#reading from LUT. But 3dhistog doesn't get the last unq value if not
#consequtive

cmds=$cmds_dir/$(basename $roi_file .nii).cmds
jobs=10


while IFS= read -r line
do
  line=($line)
    ID=${line[0]};
    ROI_name=${line[1]}
    echo "ROI: $roi ID: $ID "
    3dcalc -a ${roi_file} -expr "equals(a,$ID)" -prefix $out/$ID.$ROI_name.nii 
    #echo "3dcalc -a ${roi_file} -expr "'"equals(a,'"$ID"')"'" -prefix $out/$ID.$ROI_name.nii" >> $cmds

done < $roi_list

#parallel --jobs ${jobs} < $cmds


