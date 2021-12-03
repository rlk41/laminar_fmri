#!/bin/bash 



# ANAT_working_recon-all

# ANAT_ANAT2VASO4_working_ANTs

# ANAT 4
# initial_matrix.txt    ANAT2VASO.4.txt 
# moving                ANAT.bias.nii
# target                VASO_LN.MEAN.bias.nii 

# sbatch --mem=20g --cpus-per-task=50 \
# --output="$logs/ANTS_ANAT2VASO4.log" \
# --time 72:00:00 \
# --job-name="ANTs_ANAT2VASO4" \
# "$scripts_batch_dir/run_ANTS_ANAT2VASO.4.sh"

# jobload -j 26506119

# download to manualy correct and segment 
# freeview \
# $recon_dir/mri/brain.mgz \
# $recon_dir/mri/wm.mgz \
# $ds_dir/ANAT/ANAT_working_bias/c1uncorr.nii \
# $ds_dir/ANAT/ANAT_working_bias/c2uncorr.nii \
# $ds_dir/ANAT/ANAT_working_bias/mask.nii \


## DOWNLOAD TO LAPTOP 

node="cn0905"
# scp $node:/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/mri/brain.mgz . 
# scp $node:/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/mri/wm.mgz .
# scp $node:/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_bias/c1uncorr.nii .
# scp $node:/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_bias/c2uncorr.nii .
# scp $node:/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_bias/mask.nii .



scp $node:/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/mri/brainmask.mgz .
scp $node:/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/mri/orig.mgz .
scp $node:/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/mri/wm.mgz .
scp $node:/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/mri/aseg.mgz .


scp $node:/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/surf/lh.white .
scp $node:/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/surf/lh.pial .
scp $node:/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/surf/rh.white .
scp $node:/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/surf/rh.pial .

scp $node:/data/kleinrl/Wholebrain2.0/ANAT_working_ANTs/inv_EPI.nii . 

freeview \
orig.mgz brainmask.mgz wm.mgz \
-f lh.white -f lh.pial -f rh.white -f rh.pial 



recon-all -autorecon-pial \
  -s $subjid \
  -parallel -openmp 10


# cp brainmask.manualedits5.mgz brainmask.mgz
# cp wm.manualedits3.mgz wm.mgz

sbatch --mem=40g --cpus-per-task=40 \
--output="$logs/main_ANAT.log" \
--time 72:00:00 \
--job-name="main_ANAT" \
"$scripts_dir/main_ANAT.sh"

#jobload -j 26560768

#jobload -j 26585549



