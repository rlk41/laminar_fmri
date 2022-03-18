#!/bin/bash 

#fsl_design_file=$1

# EPI=$EPI_4d
# timeseries=$t 
# out_dir=$fsl_feat_out


EPI=$1
out_dir=$3



export FSL_MEM=20
#out_dir="$fsl_feat_dir/$(basename $timeseries .1D)"
generated_melodic_design_file="$out_dir/design.fsf"
log="$out_dir/fsl_feat.log"



echo "Running design.fsf ${1}"
echo "EPI:          $EPI"
echo "outdir:       $out_dir "
echo "design_file:  $generated_melodic_design_file"
echo "log:          $log"


mkdir -p $out_dir 
echo "mkdir out_dir: $out_dir  " >> $log 



if [ -f $generated_melodic_design_file ]; then 
  rm $generated_melodic_design_file
fi 

echo "generating DESIGN.fsf   " >> $log 
echo "     params $EPI $timeseries $out_dir" >> $log 

#generate_fslFeat_design.sh $EPI $timeseries $out_dir > $generated_fsl_design_file
generate_fslMelodic_design.sh $EPI $out_dir > $generated_melodic_design_file


echo "running melodic" >> $log 

#feat $generated_fsl_design_file
melodic $generated_melodic_design_file

echo "done -- fsl_melodic.job.sh"