



analysis="thalamicRois"
analysis_dir=$my_scratch/analyses/$analysis 

mkdir -p $analysis_dir


# tests
# run_laminar_permute_swarm.sh -r $roi_path -p 0 -o $out_dir -t 2 -X
# run_laminar_permute_swarm.sh -r $roi_path -p 0 -o $out_dir -t 2 -A -X 

# run_laminar_permute_swarm.sh -r $roi_path -p 2 -o $out_dir -t 2 -X
# run_laminar_permute_swarm.sh -r $roi_path -p 2 -o $out_dir -t 2 -X -A 

rois=($(ls $rois_thalamic/*.lh.*))
echo ${#rois[@]}

for roi_path in ${rois[@]}; do 

    # diagonal AVE 
    roi=$(basename $roi_path .nii)
    
    echo $roi $roi_path 

    
    out_dir="$analysis_dir/${roi}_ave"
    mkdir -p $out_dir 
    run_laminar_permute_swarm.sh -r $roi_path -p 0 -o $out_dir 

done 









analysis="thalamicRois"
analysis_dir=$my_scratch/analyses/$analysis 

rois=($(ls $rois_thalamic/*.lh.*))
echo ${#rois[@]}

for roi_path in ${rois[@]}; do 

    # diagonal AVE 
    roi=$(basename $roi_path .nii)
    
    echo $roi $roi_path 

    
    out_dir="$analysis_dir/${roi}_ave"

    swarm_dir="$out_dir/swarm"

    dep_post=$(swarm -f $swarm_dir/swarm.post -g 10 --job-name feat_post --time 00:30:00)


    dep_L2D=$(swarm -f $swarm_dir/swarm.L2D -g 20  --job-name L2D --logdir $swarm_dir \
    --time 24:00:00 --dependency=afterok:$dep_post)


done 