"""
evaluate the fit of ANAT_working_ANTs

cd /data/kleinrl/Wholebrain2.0/ANAT_working_ANTs

cp $recon_dir/mri/wm.mgz . 
cp $recon_dir/mri/brainmask.mgz . 

mri_convert wm.mgz wm.nii 
mri_convert brainmask.mgz brainmask.nii 

antsApplyTransforms -d 3 -i wm.nii -o warped_wm.nii -r EPI.nii \
-t registered_1Warp.nii.gz -t registered_0GenericAffine.mat -n BSpline[5]

3dcalc -a warped_wm.nii -datum short -expr 'a' -prefix warped_wm.nii -overwrite

antsApplyTransforms -d 3 -i brainmask.nii -o warped_brainmask.nii -r EPI.nii \
-t registered_1Warp.nii.gz -t registered_0GenericAffine.mat -n BSpline[5]

3dcalc -a warped_brainmask.nii -datum short -expr 'a' -prefix warped_brainmask.nii -overwrite

# IM GOING TO MANUALLY CORRECT THIS 

scp -r cn0852:/data/kleinrl/Wholebrain2.0/ANAT_working_ANTs . 

scp warped_wm.manualedits2.nii cn0852:/data/kleinrl/Wholebrain2.0/ANAT/ANAT2VASO1/warped_wm.manualedits2.nii
scp warped_wm.manualedits2.nii cn0852:/data/kleinrl/Wholebrain2.0/ANAT_working_ANTs/warped_wm.manualedits2.nii

scp warped_brainmask.manualedits3.nii cn0852:/data/kleinrl/Wholebrain2.0/ANAT/ANAT2VASO1/warped_brainmask.manualedits3.nii
scp warped_brainmask.manualedits3.nii cn0852:/data/kleinrl/Wholebrain2.0/ANAT_working_ANTs/warped_brainmask.manualedits3.nii

mri_convert warped_wm.manualedits2.nii warped_wm.manualedits2.mgz
mri_convert warped_brainmask.manualedits3.nii warped_brainmask.manualedits3.mgz



sbatch --mem=40g --cpus-per-task=40 \
--output="$logs/main_ANAT_ANAT2VASO.log" \
--time 72:00:00 \
--job-name="main_ANAT_ANAT2VASO1" \
"$scripts_dir/main_ANAT_ANAT2VASO1.sh"

jobload -j 26602038

after initial 

cd /data/kleinrl/Wholebrain2.0/ANAT/ANAT2VASO1

echo $ANTs_reg_1warp_inverse
echo $ANTs_reg_0GenAffine
source_ANAT2VASO1



warp_ANTS_resampleCu_inverse.sh warped_brainmask.manualedits3.nii MP2RAGE.nii
warp_ANTS_resampleCu_inverse.sh warped_wm.manualedits2.nii MP2RAGE.nii

3dcalc -a inv_warped_wm.manualedits2.nii -expr 'ispositive(a-100)' -prefix inv_warped_wm.manualedits2.thresh.nii


mri_convert inv_warped_wm.manualedits2.nii inv_warped_wm.manualedits2.mgz
mri_convert inv_warped_brainmask.manualedits3.nii inv_warped_brainmask.manualedits3.mgz
mri_convert inv_warped_wm.manualedits2.thresh.nii inv_warped_wm.manualedits2.thresh.mgz




cp inv_*.mgz /data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/mri

source_wholebrain 

recon-all -autorecon-pial \
  -s $subjid \
  -parallel -openmp 40

cp -r ANAT ANAT_postpial-witherrors

recon-all -autorecon2-wm -autorecon3 \
  -s $subjid \
  -parallel -openmp 40

sbatch --mem=40g --cpus-per-task=40 \
--output="$logs/main_ANAT-fix-WM-AR3.log" \
--time 72:00:00 \
--job-name="main_ANAT_fixWM-AR3" \
"$scripts_dir/main_ANAT.sh"

sbatch --mem=40g --cpus-per-task=10 \
--output="$logs/main_ANAT-makesurfaces-SUMA.log" \
--time 72:00:00 \
--job-name="main_ANAT_makesurfaces-SUMA" \
"$scripts_dir/main_ANAT.sh"

# I SEEM TO BE ABLE TO WARP THE MANUAL EDITS INTO ANAT SPACE 
# AND BUILD SURFACES HERE -- I'LL HAVE TO BUID RIM HERE AND WARP TO VASO 


source_ANAT2VASO1 
cd $ANTs_dir 
warp_ANTS_resampleCu_inverse.sh EPI.nii MP2RAGE.nii




#warp files into VASO run autorecon3 in VASO space to regen surfs


scp 




source_ANAT2VASO1 

3dcalc -a warped_wm.manualedits2.nii -expr 'ispositive(a-100)' -prefix warped_wm.manualedits2.thresh.nii
mri_convert warped_wm.manualedits2.thresh.nii warped_wm.manualedits2.thresh.mgz
cp warped_wm.manualedits2.thresh.mgz $recon_dir/mri/

cp $recon_dir/mri/warped_wm.manualedits2.thresh.mgz $recon_dir/mri/wm.mgz

# I HAVENT BEEN ABLE TO BUILD SURFACES IN VASO USING MANUALLY EDITIED FILES



node="cn0905"

scp $node:/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/mri/brainmask.mgz .
scp $node:/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/mri/orig.mgz .
scp $node:/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/mri/wm.mgz .
scp $node:/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/mri/aseg.mgz .


scp $node:/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/surf/lh.white .
scp $node:/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/surf/lh.pial .
scp $node:/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/surf/rh.white .
scp $node:/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/surf/rh.pial .

scp $node:/data/kleinrl/Wholebrain2.0/ANAT_working_ANTs/inv_EPI.nii . 



sbatch --mem=40g --cpus-per-task=40 \
--output="$logs/main_ANAT-fix-WM-AR3-2.log" \
--time 72:00:00 \
--job-name="main_ANAT_fixWM-AR3-2" \
"$scripts_dir/main_ANAT.sh"

"""


sbatch --mem=40g --cpus-per-task=40 \
--output="$logs/main_ANAT_VASO2ANAT.log" \
--time 72:00:00 \
--job-name="main_ANAT_VASO2ANAT" \
"$scripts_dir/main_ANAT_VASO2ANAT.sh"





sbatch --mem=40g --cpus-per-task=40 \
--output="$logs/main_ANAT_inv_EPI.log" \
--time 72:00:00 \
--job-name="main_ANAT_inv_EPI" \
"$scripts_dir/main_ANAT_inv_EPI.sh"





sbatch --mem=40g --cpus-per-task=40 \
--output="$logs/main_ANAT-SUMA-LAYNI-couldntfixWM.log" \
--time 72:00:00 \
--job-name="main_ANAT_LAYNI-NOfixWM" \
"$scripts_dir/main_ANAT.sh"

