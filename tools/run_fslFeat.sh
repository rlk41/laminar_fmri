#!/bin/bash 

set -e 

EPI=$1
timeseries=$2 
out_dir=$3


export FSL_MEM=20
generated_fsl_design_file="$out_dir/design.fsf"
log="$out_dir/fsl_feat_run_fslFeat.log"





# if [ -d $out_dir ]; then 
#   rm -rf $out_dir*
#   echo "removing out_dir: $out_dir "  >> $log 
# fi 

# echo "mkdir out_dir: $out_dir  "  >> $log 
# mkdir -p $out_dir 

if [ -f $generated_fsl_design_file ]; then 
  rm $generated_fsl_design_file
fi 


echo "Running design.fsf ${1}"                    >> $log 
echo "EPI:          $EPI"                         >> $log 
echo "outdir:       $out_dir "                    >> $log 
echo "design_file:  $generated_fsl_design_file"   >> $log 
echo "log:          $log"                         >> $log 



# generate_fslFeat_design.sh $EPI $timeseries $out_dir > $generated_fsl_design_file

# feat $generated_fsl_design_file


echo "dep1: $dep1" >> $log


dep1=$(sbatch --mem=1g --cpus-per-task=1 \
        --job-name=fsl_feat_submit \
        --output=$out_dir/fsl_feat.log \
        --time 2:00:00 \
        fsl_feat.job.sh $EPI $timeseries $out_dir )
        

# dep1=$(swarm \
#         --job-name=fsl_feat_submit \
#         fsl_feat.job.sh $EPI $timeseries $out_dir )



        #/data/kleinrl/Wholebrain2.0/design/fsl_feats.fsf )

#dep1="26998158"
echo "dep1: $dep1" >> $log
echo "$dep1" 
# dep2=$(sbatch --mem=20g --cpus-per-task=1 \
#         --job-name=L2D \
#         --output=$out_dir/L2D.log \
#         --time 2:00:00 \
#         --dependency=afterok:$dep1 \
#         L2D.job.sh $out_dir )


echo "DONE -- run_fslFeat.sh"  >> $log 


# for d in $fsl_feat_dir/*.feat; do 
#     cd $d 
#     echo $(pwd)

#     base=$(basename $d)
#     base=(${base//./ })
#     base=${base[0]} 
    
#     unset EPI
#     EPI="$VASO_func_dir/$base.nii"


#     echo "EPI :    $EPI"
#     echo "columns: $warp_scaled_columns_ev_10000_borders "
#     echo "layers:  $warp_scaled_layers_ed_n10 "

#     source_laminar_fmri


#     resample_4x.sh thresh_zstat1.nii.gz

#     LN2_LAYERDIMENSION -values thresh_zstat1.scaled.nii.gz \
#     -columns $warp_scaled_columns_ev_10000_borders  \
#     -layers $warp_scaled_layers_ed_n10 \
#     -output thresh_zstat1.scaled.L2D.nii.gz


# done




#export fsl_design_file="$fsl_feat_dir/design.fsf"

#export fsl_timecourse_dir="$fsl_feat_dir/L_LGN_1Ds"
#export fsl_feat_template="$project_dir2.fsf"
#export fsl_design_generated="$fsl_feat_dir/"
#export FSL_MEM=15
#timeseries="$fsl_timecourse_dir/L_LGN.$(basename $EPI .nii).1D"




# #out_dir="$fsl_feat_dir/$(basename $timeseries .1D)"
# generated_fsl_design_file="$out_dir/design.fsf"
# log="$out_dir/fsl_feat.log"

# echo "EPI:          $EPI_4d"
# echo "outdir:       $out_dir "
# echo "design_file:  $generated_fsl_design_file"
# echo "log:          $log"


# if [ -d $out_dir ]; then 
#   rm -rf $out_dir*
#   echo "removing out_dir: $out_dir "
# fi 

# echo "mkdir out_dir: $out_dir  "
# mkdir -p $out_dir 

# if [ -f $generated_fsl_design_file ]; then 
#   rm $generated_fsl_design_file
# fi 


# generate_fslFeat_design.sh $EPI_4d $timeseries $out_dir > $generated_fsl_design_file






#export FSL_MEM=15
#feat $fsl_design_file >> $job_list &

# sbatch --mem=1g --cpus-per-task=1 \
# --output=$log \
# --time 2:00:00 \
# fsl_feat.job.sh $fsl_design_file >> 



# dep1=$(sbatch --mem=1g --cpus-per-task=1 \
#         --output=$out_dir/fsl_feat.log \
#         --time 2:00:00 \
#         fsl_feat.job.sh $generated_fsl_design_file )