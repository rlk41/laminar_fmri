


analysis_dir="$my_scratch/analyses/nullDist_pca10_V4"


cd $analysis_dir

parc=$warped_columns_30k

base=$(basename $parc .nii )

roi_dir="$analysis_dir/rois"


rois=($(ls $rois_hcp/*L_V4*.nii))



echo ${rois[@]}
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



for start in `seq 0 1 $(( $size - 1 ))`
do    

    roi_path=${rois[$start]} 

    c=$(basename $roi_path .nii)

    echo $c


    out_dir=$analysis_dir/fsl_feat_${c}_pca10

    mkdir -p $out_dir 


    # echo "run_laminar_permute_swarm.sh -r $roi_path -p 10 -o $out_dir -A " | tee -a $swarm_submit
    echo "run_laminar_permute_swarm.sh -r $roi_path -p 10 -o $out_dir -X" | tee -a $swarm_submit


done 



for start in $(seq -f "%04g" 0 20)
do    

    roi_path=${rois[0]} 

    c=$(basename $roi_path .nii)

    echo $c


    out_dir=$analysis_dir/fsl_feat_${c}_pca10_NULL${start}

    mkdir -p $out_dir 


    # echo "run_laminar_permute_swarm.sh -r $roi_path -p 10 -o $out_dir -A " | tee -a $swarm_submit
    echo "run_laminar_permute_swarm.sh -r $roi_path -p 10 -o $out_dir -X -N" | tee -a $swarm_submit


done 






# this will generate the pcas and file stricture but not run 
# if -X included 
swarm -b 10 -f $swarm_submit -g 10


#merge the swarm.feat files together and submit 

#find $analysis_dir -name swarm.feat

swarm_merged_dir=$analysis_dir/swarm_merged
swarm_merged_feat=$swarm_merged_dir/swarm_mearged.feat


mkdir -p $swarm_merged_dir


touch $swarm_merged_feat

cd $analysis_dir
feats_to_merge=($(find . -name swarm.feat ))
echo ${#feats_to_merge[@]}

size=${#feats_to_merge[@]}


cat ${feats_to_merge[@]} | tee -a $swarm_merged_feat

cat $swarm_merged_feat | wc 



dep_merged_feat=$(swarm -f $swarm_merged_feat -g 20 -t 1 --job-name feat_merged --logdir $swarm_merged_dir --time 10:00:00 )

# 34457483


if [ -f $swarm_merged_dir/swarm_merged.post  ]; 
then 
rm $swarm_merged_dir/swarm_merged.post 
touch $swarm_merged_dir/swarm_merged.post 
else 
touch $swarm_merged_dir/swarm_merged.post 
fi 



if [ -f $swarm_merged_dir/swarm_merged.L2D ]; 
then 
rm $swarm_merged_dir/swarm_merged.L2D
touch $swarm_merged_dir/swarm_merged.L2D
else 
touch $swarm_merged_dir/swarm_merged.L2D
fi 


for out_dir in $analysis_dir/fsl_feat_*; do 

    # if [ -d $out_dir/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat ]; 
    # then 
    # echo "EXISTS RUNNING -- $out_dir/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat "


    echo "run_laminar_permute_post.sh -d $out_dir" | tee -a $swarm_merged_dir/swarm_merged.post 

    s=( 1 3 5 7 8 )
    dir="$out_dir/mean"
    mkdir -p $dir 
    mkdir -p $dir/logs

    for smoothing in ${s[@]};do 
    echo "L2D.job.sh $dir $smoothing" | tee -a $swarm_merged_dir/swarm_merged.L2D 
    done 


    #fi 
done 





# dep_merged_post=$(swarm -f $swarm_merged_dir/swarm_merged.post -g 10 --job-name post_merged --logdir $swarm_merged_dir \
# --time 02:00:00)

dep_merged_post=$(swarm -f $swarm_merged_dir/swarm_merged.post -g 10 --job-name post_merged --logdir $swarm_merged_dir \
--dependency=afterany:$dep_merged_feat --time 02:00:00)


dep_merged_L2D=$(swarm -f $swarm_merged_dir/swarm_merged.L2D -g 20  --job-name L2D_merged --logdir $swarm_merged_dir \
--dependency=afterany:$dep_merged_post --time 48:00:00 )





