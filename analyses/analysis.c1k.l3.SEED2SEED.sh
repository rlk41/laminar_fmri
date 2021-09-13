#!/bin/bash 

source ../paths

################
# C1k 
################


#rm -rf $analysis_c1k_l3_SEED2SEED
#mkdir -p $analysis_c1k_l3_SEED2SEED

cd $analysis_c1k_l3_SEED2SEED

seed=$rois_thalamic/8209.Right-LGN.nii

# Right_LGN L3 C1k
SEED2SEED.py --epi $EPI --layers $warp_leakylayers3 \
--columns $warp_columns_ev_1000 \
--seed $seed 

export cmds_SEED2SEED="$layer4EPI/cmds/cmds.SEED2SEED.c1k.l3.txt"
rm $cmds_SEED2SEED

for seed in $rois_c1kl3/*; do 

echo "/home/richard/Projects/laminar_fmri/tools/SEED2SEED.py --epi $EPI --layers $warp_leakylayers3 \
--columns $warp_columns_ev_1000 \
--seed $seed \
--outdir $analysis_c1k_l3_SEED2SEED/$(basename $seed .nii)" >> $cmds_SEED2SEED
done 

parallel --jobs 10 < $cmds_SEED2SEED


#conda activate pysurfer

#conda run -n pysurfer 
plot_surf.py \
--subid $EPI_base \
--vol $analysis_c1k_l3_SEED2SEED/8209.Right-LGN.SEED2SEED.ff.nii
plot_surf.py \
--subid $EPI_base \
--vol $analysis_c1k_l3_SEED2SEED/8209.Right-LGN.SEED2SEED.fb.nii
plot_surf.py \
--subid $EPI_base \
--vol $analysis_c1k_l3_SEED2SEED/8209.Right-LGN.SEED2SEED.super.nii
plot_surf.py \
--subid $EPI_base \
--vol $analysis_c1k_l3_SEED2SEED/8209.Right-LGN.SEED2SEED.deep.nii
plot_surf.py \
--subid $EPI_base \
--vol $analysis_c1k_l3_SEED2SEED/8209.Right-LGN.SEED2SEED.other.nii



freeview \
-v $warp_hcp \
-v $SUBJECTS_DIR/$EPI_base/mri/brain.mgz \ 
-v $analysis_c1k_l3_SEED2SEED/*.nii \ 








S2S='8209.Right-LGN.SEED2SEED.ff.nii'
hemis=('lh' 'rh')
projfracs=(0.5)
surf='white'

for hemi in ${hemis[@]}; do
  for projfrac in ${projfracs[@]}; do
    out_file=$(basename $S2S .nii)
    out="${analysis_c1k_l3_SEED2SEED}/${EPI_base}.${hemi}.projfrac_${projfrac}.${surf}.mgh"

    echo "-----------------------------"
    echo "hemi:      ${hemi}"
    echo "projfrac:  ${projfrac}"
    echo "EPI:       ${EPI_base}"
    echo "OUT:       ${out}"
    echo "-----------------------------"

    mri_vol2surf --src ${EPI} --o ${out} --regheader ${EPI_base} --hemi ${hemi} --surf ${surf} --projfrac ${projfrac} --surf-fwhm 2
  done
done











$analysis_c1k_l3_SEED2SEED/8209.Right-LGN.SEED2SEED.ff.nii
#plot_surf.py --subid $EPI_base --vol /media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/analysis.c1k.l3.SEED2SEED/8209.Right-LGN.SEED2SEED.ff.nii



afni -niml &
suma -spec $SUBJECTS_DIR/$EPI_base/SUMA/SubjectName_both.spec -sv \
SubjectName_SurfVol+orig



$analysis_c1k_l3_SEED2SEED/8209.Right-LGN.SEED2SEED.ff.nii





fsleyes $seed 

# ###############
# # C10k 
# ###############
# export analysis_c10k_l3_SEED2SEED=$layer4EPI/analysis.c10k.l3.SEED2SEED
# mkdir -p $analysis_c10k_l3_SEED2SEED
# cd $analysis_c10k_l3_SEED2SEED

# # Right_LGN L3 C10k
# SEED2SEED.py --epi $EPI --layers $warp_leakylayers3 --columns $warp_columns_ev_10000 \
# --seed $rois_thalamic/8209.Right-LGN.nii


###############
# FOR LOOP -- C10k 
###############
export analysis_c10k_l3_SEED2SEED=$layer4EPI/analysis.c10k.l3.SEED2SEED
mkdir -p $analysis_c10k_l3_SEED2SEED

cd $analysis_c10k_l3_SEED2SEED

# Right_LGN L3 C1k
SEED2SEED.py --epi $EPI --layers $warp_leakylayers3 \
--columns $warp_columns_ev_10000 \
--seed $seed 


#conda activate pysurfer
#conda run -n pysurfer 
plot_surf.py \
--subid $EPI_base \
--vol $analysis_c10k_l3_SEED2SEED/8209.Right-LGN.SEED2SEED.ff.nii
plot_surf.py \
--subid $EPI_base \
--vol $analysis_c10k_l3_SEED2SEED/8209.Right-LGN.SEED2SEED.fb.nii
plot_surf.py \
--subid $EPI_base \
--vol $analysis_c10k_l3_SEED2SEED/8209.Right-LGN.SEED2SEED.super.nii
plot_surf.py \
--subid $EPI_base \
--vol $analysis_c10k_l3_SEED2SEED/8209.Right-LGN.SEED2SEED.deep.nii
plot_surf.py \
--subid $EPI_base \
--vol $analysis_c10k_l3_SEED2SEED/8209.Right-LGN.SEED2SEED.other.nii





for roi in $rois_thalamic/8209.*
do
    echo $roi
    SEED2SEED.py --epi $EPI --layers $warp_leakylayers3 --columns $warp_columns_ev_10000 \
    --seed $roi 
done  

