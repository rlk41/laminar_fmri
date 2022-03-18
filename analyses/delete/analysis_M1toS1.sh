



analysis="M2toS1"

analysis_dir=$my_scratch/analyses/$analysis 

mkdir -p $analysis_dir





rois=($(ls $rois_hcp/*.L_*))
echo ${#rois[@]}

swarm_submit="$analysis_dir/swarm.submit"
touch $swarm_submit

for roi_path in ${rois[@]}; do 

    roi=$(basename $roi_path .nii)
    echo $roi $roi_path 

    
    out_dir="$analysis_dir/${roi}_ave"
    mkdir -p $out_dir 
    echo "run_laminar_permute_swarm.sh -r $roi_path -p 0 -o $out_dir " | tee -a $swarm_submit

done 


swarm -b 10 -f $swarm_submit







for roi_path in ${rois[@]:20:40:}; do 

    roi=$(basename $roi_path .nii)
    echo $roi $roi_path 

    
    out_dir="$analysis_dir/${roi}_ave"
    mkdir -p $out_dir 
    run_laminar_permute_swarm.sh -r $roi_path -p 0 -o $out_dir 

done 



