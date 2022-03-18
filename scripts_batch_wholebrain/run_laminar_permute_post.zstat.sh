#!/bin/bash 

set -e 


print_usage() {
  printf "Usage: ...  run_laminar_permute_post.sh -d /data/kleinrl/Wholebrain2.0/fsl_feat_permute_1010.lh_FEF"
}

while getopts 'd:' flag; do
  case "${flag}" in
    d) out_dir="${OPTARG}" ;;
    *) print_usage
       exit 1 ;;
  esac
done


echo "out_dir: $out_dir"


cd $out_dir 



echo "PCA means"
for d in $out_dir/DAY*; do 

  echo $d

  if [ -d $d/mean ]; then
    rm -rf $d/mean
  fi


  mkdir -p $d/mean 

  zstats=($(find $d -name "thresh_zstat1.nii.gz"))
  if [ "${#zstats[@]}" -eq "0" ]; then 
    echo "# == 0 - not enough to average"

  elif [ "${#zstats[@]}" -eq "1" ]; then   
    echo "# == 1 - not enough to average"
    cp ${zstats[0]} $d/mean/thresh_zstat1.mean.nii.gz

  else 
    echo "# == ${#zstats[@]} - averaging"
    3dMean -prefix $d/mean/thresh_zstat1.mean.nii.gz ${zstats[@]} -overwrite 
  fi 



  mean_funcs=($(find $d -name "mean_func.nii.gz"))
  if [ "${#mean_funcs[@]}" -eq "0" ]; then 
    echo "# == 0 - not enough to average"

  elif [ "${#mean_funcs[@]}" -eq "1" ]; then   
    echo "# == 1 - not enough to average"
    cp ${mean_funcs[0]} $d/mean/mean_func.mean.nii.gz

  else 
    echo "# == ${#mean_funcs[@]} - averaging"
    3dMean -prefix $d/mean/mean_func.mean.nii.gz ${mean_funcs[@]} -overwrite 
  fi 


done 


echo "Averaged Mean"
# AVERAGED PER ROI 
cd $out_dir


if [ -d $d/mean ]; then 
  rm -rf $d/mean
fi 

mkdir -p $out_dir/mean 



zstats=($(find $out_dir -name "thresh_zstat1.mean.nii.gz"))
if [ "${#zstats[@]}" -eq "0" ]; then 
  echo "# == 0 - not enough to average"

elif [ "${#zstats[@]}" -eq "1" ]; then   
  echo "# == 1 - not enough to average"
  cp ${zstats[0]} $out_dir/mean/thresh_zstat1.nii.gz

else 
  echo "# == ${#zstats[@]} - averaging"
  3dMean -prefix $out_dir/mean/thresh_zstat1.nii.gz ${zstats[@]} -overwrite 
fi 



mean_funcs=($(find $out_dir -name "mean_func.mean.nii.gz"))
if [ "${#mean_funcs[@]}" -eq "0" ]; then 
  echo "# == 0 - not enough to average"

elif [ "${#mean_funcs[@]}" -eq "1" ]; then   
  echo "# == 1 - not enough to average"
  cp ${mean_funcs[0]} $out_dir/mean/mean_func.nii.gz

else 
  echo "# == ${#mean_funcs[@]} - averaging"
  3dMean -prefix $out_dir/mean/mean_func.nii.gz ${mean_funcs[@]} -overwrite 
fi 



# average PCAs 

# pca_list=()
# for pca in $(ls *pca_*); do
#   pca()

# find . -name *pca_000/mean/thresh_zstat1.mean.nii.gz 


cd $out_dir/mean 

export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1


layer_dir="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/"
layers="${layer_dir}/grow_leaky_loituma/equi_volume_layers_n10.nii"



warp_ANTS_resampleCu_inverse.sh thresh_zstat1.nii.gz $layers

warp_ANTS_resampleCu_inverse.sh mean_func.nii.gz $layers



echo "DONE"



# zstats=($(find $out_dir  -name "thresh_zstat1.mean.nii.gz" ))
# if [ "${#zstats[@]}" -gt "2" ]; then 
#   3dMean -prefix $out_dir/mean/thresh_zstat1.nii.gz ${zstats[@]} -overwrite 
# else 
#   echo "NOT ENOUGH TO AVERAGE "
#   echo "copying the single to $out_dir/mean"
#   echo "but should look into this "

#   cp ${zstats[0]} $out_dir/mean/thresh_zstat1.nii.gz

# fi 

# mean_funcs=($(find $out_dir  -name "mean_func.mean.nii.gz" ))
# if [ "${#mean_funcs[@]}" -gt "2" ]; then 
#   3dMean -prefix $out_dir/mean/mean_func.nii.gz ${mean_funcs[@]} -overwrite 
# else 
#   echo "NOT ENOUGH TO AVERAGE "
#   echo "copying the single to $out_dir/mean"
#   echo "but should look into this "

#   cp ${mean_funcs[0]} $out_dir/mean/mean_func.nii.gz

# fi 





# echo "submitting L2D"

# s=( 1 3 4 5 7 10 )
# dir="$out_dir/mean"
# mkdir $dir/logs

# for smoothing in ${s[@]};do 
#   echo $dir $smoothing
#   sbatch --mem=20g --cpus-per-task=5 \
#       --job-name=L2D \
#       --output=$dir/logs/L2D_fwhm$smoothing.log \
#       --time 3-0 \
#       L2D.job.sh $dir $smoothing
# done 
