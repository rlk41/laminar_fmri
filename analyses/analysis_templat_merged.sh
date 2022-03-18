


analysis_dir="$my_scratch/analyses/V4_ALL"

cd $analysis_dir

parc=$warped_columns_30k

base=$(basename $parc .nii )

roi_dir="$analysis_dir/rois"


#rois=($(ls $rois_hcp/*.L_*.nii))


# fsl_feat_1001.L_V1_pca10_ALL
# 1959
# fsl_feat_1002.L_MST_pca10_ALL
# 0
# fsl_feat_1006.L_V4_pca10_ALL
# 1957
# fsl_feat_1010.L_FEF_pca10_ALL
# 1958
# fsl_feat_1023.L_MT_pca10_ALL
# 1960
# fsl_feat_1048.L_LIPv_pca10_ALL
# 1961
# fsl_feat_1133.L_TE1p_pca10_ALL
# 0
# fsl_feat_1135.L_TF_pca10_ALL
# 1953
# fsl_feat_8109.lh.LGN_pca10_ALL
# 1961

#rois1=($(ls $rois_hcp/1006.L_V4.nii))
#rois1=($(ls $rois_hcp/1010.L_FEF.nii))
#rois2=($(ls $rois_hcp/1001.L_V1.nii ))
#rois3=($(ls $rois_thalamic/8109.lh.LGN.nii))
rois1=($(ls $rois_hcp/1048.L_LIPv.nii))
rois2=($(ls $rois_hcp/1023.L_MT.nii ))
rois3=($(ls $rois_hcp/1135.L_TF.nii))


rois4=($(ls $rois_hcp/1133.L_TE1p.nii))
rois5=($(ls $rois_hcp/1002.L_MST.nii))





#rois=( ${rois1[@]} ${rois2[@]} ${rois3[@]} ) #${rois4[@]} ${rois5[@]} ${rois6[@]} ${rois7[@]}  ${rois8[@]} )
rois=( ${rois4[@]} ${rois5[@]}  ) #${rois4[@]} ${rois5[@]} ${rois6[@]} ${rois7[@]}  ${rois8[@]} )


echo ${#rois[@]}
echo ${rois[@]}




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


    out_dir=$analysis_dir/fsl_feat_${c}_pca10_ALL

    mkdir -p $out_dir 


    # echo "run_laminar_permute_swarm.sh -r $roi_path -p 10 -o $out_dir -A " | tee -a $swarm_submit
    echo "run_laminar_permute_swarm.sh -r $roi_path -p 10 -o $out_dir -A -X" | tee -a $swarm_submit


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



cat $analysis_dir/fsl_feat_1133.L_TE1p_pca10_ALL/swarm/swarm.feat | wc -l 
cat $analysis_dir/fsl_feat_1002.L_MST_pca10_ALL/swarm/swarm.feat | wc -l 
cat $swarm_merged_feat | wc -l 


cat $analysis_dir/fsl_feat_1133.L_TE1p_pca10_ALL/swarm/swarm.feat >> $swarm_merged_feat
cat $analysis_dir/fsl_feat_1002.L_MST_pca10_ALL/swarm/swarm.feat >> $swarm_merged_feat

cat $swarm_merged_feat | wc -l 


dep_feat_merged=$(swarm -f $swarm_merged_feat -g 20 -t 1 --job-name feat_merged --logdir $swarm_merged_dir --time 10:00:00 )


# dep_merged_feat=33710840



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

    echo "run_laminar_permute_post.sh -d $out_dir" | tee -a $swarm_merged_dir/swarm_merged.post 

    s=( 1 3 4 5 7 8 10 15 20)
    dir="$out_dir/mean"
    mkdir -p $dir 
    mkdir -p $dir/logs

    for smoothing in ${s[@]};do 
    echo "L2D.job.sh $dir $smoothing" | tee -a $swarm_merged_dir/swarm_merged.L2D 
    done 

done 


dep_merged_post=$(swarm -f $swarm_merged_dir/swarm_merged.post -g 10 --job-name post_merged --logdir $swarm_merged_dir \
--dependency=afterok:$dep_merged_feat --time 02:00:00)



dep_merged_L2D=$(swarm -f $swarm_merged_dir/swarm_merged.L2D -g 20  --job-name L2D_merged --logdir $swarm_merged_dir \
--dependency=afterok:$dep_merged_post --time 48:00:00 )







# $rois_hcp/1001.L_V1.nii

# $rois_hcp/1049.L_VIP.nii

# $rois_hcp/1006.L_V4.nii



# #swarm -b 10 -f $swarm_submit -g 10


# ## RUNNING POST 


# for out_dir in $analysis_dir/fsl_feat*
# do 

#     swarm_dir=$out_dir/swarm 

#     cd $swarm_dir

#     echo $swarm_dir 



#     log=$out_dir/fsl_feat_submit_pcas.log





#     if [ -f $swarm_dir/swarm.post ]; then 
#     rm $swarm_dir/swarm.post
#     fi 

#     echo "run_laminar_permute_post.sh -d $out_dir" | tee -a $swarm_dir/swarm.post $log


#     dep_post=$(swarm -f $swarm_dir/swarm.post -g 10 --job-name feat_post --time 00:30:00)



#     s=( 1 3 4 5 7 8 10 15 20)
#     dir="$out_dir/mean"
#     mkdir -p $dir 
#     mkdir -p $dir/logs


#     if [ -f $swarm_dir/swarm.L2D ]; then 
#     rm $swarm_dir/swarm.L2D
#     fi 

#     for smoothing in ${s[@]};do 
#     echo "L2D.job.sh $dir $smoothing" | tee -a $swarm_dir/swarm.L2D $log
#     done 

#     #dep_L2D=$(swarm -f $swarm_dir/swarm.L2D -g 20 --job-name L2D --logdir $swarm_dir \
#     #--time 24:00:00 --dependency=afterok:$dep_post)

#     # swarm -f swarm.L2D -g 20 --job-name L2D --logdir . --time 24:00:00

#     #echo "L2D $dep_L2D " >> $job_ids


#     dep_L2D=$(swarm -f $swarm_dir/swarm.L2D -g 20  --job-name L2D --logdir $swarm_dir \
#     --time 48:00:00 --dependency=afterok:$dep_post)

#     echo "POST $dep_L2D" | tee -a $job_ids $log 




# done 















# swarm -f swarm.post -g 10 --job-name feat_post --time 00:30:00

