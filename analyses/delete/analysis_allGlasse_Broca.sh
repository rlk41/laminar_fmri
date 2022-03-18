



analysis="allGlasser_broca"



analysis_dir=$my_scratch/analyses/$analysis 




parc=$warp_parc_hcp

base=$(basename $parc .nii )

roi_dir="$analysis_dir/rois"




mkdir -p $analysis_dir 
mkdir -p $roi_dir 






rois1=($(ls $rois_hcp/*.L_*47*))

rois2=($(ls $rois_hcp/*.L_*45*))

rois=( ${rois1[@]} ${rois[@]} )



echo ${#rois[@]}
echo ${rois[@]}


for c in ${rois[@]}; do 

    roi_path="$roi_dir/$c.nii.gz"

    3dcalc -a $parc -expr "equals(a, $c)" -prefix $roi_path &


done 




swarm_submit="$analysis_dir/swarm.submit"
touch $swarm_submit

for roi_path in ${rois[@]}; do 

    roi=$(basename $roi_path .nii)
    echo $roi $roi_path 

    
    out_dir="$analysis_dir/${roi}"
    mkdir -p $out_dir 
    echo "run_laminar_permute_swarm.sh -r $roi_path -p 10 -o $out_dir " | tee -a $swarm_submit

done 


swarm -b 10 -f $swarm_submit -g 10




