
export analysis_hcp_l3_SEED2SEED="$layer4EPI/analysis.hcp.l3.SEED2SEED"
export cmds_SEED2SEED_hcpl3="$layer4EPI/cmds/cmds.SEED2SEED.hcp.l3.txt"

#rm $cmds_SEED2SEED

for seed in $rois_hcpl3/*; do 

echo "/home/richard/Projects/laminar_fmri/tools/SEED2SEED.py --epi $EPI --layers $warp_leakylayers3 \
--columns $warp_hcp \
--seed $seed \
--outdir $analysis_hcp_l3_SEED2SEED/$(basename $seed .nii)" >> $cmds_SEED2SEED_hcpl3
done 

parallel --jobs 1 < $cmds_SEED2SEED_hcpl3


# conda activate pysurfer 
cd $analysis_hcp_l3_SEED2SEED/1001.L_V1.1

seed=$rois_hcpl3/1001.L_V1.1.nii


plot_surf.py \
--subid $EPI_base \
--vol *.ff.nii \
--seed $seed

plot_surf.py \
--subid $EPI_base \
--vol *.fb.nii \
--seed $seed

plot_surf.py \
--subid $EPI_base \
--vol *.deep.nii \
--seed $seed

plot_surf.py \
--subid $EPI_base \
--vol *.super.nii \
--seed $seed

plot_surf.py \
--subid $EPI_base \
--vol *.other.nii \
--seed $seed





plot_surf.py \
--subid $EPI_base \
--vol $analysis_hcp_l3_SEED2SEED/1001.L_V1.1.SEED2SEED.fb.nii

plot_surf.py \
--subid $EPI_base \
--vol $analysis_hcp_l3_SEED2SEED/1001.L_V1.1.SEED2SEED.deep.nii

plot_surf.py \
--subid $EPI_base \
--vol $analysis_hcp_l3_SEED2SEED/1001.L_V1.1.SEED2SEED.super.nii

