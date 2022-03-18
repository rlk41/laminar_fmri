#!/bin/bash

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"


# set required paths!


EPIs=(${VASO_func_dir}/*VASO.nii)
for EPI in ${EPIs[@]}; do
    echo 'Running main_EPI.sh on '${EPI};
    ./main_EPI.sh ${EPI}
done
