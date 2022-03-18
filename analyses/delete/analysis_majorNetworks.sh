# large scale netowkrs 
# http://scottbarrykaufman.com/wp-content/uploads/2013/08/Bressler_Large-Scale_Brain_10.pdf 

#central-executive 
#salience networks
#default-mode network 

# Predictions???



rois=($(ls $rois_hcp/*L_*{23,32,33}*))
echo $rois


for roi_path in ${rois[@]}; do 


    roi=$(basename $roi_path .nii)

    out_dir="$analysis_dir/${roi}_ave_diagonal"
    mkdir -p $out_dir 
    run_laminar_permute_swarm.sh -r $roi_path -p 0 -o $out_dir 

done 