# export VASO_mean4d="$ds_dir/VASO_LN.MEAN4D.nii.gz"
# export renzo_layers="$ds_dir/ANAT/dwscaled_layers.nii"
# export rim="$ds_dir/ANAT/rim.nii"

# 3dMean -prefix $VASO_mean4d ${EPIs[@]}


# 3dmerge -gmean 

# cd $ds_dir/ANAT

# mkdir -p layers

# #3dcalc -a $renzo_layers -expr 'ispositive(a)*3' -prefix rim.nii -overwrite

# cp ../dwscaled_layers.nii . 


# export renzo_layers="/data/kleinrl/Wholebrain2.0/ANAT/dwscaled_layers.nii"

# 3dcalc -a $renzo_layers -expr 'ispositive(a-6)'   -prefix gm_outer_1.nii -overwrite
# 3dcalc -a $renzo_layers -expr 'and(ispositive(a),isnegative(a-2))'   -prefix gm_inner_2.nii -overwrite
# 3dcalc -a $renzo_layers -expr 'and(ispositive(a-1), isnegative(a-7))'   -prefix gm_middle_3.nii -overwrite
# 3dcalc -a gm_outer_1.nii -b gm_middle_3.nii -c gm_inner_2.nii -expr '(a*1)+(b*3)+(c*2)'   -prefix rim.nii -overwrite

# LN2_LAYERS -rim rim.nii

# LN2_COLUMNS -rim rim.nii -nr_columns 10000 -midgm rim_midGM_equidist.nii 



# export ANTs_dir=$ds_dir/ANAT2VASO+mask_working_ANTs

# mkdir -p $ANTs_dir

# cp mask.nii $ANTs_dir
# cp ANAT2VASO.2.txt $ANTs_dir/initial_matrix.txt

# sbatch --mem=20g --cpus-per-task=50 \
# --output="$logs/ANTS_ANAT2VASO+mask_wholebrain.log" \
# --time 72:00:00 \
# --job-name="ANTs_mask" \
# "$scripts_batch_dir/run_ANT_mask.sh"


#itksnap -g $ds_dir/VASO_LN.mean.bias.nii -o ${ANAT_bias}  --scale 1

# cd $ANTs_dir

# run_ANT_mask.sh -a $ANAT_bias -e ../VASO_LN.MEAN.nii





# source_wholebrain2.0
# export ANTs_dir="$ds_dir/ANAT_newinitxfm_working_ANTs"
# mkdir -p $ANTs_dir 
# cd $ds_dir 
# cp ANAT2VASO.2.txt $ANTs_dir/initial_matrix.txt

# sbatch --mem=20g --cpus-per-task=50 \
# --output="$logs/ANTS_wb_newinit.log" \
# --time 72:00:00 \
# --job-name="ANTs_wb_newinit" \
# "$scripts_batch_dir/run_ANTS_wb.sh"



# # ANAT_2 
# cd /data/kleinrl/Wholebrain2.0/ANAT/ANAT_2_working_recon-all/ANAT_2/mri

# mri_vol2vol --mov brain.mgz --targ rawavg.mgz --regheader --o brain-in-rawavg.mgz --no-save-reg --inv --xfm transforms/talairach.xfm 




# mri_vol2vol --mov brain.mgz --fstarg  --reg register.dat --o brain-in-rawavg.mgz --no-save-reg
# mri_vol2vol --mov brain.mgz --targ rawavg.mgz --s --o brain-in-rawavg.mgz --no-save-reg

# mri_vol2vol --reg transforms/talairach.lta --mov brain.mgz --targ orig.mgz --inv --o brain-in-rawavg.mgz

# mri_convert brain.mgz brain.nii 
# mri_convert rawavg.mgz rawavg.nii 

# 3dresample -master rawavg.nii -prefix brain.rs2rawavg.nii -input brain.nii 






# ANAT 4
# initial_matrix.txt    ANAT2VASO.4.txt 
# moving                ANAT.bias.nii
# target                VASO_LN.MEAN.bias.nii 

# sbatch --mem=20g --cpus-per-task=50 \
# --output="$logs/ANTS_ANAT2VASO4.log" \
# --time 72:00:00 \
# --job-name="ANTs_ANAT2VASO4" \
# "$scripts_batch_dir/run_ANTS_ANAT2VASO.4.sh"

# 26506119


# ANAT 4
# initial_matrix.txt    ANAT2VASO.4.txt 
# moving                ANAT.bias.nii
# target                VASO_LN.MEAN.bias.nii 
# mask 


# sbatch --mem=20g --cpus-per-task=50 \
# --output="$logs/ANTS_ANAT2VASO4_mask.log" \
# --time 72:00:00 \
# --job-name="ANTs_ANAT2VASO4_mask" \
# "$scripts_batch_dir/run_ANTS_ANAT2VASO4mask.sh"

