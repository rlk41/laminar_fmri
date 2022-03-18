





analysis_dir="$my_scratch/analyses/movingColumns_horizontal"

rois=( "19275" "26539" "19517" "27054" "22677" "11584" "12796" "27986" "23211" "23227" "12488" "11313")

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


# for c in ${rois[@]}; do 


#     out_dir=$analysis_dir/fsl_feat_${c}_ave

#     mkdir -p $out_dir 


#     roi_path="$roi_dir/$c.nii.gz"

#     #3dcalc -a $parc -expr "equals(a, $c)" -prefix $roi_path

#     # running average 
#     echo "run_laminar_permute_swarm.sh -r $roi_path -p 0 -o $out_dir " >> $swarm_submit


# done 


for c in ${rois[@]}; do 


    out_dir=$analysis_dir/fsl_feat_${c}_pca10

    mkdir -p $out_dir 


    roi_path="$roi_dir/$c.nii.gz"

    #3dcalc -a $parc -expr "equals(a, $c)" -prefix $roi_path

    # running average 
    echo "run_laminar_permute_swarm.sh -r $roi_path -p 10 -o $out_dir " >> $swarm_submit


done 

cat $swarm_submit | wc 

swarm -b 10 -f $swarm_submit -g 10
