#!/bin/bash 

set -e 

source_laminar_fmri 

#export fsl_feat_dir="${ds_dir}/derivatives/sub-01/fslFEAT"
#export fsl_design_file="$fsl_feat_dir/design.fsf"
#export fsl_feat_template="$project_dir2.fsf"
#export fsl_design_generated="$fsl_feat_dir/"

mkdir -p $fsl_feat_dir
mkdir -p $fsl_timecourse_dir

cd $fsl_feat_dir



for EPI in $VASO_func_dir/*VASO.nii; do 

    source /home/kleinrl/projects/laminar_fmri/paths_biowulf

    #export L_LGN_1D="${fsl_feat_dir}/L_LGN.${EPI_base}.1D"

    #3dmaskave -q -mask $rois_thalamic/8109.lh.LGN.nii $EPI > $L_LGN_1D

    for roi_path in $rois_thalamic/*; do 

        roi=$(basename $roi_path .nii)
        roi_1D="$fsl_timecourse_dir/$roi.$EPI_base.1D"
        roi_dump="$fsl_timecourse_dir/$roi.$EPI_base.DUMP"

        echo $roi 
        echo $roi_path 
        echo $roi_1D
        echo $roi_dump

        #extract average 
        3dmaskave -q -mask $roi_path $EPI > $roi_1D 

        # dump and PCA.. 
        3dmaskdump -noijk -o $roi_dump -mask $roi_path $EPI

    done 

    for roi_path in $rois_hcp/*L_V1*; do 

        roi=$(basename $roi_path .nii)
        roi_1D="$fsl_timecourse_dir/$roi.$EPI_base.1D"
        roi_dump="$fsl_timecourse_dir/$roi.$EPI_base.DUMP"

        echo $roi 
        echo $roi_path 
        echo $roi_1D
        echo $roi_dump

        #extract average 
        3dmaskave -q -mask $roi_path $EPI > $roi_1D 

        # dump and PCA.. 
        3dmaskdump -noijk -o $roi_dump -mask $roi_path $EPI

    done 

    for roi_path in $rois_hcp/*L_MT*; do 

        roi=$(basename $roi_path .nii)
        roi_1D="$fsl_timecourse_dir/$roi.$EPI_base.1D"
        roi_dump="$fsl_timecourse_dir/$roi.$EPI_base.DUMP"

        echo $roi 
        echo $roi_path 
        echo $roi_1D
        echo $roi_dump

        #extract average 
        3dmaskave -q -mask $roi_path $EPI > $roi_1D 

        # dump and PCA.. 
        3dmaskdump -noijk -o $roi_dump -mask $roi_path $EPI

    done 

    for roi_path in $rois_hcp/*R_V1*; do 

        roi=$(basename $roi_path .nii)
        roi_1D="$fsl_timecourse_dir/$roi.$EPI_base.1D"
        roi_dump="$fsl_timecourse_dir/$roi.$EPI_base.DUMP"

        echo $roi 
        echo $roi_path 
        echo $roi_1D
        echo $roi_dump

        #extract average 
        3dmaskave -q -mask $roi_path $EPI > $roi_1D 

        # dump and PCA.. 
        3dmaskdump -noijk -o $roi_dump -mask $roi_path $EPI

    done 

    for roi_path in $rois_hcp/*R_MT*; do 

        roi=$(basename $roi_path .nii)
        roi_1D="$fsl_timecourse_dir/$roi.$EPI_base.1D"
        roi_dump="$fsl_timecourse_dir/$roi.$EPI_base.DUMP"

        echo $roi 
        echo $roi_path 
        echo $roi_1D
        echo $roi_dump

        #extract average 
        3dmaskave -q -mask $roi_path $EPI > $roi_1D 

        # dump and PCA.. 
        3dmaskdump -noijk -o $roi_dump -mask $roi_path $EPI

    done 


    3dcalc -a $rois_thalamic/8109.lh.LGN.nii \
            -b $rois_thalamic/8209.rh.LGN.nii \
            -expr 'a+b' -prefix $rois_thalamic/both.LGN.nii



    for roi_path in $rois_thalamic/both.LGN.nii; do 

        roi=$(basename $roi_path .nii)
        roi_1D="$fsl_timecourse_dir/$roi.$EPI_base.1D"
        roi_dump="$fsl_timecourse_dir/$roi.$EPI_base.DUMP"

        echo $roi 
        echo $roi_path 
        echo $roi_1D
        echo $roi_dump

        #extract average 
        3dmaskave -q -mask $roi_path $EPI > $roi_1D 

        # dump and PCA.. 
        3dmaskdump -noijk -o $roi_dump -mask $roi_path $EPI

    done 



done 

job_list="$fsl_feat_dir/joblist.txt"
rm $job_list 

#sub-01_ses-06_task-movie_run-05_

for EPI in $VASO_func_dir/*VASO.nii; do 
    for timeseries in $fsl_timecourse_dir/*lh.LGN*.1D; do 


        out_dir_clust="$fsl_feat_dir/$(basename $EPI .nii)/$(basename $timeseries .1D).cluster"
        fsl_design_file_clust="$out_dir_clust/design.fsf"
        log_clust="$out_dir_clust/log.txt"

        echo "EPI:          $EPI "
        echo "outdir:       $out_dir_clust "
        echo "design_file:  $fsl_design_file_clust"
        echo "log:          $log_clust"

        mkdir -p $out_dir_clust

        generate_fslFeat_design.sh $EPI $timeseries $out_dir_clust > $fsl_design_file_clust

        sbatch --mem=1g --cpus-per-task=1 \
        --output=$log_clust \
        --time 2:00:00 \
        fsl_feat.job.sh $fsl_design_file_clust >> $job_num
        
        echo $job_num >> $job_list

        echo "EPI :    $EPI"
        echo "columns: $warp_scaled_columns_ev_10000_borders "
        echo "layers:  $warp_scaled_layers_ed_n10 "
        echo "dir:     $d"
        # source_laminar_fmri


        # resample_4x.sh thresh_zstat1.nii.gz

        # LN2_LAYERDIMENSION -values thresh_zstat1.scaled.nii.gz \
        # -columns $warp_scaled_columns_ev_10000_borders  \
        # -layers $warp_scaled_layers_ed_n10 \
        # -output thresh_zstat1.scaled.L2D.nii.gz

        sbatch --mem=20g --cpus-per-task=2 \
        --output="$logs/L2D-$base.log" \
        --time 5:00:00 \
        --job-name="L2D" \
        L2D.job.sh $EPI $d 





    done 
done 



cd /data/kleinrl/layers_rs5x_sub-06-05/

warp_ANTS_resampleNN_inverse.sh equi_distance_layers_n10.nii rim.nii
warp_ANTS_resampleNN_inverse.sh equi_volume_layers_n10.nii rim.nii

for EPI in ${EPIs[@]}; do 
    source_laminar_fmri
    


    mkdir -p $EPI_base 
    cd $EPI_base 

    echo $EPI_base 
    echo $(pwd)


    cp ../warped_* . 

    warp_ANTS_resampleNN.sh warped_equi_distance_layers_n10.nii ../rim.nii
    warp_ANTS_resampleNN.sh warped_equi_volume_layers_n10.nii ../rim.nii

    cd .. 

    done 



 for timeseries in $fsl_timecourse_dir/*L_MT*.1D; do 

        #timeseries="$fsl_timecourse_dir/L_LGN.$(basename $EPI .nii).1D"

        export FSL_MEM=15


        out_dir_clust="$fsl_feat_dir/$(basename $EPI .nii)/$(basename $timeseries .1D).cluster"
        out_dir_vox="$fsl_feat_dir/$(basename $EPI .nii)/$(basename $timeseries .1D).voxelwise"

        fsl_design_file_clust="$out_dir_clust/design.fsf"
        fsl_design_file_vox="$out_dir_vox/design.fsf"

        log_clust="$out_dir_clust/log.txt"
        log_vox="$out_dir_vox/log.txt"

        #rm -rf $out_dir

        echo "EPI:          $EPI"
        echo "outdir:       $out_dir_clust "
        echo "outdir:       $out_dir_vox "

        echo "design_file:  $fsl_design_file_clust"
        echo "design_file:  $fsl_design_file_vox"

        #echo "log:          $log"

        mkdir -p $out_dir_clust
        mkdir -p $out_dir_vox

        generate_fslFeat_design.sh $EPI $timeseries $out_dir_clust > $fsl_design_file_clust
        generate_fslFeat_design_voxel.sh $EPI $timeseries $out_dir_vox > $fsl_design_file_vox

        #export FSL_MEM=15
        #feat $fsl_design_file >> $job_list &
        
        sbatch --mem=1g --cpus-per-task=1 \
        --output=$log_clust \
        --time 2:00:00 \
        fsl_feat.job.sh $fsl_design_file_clust >> $job_list

        sbatch --mem=1g --cpus-per-task=1 \
        --output=$log_vox \
        --time 2:00:00 \
        fsl_feat.job.sh $fsl_design_file_vox >> $job_list

    done 

 for timeseries in $fsl_timecourse_dir/*R_V1*.1D; do 

        #timeseries="$fsl_timecourse_dir/L_LGN.$(basename $EPI .nii).1D"

        export FSL_MEM=15


        out_dir_clust="$fsl_feat_dir/$(basename $EPI .nii)/$(basename $timeseries .1D).cluster"
        out_dir_vox="$fsl_feat_dir/$(basename $EPI .nii)/$(basename $timeseries .1D).voxelwise"

        fsl_design_file_clust="$out_dir_clust/design.fsf"
        fsl_design_file_vox="$out_dir_vox/design.fsf"

        log_clust="$out_dir_clust/log.txt"
        log_vox="$out_dir_vox/log.txt"

        #rm -rf $out_dir

        echo "EPI:          $EPI"
        echo "outdir:       $out_dir_clust "
        echo "outdir:       $out_dir_vox "

        echo "design_file:  $fsl_design_file_clust"
        echo "design_file:  $fsl_design_file_vox"

        #echo "log:          $log"

        mkdir -p $out_dir_clust
        mkdir -p $out_dir_vox

        generate_fslFeat_design.sh $EPI $timeseries $out_dir_clust > $fsl_design_file_clust
        generate_fslFeat_design_voxel.sh $EPI $timeseries $out_dir_vox > $fsl_design_file_vox

        #export FSL_MEM=15
        #feat $fsl_design_file >> $job_list &
        
        sbatch --mem=1g --cpus-per-task=1 \
        --output=$log_clust \
        --time 2:00:00 \
        fsl_feat.job.sh $fsl_design_file_clust >> $job_list

        sbatch --mem=1g --cpus-per-task=1 \
        --output=$log_vox \
        --time 2:00:00 \
        fsl_feat.job.sh $fsl_design_file_vox >> $job_list

    done 



done 


cat $job_list



echo ${fsl_feats[@]}
echo $fsl_feats_mean

3dMean -prefix $fsl_feats_mean ${fsl_feats[@]} -overwrite

unset fsl_L2D_congruent
fsl_L2D_congruent=()
for e in $fsl_feat_dir/sub*VASO; do 
base=$(basename $e)
add=($(find $fsl_feat_dir -wholename "$base/*L_LGN.$base.feat/thresh_zstat1.scaled.L2D.nii.gz"))
fsl_L2D_congruent+=("$e/L_LGN.$base/thresh_zstat1.scaled.L2D.nii.gz")
#fsl_L2D_congruent+=(add)

done 

3dMean -prefix $fsl_L2D_mean ${fsl_L2D_congruent[@]:2:14} -overwrite


# upsample each b-weight vol
# transform rim to b-weight 
# build layers 

cd $layer4EPI
mkdir -p layers_scaled_ed_n10 
cd layers_scaled_ed_n10

# LN2_LAYERS \
# -rim $warped_scaled_rim \
# -nr_layers 10 \
# -incl_borders \
# -output warped_scaled_rim_equidist_n10 

# sbatch --mem=40g --cpus-per-task=2 \
# --output=$logs/layer_job_fsl_feat2.log \
# --time 24:00:00 \
# layers_job.sh 

# extract 


feat_thresh=$fsl_feat_dir/$EPI_base/$EPI_base.L_LGN.$EPI_base.feat/thresh_zstat1.nii.gz
feat_thresh_scaled5x=$fsl_feat_dir/$EPI_base/$EPI_base.L_LGN.$EPI_base.feat/thresh_zstat1.scaled5x.nii.gz
rim2thresh=$fsl_feat_dir/$EPI_base/$EPI_base.L_LGN.$EPI_base.feat/rim.thresh_zstat1.scaled5x.nii.gz


3dinfo $feat_thresh

resample_5x.sh $feat_thresh
#warp_ANTS_resampleNN.sh $rim 

antsApplyTransforms -d 3 -i $rim -o $rim2thresh -r $feat_thresh_scaled5x \
-t $ANTs_reg_1warp -t $ANTs_reg_0GenAffine -n NearestNeighbor

3dcalc -a $rim2thresh  -datum short -expr 'a' -prefix $rim2thresh  -overwrite

#mri_convert rim.thresh_zstat1.scaled5x.nii.gz rim.nii

# layers_feat_job.sh 



3dinfo thresh_zstat1.scaled5x.nii

3drefit -TR .1 thresh_zstat1.scaled5x.nii





# LN_GROW_LAYERS -rim $rim2thresh -N 1000 -vinc 60 -threeD
# #LN_LEAKY_LAYERS -rim rim.nii -nr_layers 1000 -iterations 100

# # N3
# LN_LOITUMA -equidist rim_layers.nii -leaky rim_leaky_layers.nii -FWHM 1 -nr_layers 3
# mv equi_distance_layers.nii equi_distance_layers_n3.nii
# mv equi_volume_layers.nii equi_volume_layers_n3.nii

# # N10
# LN_LOITUMA -equidist rim_layers.sacled.nii -leaky rim_leaky_layers.scaled.nii -FWHM 1 -nr_layers 10
# mv equi_distance_layers.scaled.nii equi_distance_layers_n10.scaled.nii
# mv equi_volume_layers.scaled.nii equi_volume_layers_n10.scaled.nii


cp $warp_scaled_columns_ev_10000_borders . 

3dresample -master thresh_zstat1.scaled5x.nii \
-prefix warped_columns_ev_10000_borders.scaled5x.nii \
-input warped_columns_ev_10000_borders.scaled.nii

# Apply inverse warp but keep scaled up 

LN2_LAYERDIMENSION -values thresh_zstat1.scaled5x.nii \
-columns warped_columns_ev_10000_borders.scaled5x.nii  \
-layers equi_volume_layers_n10.nii \
-output thresh_zstat1.scaled5x.L2D.nii.gz

# layers  810 1080 600 
# column  810 1080 600 
# in  810 1080 600 

# freeview \
# thresh_zstat1.scaled5x.nii \
# warped_columns_ev_10000_borders.scaled5x.nii  \
# equi_volume_layers_n10.nii \
# thresh_zstat1.scaled5x.L2D.nii.gz


#for EPI in EPIs; do 

unset EPI   
source_laminar_fmri
#source 

for d in $fsl_feat_dir/*/L_LGN*.feat; do 
    cd $d 
    echo $(pwd)

    #base=$(basename $d)
    #base=(${base//./ })
    base=(${d//// })

    base=${base[-2]} 
    
    unset EPI
    EPI="$VASO_func_dir/$base.nii"


    echo "EPI :    $EPI"
    echo "columns: $warp_scaled_columns_ev_10000_borders "
    echo "layers:  $warp_scaled_layers_ed_n10 "
    echo "dir:     $d"
    # source_laminar_fmri


    # resample_4x.sh thresh_zstat1.nii.gz

    # LN2_LAYERDIMENSION -values thresh_zstat1.scaled.nii.gz \
    # -columns $warp_scaled_columns_ev_10000_borders  \
    # -layers $warp_scaled_layers_ed_n10 \
    # -output thresh_zstat1.scaled.L2D.nii.gz

    sbatch --mem=20g --cpus-per-task=2 \
    --output="$logs/L2D-$base.log" \
    --time 5:00:00 \
    --job-name="L2D" \
    L2D.job.sh $EPI $d 

done

# average zstats 
for d in $fsl_feat_dir/*.feat; do 
    cd $d 






done














# kleinrl  25889936      sinteracti  interactive  R                  2:19:05      8:00:00      1     10   20 GB              cn0851
# kleinrl  25892741_0    feat2_pre   norm         R                  1:28:33      2:00:00      1      2   15 GB  afterany:2  cn0864
# kleinrl  25892743_[0]  feat3_film  quick        PD  Dependency                  2:00:00             1   15 GB  afterany:2
# kleinrl  25892745_[0]  feat4_post  quick        PD  Dependency                  2:00:00             1   15 GB  afterany:2
# kleinrl  25892747_[0]  feat5_stop  quick        PD  Dependency                  2:00:00             1   15 GB  afterany:2
# kleinrl  25892749_0    feat2_pre   norm         R                  1:28:33      2:00:00      1      2   15 GB  afterany:2  cn0948
# kleinrl  25892750_[0]  feat3_film  quick        PD  Dependency                  2:00:00             1   15 GB  afterany:2
# kleinrl  25892752_[0]  feat4_post  quick        PD  Dependency                  2:00:00             1   15 GB  afterany:2
# kleinrl  25892753_[0]  feat5_stop  quick        PD  Dependency                  2:00:00             1   15 GB  afterany:2
# kleinrl  25892803_0    feat2_pre   norm         R                  1:28:33      2:00:00      1      2   15 GB  afterany:2  cn0956
# kleinrl  25892876_[0]  feat3_film  quick        PD  Dependency                  2:00:00             1   15 GB  afterany:2
# kleinrl  25892877_[0]  feat4_post  quick        PD  Dependency                  2:00:00             1   15 GB  afterany:2
# kleinrl  25892878_[0]  feat5_stop  quick        PD  Dependency                  2:00:00             1   15 GB  afterany:2
# kleinrl  25892880_0    feat2_pre   norm         R                  1:28:33      2:00:00      1      2   15 GB  afterany:2  cn0990
# kleinrl  25892881_[0]  feat3_film  quick        PD  Dependency                  2:00:00             1   15 GB  afterany:2
# kleinrl  25892882_[0]  feat4_post  quick        PD  Dependency                  2:00:00             1   15 GB  afterany:2
# kleinrl  25892883_[0]  feat5_stop  quick        PD  Dependency                  2:00:00             1   15 GB  afterany:2
# kleinrl  25892887_0    feat2_pre   norm         R                  1:28:33      2:00:00      1      2   15 GB  afterany:2  cn0990
# kleinrl  25892888_[0]  feat3_film  quick        PD  Dependency                  2:00:00             1   15 GB  afterany:2
# kleinrl  25892911_[0]  feat4_post  quick        PD  Dependency                  2:00:00             1   15 GB  afterany:2
# kleinrl  25892913_[0]  feat5_stop  quick        PD  Dependency                  2:00:00             1   15 GB  afterany:2
# kleinrl  25892915_0    feat2_pre   norm         R                  1:28:03      2:00:00      1      2   15 GB  afterany:2  cn1022
# kleinrl  25892916_[0]  feat3_film  quick        PD  Dependency                  2:00:00             1   15 GB  afterany:2
# kleinrl  25892917_[0]  feat4_post  quick        PD  Dependency                  2:00:00             1   15 GB  afterany:2
# kleinrl  25892918_[0]  feat5_stop  quick        PD  Dependency                  2:00:00             1   15 GB  afterany:2
# =====================================================================================================================================







# export fsl_design_file="/data/kleinrl/ds003216/derivatives/sub-01/VASO_func/sub-01_ses-06_task-movie_run-05_VASO_fslFEAT/design_L_LGN.fsf"

# # NEED to add .nii to end of feat_files!!!
# # set feat_files(1) "/gpfs/gsfs11/users/kleinrl/ds003216/derivatives/sub-01/VASO_func/sub-01_ses-06_task-movie_run-05_VASO.nii"

# feat $fsl_design_file 


# ##### 100GB 
# # 25859342_[0] 3.4 GB
# # 25859346_0 - 6.2 GB
# # 25859350_0 - 12 GB
# # 25859355_0 - 0.6 GB
# # 25859360_0 - 0 GB 


# set -e 


# job_name="fsl_feat_LGN"
# job_list="/home/kleinrl/projects/laminar_fmri/logs/${job_name}-joblist.log"
# #touch $job_list 

# #for EPI in $VASO_func_dir/*movie*VASO.nii
# #do 

# #echo $EPI 
# #source /home/kleinrl/projects/laminar_fmri/paths_biowulf

# log="/home/kleinrl/projects/laminar_fmri/logs/${job_name}-${EPI_base}.log"

# echo "  "
# echo "EPI: ${EPI}"
# echo "  "
# echo "LOG: ${log}"
# echo "  "


# export fsl_design_file="/home/kleinrl/projects/laminar_fmri_LGN2.fsf"

# # sbatch --mem=10g --cpus-per-task=5 \
# # --partition=norm \
# # --output=$log \
# # --time 24:00:00 \
# # --job-name=$job_name \
# # fsl_feat.job.sh $fsl_design_file >> $job_list




##### 150GB 





#upsample 



# LN2_LAYERDIMENSION



#fsl_melodic 

# export R_LGN_1D="${fsl_feat_dir}/R_LGN.${EPI_base}.1D"

# export L_MT_1D="${fsl_feat_dir}/L_MT.${EPI_base}.1D"
# export R_MT_1D="${fsl_feat_dir}/R_MT.${EPI_base}.1D"

# export L_V1_1D="${fsl_feat_dir}/L_V1.${EPI_base}.1D"
# export R_V1_1D="${fsl_feat_dir}/R_V1.${EPI_base}.1D"

# o="/home/kleinrl/Desktop/filenames.txt"

# echo $L_LGN_1D >> $o
# echo $R_LGN_1D >> $o

# echo $L_V1_1D >> $o
# echo $R_V1_1D >> $o

# echo $L_MT_1D >> $o
# echo $R_MT_1D >> $o

# 3dmaskave -q -mask $rois_thalamic/8209.rh.LGN.nii $EPI > $R_LGN_1D

# 3dmaskave -q -mask $rois_hcp/1001.L_V1.nii $EPI > $L_V1_1D
# 3dmaskave -q -mask $rois_hcp/2001.R_V1.nii $EPI > $R_V1_1D

# 3dmaskave -q -mask $rois_hcp/1023.L_MT.nii $EPI > $L_MT_1D
# 3dmaskave -q -mask $rois_hcp/2023.R_MT.nii $EPI > $R_MT_1D



# 3dmaskave -q -mask $rois_hcp/1001.L_V1.nii $EPI > $L_V1_1D
# 3dmaskave -q -mask $rois_hcp/2001.R_V1.nii $EPI > $R_V1_1D

# 3dmaskave -q -mask $rois_hcp/1023.L_MT.nii $EPI > $L_MT_1D
# 3dmaskave -q -mask $rois_hcp/2023.R_MT.nii $EPI > $R_MT_1D

# 3dmaskave -q -mask $rois_thalamic/8109.lh.LGN.nii $EPI > $L_LGN_1D
# 3dmaskave -q -mask $rois_thalamic/8209.rh.LGN.nii $EPI > $R_LGN_1D


