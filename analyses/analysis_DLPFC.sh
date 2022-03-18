
analysis="FOP"
analysis_dir=$my_scratch/analyses/$analysis 

mkdir -p $analysis_dir


# tests
# run_laminar_permute_swarm.sh -r $roi_path -p 0 -o $out_dir -t 2 -X
# run_laminar_permute_swarm.sh -r $roi_path -p 0 -o $out_dir -t 2 -A -X 

# run_laminar_permute_swarm.sh -r $roi_path -p 2 -o $out_dir -t 2 -X
# run_laminar_permute_swarm.sh -r $roi_path -p 2 -o $out_dir -t 2 -X -A 

rois=($(ls $rois_hcp/*.L_FOP*))
echo ${#rois[@]}



# submitted 
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


