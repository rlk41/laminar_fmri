
#export tools_dir="/home/richard/Projects/bandettini/tools"
#export PATH="${tools_dir}:$PATH"
#export spm_path='/home/richard/matlab_toolbox'
#
#
#export ANAT_base="sub-01_ses-01_run-01_T1w"
#export ANAT="${ds_dir}/sub-01/ses-01/anat/${ANAT_base}.nii"
#export ANAT_bias="${ds_dir}/sub-01/ses-01/anat/${ANAT_base}.bias.nii"
#
#export ds_dir='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download'
#export VASO_func_dir="${ds_dir}/derivatives/sub-01/VASO_func"


source ../paths

EPIs=(${VASO_func_dir}/*VASO.nii)

for EPI in ${EPIs[@]}; do
    echo 'Running spm_bias_field_correction on '${EPI};
    spm_bias_field_correct -i ${EPI};
done

for EPI in ${EPIs[@]}; do
  EPI_base="${VASO_func_dir}/$(basename ${EPI} .nii)"
  EPI_bias="${EPI_base}_working_bias/muncorr.nii" # need to change this to 'export EPI_bias="${EPI_base}.bias.nii" '
  ANTs_dir="${EPI_base}_working_ANTs"
  init_mat="${ANTs_dir}/initial_matrix.txt"
  echo "************"
  echo "ANAT_bias:      ${ANAT_bias}"
  echo "EPI_bias:       ${EPI_bias}"
  echo "ANTs_dir:       ${ANTs_dir}"
  echo "init_mat:       ${init_mat}"

  if [ ! -f "$init_mat" ]; then
    echo "doesn't exist: $init_mat"
    mkdir ${ANTs_dir}
    export QT_AUTO_SCREEN_SCALE_FACTOR=0
    itksnap --scale 1 -g ${EPI_bias} -o ${ANAT_bias}
  else
    echo "exists: $init_mat"
  fi



done

