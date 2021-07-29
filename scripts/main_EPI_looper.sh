#!/bin/bash

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"


# set required paths!
looper=true


EPIs=(${VASO_func_dir}/*VASO.nii)

# just printing the list of EPIs to run over
echo "Looping main_EPI.sh over:  "
for EPI in ${EPIs[@]};
 do

   source ../paths

   echo "                     $(basename ${EPI})";
 done


# runnign main_EPI.sh with EPI variable set
for EPI in ${EPIs[@]}; do
    echo 'Running main_EPI.sh on '${EPI};
    ./main_EPI.sh ${EPI}
done
