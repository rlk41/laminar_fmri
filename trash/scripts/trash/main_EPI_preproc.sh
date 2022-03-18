#!/bin/bash

#fmriprep

#export FMRIPREP_DIR
#export space_variant
#export subject
#export SCAN_ID

#sh carpetCleaner.sh

##########################

# not fmriprep'ed yet use DiCER_lightweight.sh

#sh DiCER_lightweight.sh -i $func -a $T1w -w $pathToFiles -s SUBJECT_1 -d

# tissueSeg is a nifti which has the labels, 1=CSF,2=GM,3=WM,4=Restricted GM i.e.,
# Grey matter that is either eroded or just a subset of GM. The last label, 4,
# is the label that DiCER samples off to peform the correction.

# fMRIprep (for v.1.4 onwards - tissue ordering is wrong, take care, will NOT work out of the box!)

#sh DiCER_lightweight.sh -i $func -t $tissueSeg -w $pathToFiles -s SUBJECT_1 -d

#
## sh DiCER_lightweight.sh -i $func -t $tissueSeg -w $pathToFiles -s SUBJECT_1 -d -m movFile.txt
#export FMRIPREP_DIR
#export space_variant
#export subject
#export SCAN_ID
#
#sh DiCER_lightweight.sh -i $EPI -t $tissueSeg -w $carpet_dir -s SUBJECT_1 -d -m movFile.txt


#freeview $EPI_bias  ${ANAT_bias_dir}/c12uncorr.nii
N4BiasFieldCorrection -d 4 -i $EPI  -o $EPI_N4bias
#N4BiasFieldCorrection -d 4 -i $EPI -x ${ANAT_bias_dir}/c12uncorr.nii  -o $EPI_N4bias


#Detrend
3dDetrend -normalize -polort 4 -overwrite -prefix $EPI_detrend $EPI_N4bias

##demean
#3dTstat -prefix $EPI_detrend_mean -mean $EPI_detrend
#3dcalc -a $EPI_detrend -b $EPI_detrend_mean -expr "a-b" -prefix $EPI_detrend_demean


#freeview $EPI_detrend

#fslmeants
${tools_dir}/extract_single_timeseries.sh -r $rois_hcpl3 -e $EPI_detrend -j 60 -o $timeseries_hcpl3 -c $cmds_extract_hcpl3

#join into matrix
#
#sort matrix
#feed into parital correlations/correlations
#
#
