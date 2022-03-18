


analysis_dir="$my_scratch/analyses/nullDist_pca10_single"

cd $analysis_dir

parc=$warped_columns_30k

base=$(basename $parc .nii )

roi_dir="$analysis_dir/rois"


rois=($(ls $rois_hcp/*.nii))



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


    out_dir=$analysis_dir/fsl_feat_${c}_pca10_ALL

    mkdir -p $out_dir 


    # echo "run_laminar_permute_swarm.sh -r $roi_path -p 10 -o $out_dir -A " | tee -a $swarm_submit
    echo "run_laminar_permute_swarm.sh -r $roi_path -p 10 -o $out_dir -X" | tee -a $swarm_submit


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

feats_to_merge=($(find . -name swarm.feat ))
echo ${#feats_to_merge[@]}

size=${#feats_to_merge[@]}


w=0 
while [ $w -le 50 ]; do 
for start in `seq 0 3 $(( $size - 1 ))`; do    
    f=${feats_to_merge[$start]} 
    IFS='/' read -ra ff <<< "$f"
    base=${ff[1]}
    #echo $start $f $base 

    if [ ! -f $base/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat/thresh_zstat1.nii.gz ]; then 
        echo Doesnt exist: $base 
        cat $f >> $swarm_merged_feat
        w=$(( $w + 1 ))
    fi 
    
done 
done 



cat  $swarm_merged_feat | wc -l 


# for f in fsl_feat_*; do 
# for ff in $f/DAY*; do 
# for fff in $ff/*.feat; do 
# echo $fff
# rm -rf $fff/filtered_func_data.nii.gz
# rm -rf $fff/stats/res4d.nii.gz

# done 
# done 
# done 




# cat $analysis_dir/fsl_feat_1133.L_TE1p_pca10_ALL/swarm/swarm.feat | wc -l 
# cat $analysis_dir/fsl_feat_1002.L_MST_pca10_ALL/swarm/swarm.feat | wc -l 
# cat $swarm_merged_feat | wc -l 


# cat $analysis_dir/fsl_feat_1133.L_TE1p_pca10_ALL/swarm/swarm.feat >> $swarm_merged_feat
# cat $analysis_dir/fsl_feat_1002.L_MST_pca10_ALL/swarm/swarm.feat >> $swarm_merged_feat

# cat $swarm_merged_feat | wc -l 


dep_feat_merged=$(swarm -f $swarm_merged_feat -g 20 -t 1 --job-name feat_merged --logdir $swarm_merged_dir --time 10:00:00 )

# 33760212
# 33981904

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

    if [ -d $out_dir/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat ]; 
    then 
    echo "EXISTS RUNNING -- $out_dir/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat "


    echo "run_laminar_permute_post.sh -d $out_dir" | tee -a $swarm_merged_dir/swarm_merged.post 

    s=( 1 3 5 7 8 )
    dir="$out_dir/mean"
    mkdir -p $dir 
    mkdir -p $dir/logs

    for smoothing in ${s[@]};do 
    echo "L2D.job.sh $dir $smoothing" | tee -a $swarm_merged_dir/swarm_merged.L2D 
    done 


    fi 
done 





dep_merged_post=$(swarm -f $swarm_merged_dir/swarm_merged.post -g 10 --job-name post_merged --logdir $swarm_merged_dir \
--time 02:00:00)

# dep_merged_post=$(swarm -f $swarm_merged_dir/swarm_merged.post -g 10 --job-name swarm_merged_post --logdir $swarm_merged_dir \
# --dependency=afterok:$dep_merged_feat --time 02:00:00)


dep_merged_L2D=$(swarm -f $swarm_merged_dir/swarm_merged.L2D -g 20  --job-name L2D_merged --logdir $swarm_merged_dir \
--dependency=afterok:$dep_merged_post --time 48:00:00 )



###############
# build null 
#################

# create dir 
null_dir=$analysis_dir/null_1000
mkdir -p $null_dir

pes=($(find $analysis_dir/fsl_feat* -name inv_pe1.nii))
size=${#pes[@]}

echo $size ${pes[1]}

null_pes=()

for s in `seq 1 1000`; do 
    num=$((0 + $RANDOM % $(( $size - 1 )) ))
    num_pe=${pes[$num]}
    echo $num $num_pe

    null_pes+=($num_pe)

done 

3dMean -prefix $null_dir/inv_pe1.nii ${null_pes[@]} 
3dinfo $null_dir/inv_pe1.nii


# get inv_mean_func.nii in dir 
null_means=($(find $analysis_dir -name inv_mean_func.nii ))
cp ${null_means[0]} $null_dir/inv_mean_func.nii 





if [ -f $swarm_merged_dir/swarm_merged.L2D_null ]; 
then 
rm $swarm_merged_dir/swarm_merged.L2D_null
touch $swarm_merged_dir/swarm_merged.L2D_null
else 
touch $swarm_merged_dir/swarm_merged.L2D_null
fi 


s=( 1 3 5 7 8 )

mkdir -p $null_dir 
mkdir -p $null_dir/logs

for smoothing in ${s[@]};do 
echo "L2D.job.sh $null_dir $smoothing" | tee -a $swarm_merged_dir/swarm_merged.L2D_null 
done 


    

swarm -f $swarm_merged_dir/swarm_merged.L2D_null -g 20  --job-name L2DNULL_merged --logdir $null_dir/logs \
--time 48:00:00 









LN2_LAYERDIMENSION.py \
--input "/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_single/null_1000/inv_pe1.fwhm7.nii.gz" \
--columns  "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/columns/columns_ev_30000_borders.nii" \
--layers "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/grow_leaky_loituma/equi_volume_layers_n10.nii" 

cd /data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_single/null_1000

downsample_2x_NN.sh "/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_single/null_1000/inv_pe1.fwhm7.mean.nii.gz" 
downsample_2x_NN.sh "/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_single/null_1000/inv_pe1.fwhm7.se.nii.gz" 
downsample_2x_NN.sh "/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_single/null_1000/inv_pe1.fwhm7.sd.nii.gz" 


for f in fsl_feat_*; do 
if [ -f $f/mean/inv_pe1.fwhm7.nii.gz ]; then 
echo  "LN2_LAYERDIMENSION.py --input $analysis_dir/$f/mean/inv_pe1.fwhm7.nii.gz --columns  /data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/columns/columns_ev_30000_borders.nii --layers /data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/grow_leaky_loituma/equi_volume_layers_n10.nii" >> swarm.getDist


fi
done 

cat $analysis_dir/swarm.getDist  | wc -l 


swarm -f $analysis_dir/swarm.getDist_test -g 10  --job-name getDist --time 00:30:00 

34000087

34000621



# swarm -f swarm.post -g 10 --job-name feat_post --time 00:30:00





pes=($(find $analysis_dir -name inv_pe1.fwhm7.nii.gz))

pes=($(ls $analysis_dir/fsl_feat_*/mean/inv_pe1.fwhm7.nii.gz))

touch swarm.todataframe 

for p in ${pes[@]}; do 
#echo "LN2_todataframe.py --input $p --columns  /data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/columns/columns_ev_30000_borders.nii --layers /data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/grow_leaky_loituma/equi_volume_layers_n10.nii" >> swarm.todataframe 
echo "LN2_todataframe.py --input $p --columns  /data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/multiAtlasTT/hcp-mmp-b/hcp-mmp-b.nii.gz --layers /data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/grow_leaky_loituma/equi_volume_layers_n10.nii" >> swarm.todataframe 
done 

swarm -f swarm.todataframe -g 10 --job-name todataframe --time 00:30:00

