
analysis="FEF"
analysis_dir=$my_scratch/analyses/$analysis 

mkdir -p $analysis_dir


# tests
# run_laminar_permute_swarm.sh -r $roi_path -p 0 -o $out_dir -t 2 -X
# run_laminar_permute_swarm.sh -r $roi_path -p 0 -o $out_dir -t 2 -A -X 

# run_laminar_permute_swarm.sh -r $roi_path -p 2 -o $out_dir -t 2 -X
# run_laminar_permute_swarm.sh -r $roi_path -p 2 -o $out_dir -t 2 -X -A 

rois=($(ls $rois_hcp/*.L_FEF*))
echo ${#rois[@]}




for roi_path in ${rois[@]}; do 

    # diagonal AVE 
    roi=$(basename $roi_path .nii)
    
    echo $roi $roi_path 

    
    out_dir="$analysis_dir/${roi}_ave"
    mkdir -p $out_dir 
    run_laminar_permute_swarm.sh -r $roi_path -p 0 -o $out_dir 

done 





for roi_path in ${rois[@]}; do 

    # diagonal AVE 
    roi=$(basename $roi_path .nii)
    
    echo $roi $roi_path 

    
    out_dir="$analysis_dir/${roi}_pca5"
    mkdir -p $out_dir 
    run_laminar_permute_swarm.sh -r $roi_path -p 5 -o $out_dir 

done 


for roi_path in ${rois[@]}; do 

    # diagonal AVE 
    roi=$(basename $roi_path .nii)
    
    echo $roi $roi_path 

    
    out_dir="$analysis_dir/${roi}_pca10"
    mkdir -p $out_dir 
    run_laminar_permute_swarm.sh -r $roi_path -p 10 -o $out_dir 

done 



# columns per FEF 
get_column_ids >> FEF_ids
for id in FEF_ids; do 
    extract_roi -prefix 



done 




rois=""

for roi_path in ${rois[@]}; do 

    # diagonal AVE 
    roi=$(basename $roi_path .nii)
    
    echo $roi $roi_path 

    
    out_dir="$analysis_dir/${roi}_ave"
    mkdir -p $out_dir 
    run_laminar_permute_swarm.sh -r $roi_path -p 5 -o $out_dir -A

done 




# generate pltos at coords 




for roi_path in ${rois[@]}; do 

    # diagonal AVE 
    roi=$(basename $roi_path .nii)
    
    echo $roi $roi_path 

    
    out_dir="$analysis_dir/${roi}_pca5_all"
    mkdir -p $out_dir 
    run_laminar_permute_swarm.sh -r $roi_path -p 5 -o $out_dir -A

done 







analysis="FEF"
analysis_dir=$my_scratch/analyses/$analysis 

mkdir -p $analysis_dir


rois1=($(ls $rois_hcp/*.L_POS2*))
rois2=($(ls $rois_hcp/*.L_7pl*))
rois3=($(ls $rois_hcp/*.L_LO1*))
rois4=($(ls $rois_hcp/*.L_V4*))
rois5=($(ls $rois_hcp/*.L_V1*))



rois=( ${rois1[@]} ${rois2[@]} ${rois3[@]} ${rois4[@]} ${rois5[@]})

echo ${#rois[@]}


swarm_submit=$analysis_dir/swarm.submit
touch $swarm_submit


for roi_path in ${rois[@]}; do 

    # diagonal AVE 
    roi=$(basename $roi_path .nii)
    
    echo $roi $roi_path 

    
    out_dir="$analysis_dir/${roi}_pca10"
    mkdir -p $out_dir 
    echo "run_laminar_permute_swarm.sh -r $roi_path -p 10 -o $out_dir " >> $swarm_submit

done 



swarm -b 10 -f $swarm_submit -g 10
