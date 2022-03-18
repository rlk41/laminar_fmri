analysis_dir="$my_scratch/analyses/null_dist"



parc=$warped_columns_30k

base=$(basename $parc .nii )

roi_dir="$analysis_dir/rois"


rois=($(ls $rois_hcp/*.L_*.nii))

#rois=( ${rois1[@]} ${rois2[@]} ${rois3[@]} ${rois4[@]} ${rois5[@]})

echo ${#rois[@]}




mkdir -p $analysis_dir 
mkdir -p $roi_dir 

swarm_submit=$analysis_dir/swarm.submit
touch $swarm_submit

size=${#rois[@]}

# for start in `seq 1 5 $size`
# do    
#     c=${rois[$start]}

#     roi_path="$roi_dir/$c.nii.gz"

#     3dcalc -a $parc -expr "equals(a, $c)" -prefix $roi_path &

# done



for start in `seq 1 5 $size`
do    

    roi_path=${rois[$start]} 

    c=$(basename $roi_path .nii)

    


    out_dir=$analysis_dir/fsl_feat_${c}_pca10

    mkdir -p $out_dir 




    # running average 
    echo "run_laminar_permute_swarm.sh -r $roi_path -p 10 -o $out_dir " >> $swarm_submit


done 


echo "run_laminar_permute_swarm.sh -r $rois_hcp/1010.L_FEF.nii -p 10 -o $out_dir " >> $swarm_submit

swarm -b 10 -f $swarm_submit -g 10



