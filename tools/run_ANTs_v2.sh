#!/bin/bash
set -e 

while getopts e:a: flag
do
    case "${flag}" in
        e) EPI=${OPTARG};;
        a) ANAT=${OPTARG};;

    esac
done

# EPI here refers to the EPI_mean file



dir_name="$(dirname ${EPI})"
base_name="$(basename ${EPI})"

#working_dir="${dir_name}/${base_name}_working"
#working_file=${working_dir}'/uncorr.nii'
curr_dir="$(pwd)"


# if ANTs_dir not set create local dir
if [ -z ${ANTs_dir+x} ]; then
    echo  "creating ANTs dir locally";
    ANTs_dir="${curr_dir}/ANTs_dir";
fi


# if ANTs_dir doesn't exist create
if [ ! -d $ANTs_dir ]; then
  mkdir $ANTs_dir;
fi



#echo "spm_dir (path file):  ${spm_dir}"
echo "EPI_mean:             ${EPI}"
echo "ANAT:                 ${ANAT}"

echo "dir_name:             ${dir_name}"
echo "base_name:            ${base_name}"
echo "working dir:          ${ANTs_dir}"

echo "creating working dir"


#copy input into working dir
cp ${EPI} "${ANTs_dir}/EPI.nii"
cp ${ANAT} "${ANTs_dir}/MP2RAGE.nii"

cd ${ANTs_dir}

# This will apply the init_matrix, but not sure we need to... I believe the antsRegistration will take the initial_matrix.txt and apply
# antsApplyTransforms --interpolation BSpline[5] -d 3 -i MP2RAGE.nii -r EPI.nii -t initial_matrix.txt -o registered_applied.nii


echo "I expect 2 files. the T1_weighted EPI.nii and a MP2RAGE_orig.nii (renzo)"
echo "we are using the T1_weighted EPI_bias corrected and MP2RAGE bias corrected"

#  bet MP2RAGE_orig.nii MP2RAGE.nii -f 0.05
3dcalc -a MP2RAGE.nii -datum short -expr 'a' -prefix MP2RAGE.nii -overwrite


#ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=20
#export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS


echo "*****************************************"
echo "************* starting with ANTS ********"
echo "*****************************************"
#2 steps
antsRegistration \
--verbose 1 \
--dimensionality 3 \
--float 0 \
--collapse-output-transforms 1  \
--output [registered_,registered_Warped.nii.gz,registered_InverseWarped.nii.gz] \
--interpolation  BSpline[5]  \
--use-histogram-matching 0 \
--winsorize-image-intensities [0.005,0.995] \
--transform Rigid[0.1]  \
--metric MI[EPI.nii,MP2RAGE.nii,1,32,Regular,0.25]  \
--convergence [1000x500x250x100,1e-6,10]  \
--shrink-factors 12x8x4x2  \
--smoothing-sigmas 4x3x2x1vox  \
--transform Affine[0.1] \
--metric MI[EPI.nii,MP2RAGE.nii,1,32,Regular,0.25]  \
--convergence [1000x500x250x100,1e-6,10]  \
--shrink-factors 12x8x4x2  \
--smoothing-sigmas 4x3x2x1vox  \
--transform SyN[0.1,3,0]  \
--metric MI[EPI.nii,MP2RAGE.nii,1,4]  \
--convergence [100x100x70x50x20,1e-6,10]  \
--shrink-factors 10x6x4x2x1  \
--smoothing-sigmas 5x3x2x1x0vox 

# #2 steps
# antsRegistration \
# --verbose 1 \
# --dimensionality 3 \
# --float 0 \ 
# --collapse-output-transforms 1  \
# --output [registered_,registered_Warped.nii.gz,registered_InverseWarped.nii.gz] \
# #--interpolation Linear \
# --interpolation  BSpline[5]  \
# --use-histogram-matching 0 \
# --winsorize-image-intensities [0.005,0.995] \
# #--initial-moving-transform [ref.nii,s1.nii,1]  \
# --transform Rigid[0.1]  \
# #--transform Rigid[0.05] \
# #--metric CC[EPI.nii,MP2RAGE.nii,0.7,32,Regular,0.1] \
# #--convergence [1000x500,1e-6,10] \
# #--shrink-factors 2x1 \
# #--smoothing-sigmas 1x0vox \
# --metric MI[EPI.nii,MP2ARGE.nii,1,32,Regular,0.25]  \
# --convergence [1000x500x250x100,1e-6,10]  \
# --shrink-factors 12x8x4x2  \
# --smoothing-sigmas 4x3x2x1vox  \
# --transform Affine[0.1] \
# #--metric MI[EPI.nii,MP2RAGE.nii,0.7,32,Regular,0.1] \
# #--convergence [1000x500,1e-6,10] \
# #--shrink-factors 2x1 \
# #--smoothing-sigmas 1x0vox \
# --metric MI[EPI.nii,MP2RAGE.nii,1,32,Regular,0.25]  \
# --convergence [1000x500x250x100,1e-6,10]  \
# --shrink-factors 12x8x4x2  \
# --smoothing-sigmas 4x3x2x1vox  \
# #--transform SyN[0.1,2,0] \
# --transform SyN[0.1,3,0]  \
# #--metric CC[EPI.nii,MP2RAGE.nii,1,2] \
# #--convergence [500x100,1e-6,10] \
# #--shrink-factors 2x1 \
# #--smoothing-sigmas 1x0vox
# --metric MI[EPI.nii,MP2RAGE.nii,1,4]  \
# --convergence [100x100x70x50x20,1e-6,10]  \
# --shrink-factors 10x6x4x2x1  \
# --smoothing-sigmas 5x3x2x1x0vox 




#antsApplyTransforms -d 3 -i MP2RAGE.nii -o warped_MP2RAGE.nii -r MP2RAGE.nii-t registered_1Warp.nii.gz -t registered_0GenericAffine.mat
antsApplyTransforms -d 3 -i MP2RAGE.nii -o warped_MP2RAGE.nii -r MP2RAGE.nii -t registered_1Warp.nii.gz -t registered_0GenericAffine.mat
3dcalc -a warped_MP2RAGE.nii -datum short -expr 'a' -prefix warped_MP2RAGE.nii -overwrite


echo "FINISHED"
echo "Files are in ${ANTs_dir}"
echo "returning to original dir"

cd ${curr_dir}
