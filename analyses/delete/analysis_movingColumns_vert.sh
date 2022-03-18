





analysis_dir="$my_scratch/analyses/movingColumns_vertical"

rois=( "17309" "25953" "21797" "21876" "21819" "25992"
 "21818" "17292" "11142" "25949" "25986" "21810" "10350"
  "10975" "17283" "21863" )



parc=$warped_columns_30k

base=$(basename $parc .nii )

roi_dir="$analysis_dir/rois"




mkdir -p $analysis_dir 
mkdir -p $roi_dir 

swarm_submit=$analysis_dir/swarm.submit
touch $swarm_submit


for c in ${rois[@]}; do 

    roi_path="$roi_dir/$c.nii.gz"

    3dcalc -a $parc -expr "equals(a, $c)" -prefix $roi_path &

done 


for c in ${rois[@]}; do 

    roi_path="$roi_dir/final_$c.nii.gz"

    3dcalc -a $columns_30k -expr "equals(a, $c)" -prefix $roi_path &

done 





# for c in ${rois[@]}; do 


#     out_dir=$analysis_dir/fsl_feat_${c}_ave

#     mkdir -p $out_dir 


#     roi_path="$roi_dir/$c.nii.gz"


#     # running average 
#     echo "run_laminar_permute_swarm.sh -r $roi_path -p 0 -o $out_dir " >> $swarm_submit


# done 


for c in ${rois[@]}; do 


    out_dir=$analysis_dir/fsl_feat_${c}_pca10

    mkdir -p $out_dir 


    roi_path="$roi_dir/$c.nii.gz"


    # running average 
    echo "run_laminar_permute_swarm.sh -r $roi_path -p 10 -o $out_dir " >> $swarm_submit


done 

swarm -b 10 -f $swarm_submit -g 10
