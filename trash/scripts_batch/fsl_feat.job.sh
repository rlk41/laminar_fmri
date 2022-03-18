#!/bin/bash 

#fsl_design_file=$1



EPI=$1
timeseries=$2
out_dir=$3



export FSL_MEM=20

echo "Running design.fsf ${1}"


#out_dir="$fsl_feat_dir/$(basename $timeseries .1D)"
generated_fsl_design_file="$out_dir/design.fsf"
log="$out_dir/fsl_feat.log"

echo "EPI:          $EPI_4d"
echo "outdir:       $out_dir "
echo "design_file:  $generated_fsl_design_file"
echo "log:          $log"


if [ -d $out_dir ]; then 
  rm -rf $out_dir*
  echo "removing out_dir: $out_dir "
fi 

echo "mkdir out_dir: $out_dir  "
mkdir -p $out_dir 

if [ -f $generated_fsl_design_file ]; then 
  rm $generated_fsl_design_file
fi 


generate_fslFeat_design.sh $EPI $timeseries $out_dir > $generated_fsl_design_file




feat $generated_fsl_design_file


echo "done "