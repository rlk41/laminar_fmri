#!/bin/bash 

#fsl_design_file=$1

# EPI=$EPI_4d
# timeseries=$t 
# feat_dir=$fsl_feat_out

set -e 


EPI=$1
timeseries=$2
feat_dir=$3



export FSL_MEM=20


cd $feat_dir


#out_dir="$fsl_feat_dir/$(basename $timeseries .1D)"
generated_fsl_design_file="$feat_dir/design.fsf"

log="$feat_dir/logs/fsl_feat.log"
log_dir="$feat_dir/logs"


echo "Running design.fsf ${1}"
echo "EPI:          $EPI"
echo "feat_dir:     $feat_dir "
echo "design_file:  $generated_fsl_design_file"
echo "log:          $log"


mkdir -p $feat_dir 
mkdir -p $log_dir


echo "mkdir feat_dir: $feat_dir  " | tee -a $log 



if [ -f $generated_fsl_design_file ]; then 
  rm $generated_fsl_design_file
fi 

echo "generating DESIGN.fsf   " | tee -a $log 
echo "     params $EPI $timeseries $feat_dir" | tee -a $log 

generate_fslFeat_design.sh $EPI $timeseries $feat_dir > $generated_fsl_design_file

echo "running feat" | tee -a $log 


# intiail but cannot get job ids
#feat $generated_fsl_design_file


# /usr/local/apps/fsl/6.0.4/bin/feat_model design

# mkdir .files;cp /usr/local/apps/fsl/6.0.4/doc/fsl.css .files;cp -r /usr/local/apps/fsl/6.0.4/doc/images .files/images

# /usr/local/apps/fsl/6.0.4/bin/fsl_sub -T 10 -l logs -N feat0_init   /usr/local/apps/fsl/6.0.4/bin/feat /gpfs/gsfs11/users/kleinrl/Wholebrain2.0/fsl_feat_permute_1010.L_FEF_V2/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat/design.fsf -D /gpfs/gsfs11/users/kleinrl/Wholebrain2.0/fsl_feat_permute_1010.L_FEF_V2/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat -I 1 -init
# 31157049

# /usr/local/apps/fsl/6.0.4/bin/fsl_sub -T 774 -l logs -N feat2_pre -j 31157049  /usr/local/apps/fsl/6.0.4/bin/feat /gpfs/gsfs11/users/kleinrl/Wholebrain2.0/fsl_feat_permute_1010.L_FEF_V2/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat/design.fsf -D /gpfs/gsfs11/users/kleinrl/Wholebrain2.0/fsl_feat_permute_1010.L_FEF_V2/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat -I 1 -prestats
# 31157182

# /usr/local/apps/fsl/6.0.4/bin/fsl_sub -T 109 -l logs -N feat3_film -j 31157182  /usr/local/apps/fsl/6.0.4/bin/feat /gpfs/gsfs11/users/kleinrl/Wholebrain2.0/fsl_feat_permute_1010.L_FEF_V2/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat/design.fsf -D /gpfs/gsfs11/users/kleinrl/Wholebrain2.0/fsl_feat_permute_1010.L_FEF_V2/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat -I 1 -stats
# 31157349

# /usr/local/apps/fsl/6.0.4/bin/fsl_sub -T 119 -l logs -N feat4_post -j 31157349  /usr/local/apps/fsl/6.0.4/bin/feat /gpfs/gsfs11/users/kleinrl/Wholebrain2.0/fsl_feat_permute_1010.L_FEF_V2/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat/design.fsf -D /gpfs/gsfs11/users/kleinrl/Wholebrain2.0/fsl_feat_permute_1010.L_FEF_V2/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat -poststats 0 
# 31157467

# /usr/local/apps/fsl/6.0.4/bin/fsl_sub -T 1 -l logs -N feat5_stop -j 31157182,31157349,31157467  /usr/local/apps/fsl/6.0.4/bin/feat /gpfs/gsfs11/users/kleinrl/Wholebrain2.0/fsl_feat_permute_1010.L_FEF_V2/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat/design.fsf -D /gpfs/gsfs11/users/kleinrl/Wholebrain2.0/fsl_feat_permute_1010.L_FEF_V2/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat -stop
# 31157667


cd $feat_dir 

#echo "Running FEAT - feat_model" | tee -a $log
#/usr/local/apps/fsl/6.0.4/bin/feat_model design

#mkdir .files;cp /usr/local/apps/fsl/6.0.4/doc/fsl.css .files;cp -r /usr/local/apps/fsl/6.0.4/doc/images .files/images


echo "Running FEAT - INIT " | tee -a $log
#/usr/local/apps/fsl/6.0.4/bin/feat $generated_fsl_design_file -D $feat_dir -I 1 -init 

dep1=$(/usr/local/apps/fsl/6.0.4/bin/fsl_sub -T 10 -l logs -N feat0_init   /usr/local/apps/fsl/6.0.4/bin/feat $feat_dir -I 1 -init )

echo "Running FEAT - PRESTATS " | tee -a $log
#/usr/local/apps/fsl/6.0.4/bin/feat $generated_fsl_design_file -D $feat_dir -I 1 -prestats 

dep2=$(/usr/local/apps/fsl/6.0.4/bin/fsl_sub -T 774 -l logs -N feat2_pre -j $dep1  /usr/local/apps/fsl/6.0.4/bin/feat $feat_dir -I 1 -prestats )


echo "Running FEAT - STATS " | tee -a $log
#/usr/local/apps/fsl/6.0.4/bin/feat $generated_fsl_design_file -D $feat_dir -I 1 -stats 

dep3=$(/usr/local/apps/fsl/6.0.4/bin/fsl_sub -T 109 -l logs -N feat3_film -j $dep2  /usr/local/apps/fsl/6.0.4/bin/feat $feat_dir -I 1 -stats )


echo "Running FEAT - POSTSTATS " | tee -a $log
#/usr/local/apps/fsl/6.0.4/bin/feat $generated_fsl_design_file -D $feat_dir -poststats 0 

mkdir -p stats 
dep4=$(/usr/local/apps/fsl/6.0.4/bin/fsl_sub -T 119 -l logs -N feat4_post -j $dep3  /usr/local/apps/fsl/6.0.4/bin/feat $feat_dir -poststats 0 )

echo "Running FEAT - STOP " | tee -a $log
#/usr/local/apps/fsl/6.0.4/bin/feat $generated_fsl_design_file -D $feat_dir -stop

dep5=$(/usr/local/apps/fsl/6.0.4/bin/fsl_sub -T 1 -l logs -N feat5_stop -j $dep2,$dep3,$dep4  /usr/local/apps/fsl/6.0.4/bin/feat $feat_dir -stop )

echo "done -- fsl_feat.job.sh" | tee -a $log


swarm_deps=$feat_dir/swarm/deps

mkdir -p $swarm_deps

echo $dep1 | tee $swarm_deps/dep1
echo $dep2 | tee $swarm_deps/dep2
echo $dep3 | tee $swarm_deps/dep3
echo $dep4 | tee $swarm_deps/dep4
echo $dep5 | tee $swarm_deps/dep5




# echo "running cleanup" | tee -a $log

# echo "removing filtered_finc_data.nii.gz" | tee -a $log
# rm  $feat_dir/filtered_func_data.nii.gz

# echo "removing stats dir" | tee -a $log
# rm -rf $feat_dir/stats


