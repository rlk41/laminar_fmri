#!/bin/bash 

set -e 


EPI=$1 
echo "GSR.job $EPI"

source /home/kleinrl/projects/laminar_fmri/paths_biowulf

if [ ! -f $EPI_gsr ]; then
    echo "running GSR"
    global_signal_regression.py --mask $warp_brain_bin --epi $EPI --prefix $EPI_gsr
else
    echo " EPI_gsr already exists!! not running"
fi

if [ ! -f $scaled_EPI_gsr ]; then
    echo "resmapline GSR "
    resample_4x.sh $EPI_gsr
else
    echo "scaled_EPI_gsr already exists! not resampling "
fi


3dinfo $scaled_EPI_gsr

echo "DONE"