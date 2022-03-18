



analysis="allGlasser_p47r_pca20_ALL"



analysis_dir=$my_scratch/analyses/$analysis 




parc=$warp_parc_hcp

base=$(basename $parc .nii )

roi_dir="$analysis_dir/rois"




mkdir -p $analysis_dir 
mkdir -p $roi_dir 






rois=($(ls $rois_hcp/*.L_p47r*))

#rois2=($(ls $rois_hcp/*.L_*45*))

#rois=( ${rois1[@]} ${rois[@]} )



echo ${#rois[@]}
echo ${rois[@]}


# for c in ${rois[@]}; do 

#     roi_path="$roi_dir/$c.nii.gz"

#     3dcalc -a $parc -expr "equals(a, $c)" -prefix $roi_path &


# done 


pcas=10

swarm_submit="$analysis_dir/swarm.submit"
touch $swarm_submit

for roi_path in ${rois[@]}; do 

    roi=$(basename $roi_path .nii)
    echo $roi $roi_path 

    
    out_dir="$analysis_dir/${roi}_pca${pcas}"
    mkdir -p $out_dir 
    echo "run_laminar_permute_swarm.sh -r $roi_path -p $pcas -o $out_dir -A" | tee -a $swarm_submit

done 


swarm -b 10 -f $swarm_submit -g 10



# /usr/local/bin/swarm -f /data/NIMH_scratch/kleinrl/analyses/allGlasser_p47r_pca20_A/1171.L_p47r_pca20/swarm/swarm.L2D -g 20 --job-name L2D \
# --logdir /data/NIMH_scratch/kleinrl/analyses/allGlasser_p47r_pca20_A/1171.L_p47r_pca20/swarm --time 24:00:00

# 32390173


# pcas=10

# swarm_submit="$analysis_dir/swarm.submit_2"
# touch $swarm_submit

# for roi_path in ${rois[@]}; do 

#     roi=$(basename $roi_path .nii)
#     echo $roi $roi_path 

    
#     out_dir="$analysis_dir/${roi}_pca${pcas}_ALL"
#     mkdir -p $out_dir 
#     echo "run_laminar_permute_swarm.sh -r $roi_path -p $pcas -o $out_dir -A " | tee -a $swarm_submit

# done 


# swarm -b 10 -f $swarm_submit -g 10
