#!/bin/bash 

set -e 

source_laminar_fmri 

#export fsl_feat_dir="${ds_dir}/derivatives/sub-01/fslFEAT"

export fsl_timecourse_dir="$fsl_feat_dir/L_LGN_1Ds"

export fsl_design_file="$fsl_feat_dir/design.fsf"
export fsl_feat_template="$project_dir2.fsf"
export fsl_design_generated="$fsl_feat_dir/"
mkdir -p $fsl_feat_dir

cd $fsl_feat_dir



for EPI in $VASO_func_dir/*VASO.nii; do 

    source /home/kleinrl/projects/laminar_fmri/paths_biowulf

    #export L_LGN_1D="${fsl_feat_dir}/L_LGN.${EPI_base}.1D"

    #3dmaskave -q -mask $rois_thalamic/8109.lh.LGN.nii $EPI > $L_LGN_1D

    for roi in rois_thalamic/*; do 



        export roi_1D="${fsl_feat_dir}/L_LGN.${EPI_base}.1D"


        # extract average 
        3dmaskave -q -mask $rois_thalamic/8109.lh.LGN.nii $EPI > $L_LGN_1D     


        # dump and PCA.. 




    done 


done 

job_list="$fsl_feat_dir/joblist.txt"
rm $job_list 

for EPI in $VASO_func_dir/*VASO.nii; do 
    #for timeseries in $fsl_timecourse_dir/*.1D; do 

        timeseries="$fsl_timecourse_dir/L_LGN.$(basename $EPI .nii).1D"

        export FSL_MEM=15


        out_dir="$fsl_feat_dir/$(basename $EPI .nii)/$(basename $timeseries .1D)"

        fsl_design_file="$out_dir/design.fsf"

        log="$out_dir/log.txt"
        
        #rm -rf $out_dir

        echo "EPI:          $EPI"
        echo "outdir:       $out_dir "
        echo "design_file:  $fsl_design_file"
        echo "log:          $log"

        #mkdir -p $out_dir 

        #generate_fslFeat_design.sh $EPI $timeseries $out_dir > $fsl_design_file

        #export FSL_MEM=15
        #feat $fsl_design_file >> $job_list &
        
        # sbatch --mem=1g --cpus-per-task=1 \
        # --output=$log \
        # --time 2:00:00 \
        # fsl_feat.job.sh $fsl_design_file >> $job_list

    #done 
done 


cat $job_list



3dMean *.feat/thresh_zstat1.nii.gz -prefix ./thresh_zstat1.MEAN.nii.gz



#for EPI in EPIs; do 

unset EPI   
source_laminar_fmri


for d in $fsl_feat_dir/*.feat; do 
    cd $d 
    echo $(pwd)

    base=$(basename $d)
    base=(${base//./ })
    base=${base[0]} 
    
    unset EPI
    EPI="$VASO_func_dir/$base.nii"


    echo "EPI :    $EPI"
    echo "columns: $warp_scaled_columns_ev_10000_borders "
    echo "layers:  $warp_scaled_layers_ed_n10 "

    source_laminar_fmri


    resample_4x.sh thresh_zstat1.nii.gz

    LN2_LAYERDIMENSION -values thresh_zstat1.scaled.nii.gz \
    -columns $warp_scaled_columns_ev_10000_borders  \
    -layers $warp_scaled_layers_ed_n10 \
    -output thresh_zstat1.scaled.L2D.nii.gz


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


