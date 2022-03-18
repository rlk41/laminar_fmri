#!/bin/bash 

set -e 

# roi_path 
roi_path=""
# column - extract from columns 
column_id=""
# number pcas 
num_pcas=10
# outdir    
out_dir=""

EPIs=("/data/kleinrl/Wholebrain2.0/VASO_LN.4dmean.nii")


print_usage() {
  printf "Usage: ..."
}

while getopts 'r:p:o:e:' flag; do
  case "${flag}" in
    r) roi_path="${OPTARG}" ;;
    p) num_pcas="${OPTARG}" ;;
    o) out_dir="${OPTARG}" ;;
    e) EPIs=("${OPTARG}") ;;
    *) print_usage
       exit 1 ;;
  esac
done

roi_paths=($roi_path)

log=$out_dir/fsl_feat_submit_pcas.log

mkdir -p $out_dir
touch $log

#export EPIs=($(find $ds_dir -name "VASO_LN.norm.nii"))
#export EPIs=("/data/kleinrl/Wholebrain2.0/VASO_LN.4dmean.nii")
#export EPIs=("/data/kleinrl/Wholebrain2.0/VASO_LN.4dmean.norm.nii")
#EPIs=()



for roi_path in ${roi_paths[@]}; do 
for epi in ${EPIs[@]}; do 

  epi_pre=$(echo $epi | cut -d'/' -f5- )
  epi_pre=$(basename "${epi_pre////_}" .nii)

  mask=$roi_path
  roi=$(basename $roi_path .nii)


  timeseries_dir=$out_dir/timeseries/
  timeseries_1D=$timeseries_dir/$epi_pre.1D
  timeseries_2D=$timeseries_dir/$epi_pre.2D
  
  mkdir -p $timeseries_dir

  cd $timeseries_dir
  if [ -f $timeseries_2D ]; then 
    rm $timeseries_2D
  fi 


  echo "epi           $epi" >> $log 
  echo "epi_pre:      $epi_pre" >> $log 
  echo "mask:         $mask " >> $log 
  echo "timeseries_1D $timeseries_1D" >> $log 
  echo "timeseries_2D $timeseries_2D" >> $log 
  echo "out_dir_1D    $out_dir_1D" >> $log 


  3dmaskdump -noijk -mask $mask -o $timeseries_2D -overwrite $epi 
  get_pcas.py --file $timeseries_2D   #--var 0.50

  ts=($timeseries_dir/$epi_pre.2D.pca*.1D)
  for t in ${ts[@]:0:$num_pcas}; do 

    out_dir_2D="$out_dir/$(basename $t .1D)"
    

    echo "pca:          $t " >> $log 
    echo "out_dir_2D:   $out_dir_2D" >> $log 

    rm -rf $out_dir_2D*
    mkdir -p $out_dir_2D
    run_fslFeat.sh $epi $t $out_dir_2D 
  
  done 
done 
done 
