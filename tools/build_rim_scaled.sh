#!/bin/bash

# echo "Running 'SUMA_Make_Spec_FS' "
# echo "creating meshes and rim file on the MP2RAGE ANAT volume (as opposed to EPI)"
# echo "based on Renzo's code https://layerfmri.com/2017/11/26/getting-layers-in-epi-space/#more-115"

# cd $recon_dir 

# # running SUMA to create surfaces
# @SUMA_Make_Spec_FS -sid subject_name -NIFTI

# cp -r $suma_dir $scaled_suma_dir

# cd $scaled_suma_dir
# #cp $ANAT_warped ./warped_MP2RAGE.nii

# delta_x=$(3dinfo -di T1.nii)
# delta_y=$(3dinfo -dj T1.nii)
# delta_z=$(3dinfo -dk T1.nii)
# sdelta_x=$(echo "(($delta_x / 4))"|bc -l)
# sdelta_y=$(echo "(($delta_x / 4))"|bc -l)
# sdelta_z=$(echo "(($delta_z / 4))"|bc -l)
# echo "$sdelta_x"
# echo "$sdelta_y"
# echo "$sdelta_z"
# 3dresample -dxyz $sdelta_x $sdelta_y $sdelta_z -rmode Cu -overwrite -prefix scaled_T1.nii -input T1.nii
# #get obliquity matrix




# echo "dense mesh starting"
# #get dense mesh
# MapIcosahedron -spec subject_name_lh.spec -ld 564 -prefix std_lh.ld564. -overwrite
# MapIcosahedron -spec subject_name_rh.spec -ld 564 -prefix std_rh.ld564. -overwrite

# echo "************************ get surfaces in oblique orientation left"
# quickspec -tn gii std_lh.ld564.lh.pial.gii
# mv quick.spec std_lh.ld564.lh.pial.spec
# quickspec -tn gii std_lh.ld564.lh.smoothwm.gii
# mv quick.spec std_lh.ld564.lh.smoothwm.spec
# inspec -LRmerge std_lh.ld564.lh.smoothwm.spec std_lh.ld564.lh.pial.spec -detail 2 -prefix std_BOTH.ld564.lh.orient.spec -overwrite

# echo " **************************"
# echo " get binary mask of surface left"
# echo " **************************"
# 3dSurf2Vol -spec std_lh.ld564.lh.pial.spec     -surf_A std_lh.ld564.lh.pial.gii     -map_func mask -gridset T1.nii -prefix lh.pial.epi_vol.nii -sv T1.nii -overwrite
# 3dSurf2Vol -spec std_lh.ld564.lh.smoothwm.spec -surf_A std_lh.ld564.lh.smoothwm.gii -map_func mask -gridset T1.nii -prefix lh.WM.epi_vol.nii -sv T1.nii -overwrite
# 3dSurf2Vol -spec std_BOTH.ld564.lh.orient.spec -surf_A std_lh.ld564.lh.smoothwm.gii -surf_B std_lh.ld564.lh.pial.gii -sv T1.nii -gridset T1.nii -map_func mask -f_steps 40 -f_index points -f_p1_fr 0.07 -f_pn_fr -0.05 -prefix ribbonmask_564_lh.nii -overwrite

###################
echo "scaled" 
3dSurf2Vol -spec std_lh.ld564.lh.pial.spec     -surf_A std_lh.ld564.lh.pial.gii     -map_func mask -gridset $scaled_EPI -prefix lh.pial.epi_vol.scaled.nii -sv T1.nii -overwrite
3dSurf2Vol -spec std_lh.ld564.lh.smoothwm.spec -surf_A std_lh.ld564.lh.smoothwm.gii -map_func mask -gridset $scaled_EPI -prefix lh.WM.epi_vol.scaled.nii -sv T1.nii -overwrite
3dSurf2Vol -spec std_BOTH.ld564.lh.orient.spec -surf_A std_lh.ld564.lh.smoothwm.gii -surf_B std_lh.ld564.lh.pial.gii -sv T1.nii -gridset $scaled_EPI -map_func mask -f_steps 40 -f_index points -f_p1_fr 0.07 -f_pn_fr -0.05 -prefix ribbonmask_564_lh.scaled.nii -overwrite
##################



# # is fill should be bigger
# #3dSurf2Vol -spec std_BOTH.ld564.lh.orient.spec -surf_A std_lh.ld564.lh.smoothwm.obl.gii -surf_B std_lh.ld564.lh.pial.obl.gii -sv T1.nii -gridset scaled_EPI.nii -map_func mask -f_steps 40 -f_index points -f_p1_fr -0.05 -f_pn_fr 0.05 -prefix ribbonmask_564_lh.nii -overwrite

# echo " **************************"
# echo " *******DONE WITH LEFT HEMISHPERE"
# echo " **************************"
# echo "************************ get surfaces in oblique orientation left"
# quickspec -tn gii std_rh.ld564.rh.pial.gii
# mv quick.spec std_rh.ld564.rh.pial.spec
# quickspec -tn gii std_rh.ld564.rh.smoothwm.gii
# mv quick.spec std_rh.ld564.rh.smoothwm.spec
# inspec -LRmerge std_rh.ld564.rh.smoothwm.spec std_rh.ld564.rh.pial.spec -detail 2 -prefix std_BOTH.ld564.rh.orient.spec -overwrite
# echo " **************************"
# echo " get binary mask of surface right"
# echo " **************************"
# 3dSurf2Vol -spec std_rh.ld564.rh.pial.spec -surf_A std_rh.ld564.rh.pial.gii -map_func mask -gridset T1.nii -prefix rh.pial.epi_vol.nii -sv T1.nii -overwrite
# 3dSurf2Vol -spec std_rh.ld564.rh.smoothwm.spec -surf_A std_rh.ld564.rh.smoothwm.gii -map_func mask -gridset T1.nii -prefix rh.WM.epi_vol.nii -sv T1.nii -overwrite
# 3dSurf2Vol -spec std_BOTH.ld564.rh.orient.spec -surf_A std_rh.ld564.rh.smoothwm.gii -surf_B std_rh.ld564.rh.pial.gii -sv T1.nii -gridset T1.nii -map_func mask -f_steps 40 -f_index points -f_p1_fr 0.07 -f_pn_fr -0.05 -prefix ribbonmask_564_rh.nii -overwrite
# #3dLocalstat -nbhd 'SPHERE(0.2)' -prefix filled_ribbonmask_564 ribbonmask_564+orig


3dSurf2Vol -spec std_rh.ld564.rh.pial.spec -surf_A std_rh.ld564.rh.pial.gii -map_func mask -gridset $scaled_EPI -prefix rh.pial.epi_vol.scaled.nii -sv T1.nii -overwrite
3dSurf2Vol -spec std_rh.ld564.rh.smoothwm.spec -surf_A std_rh.ld564.rh.smoothwm.gii -map_func mask -gridset $scaled_EPI -prefix rh.WM.epi_vol.scaled.nii -sv T1.nii -overwrite
3dSurf2Vol -spec std_BOTH.ld564.rh.orient.spec -surf_A std_rh.ld564.rh.smoothwm.gii -surf_B std_rh.ld564.rh.pial.gii -sv T1.nii -gridset $scaled_EPI -map_func mask -f_steps 40 -f_index points -f_p1_fr 0.07 -f_pn_fr -0.05 -prefix ribbonmask_564_rh.scaled.nii -overwrite
#3dLocalstat -nbhd 'SPHERE(0.2)' -prefix filled_ribbonmask_564 ribbonmask_564+orig




3dcalc -a ribbonmask_564_rh.scaled.nii -b ribbonmask_564_lh.scaled.nii -expr 'a + b ' -prefix fill.scaled.nii -overwrite
3dcalc -a lh.pial.epi_vol.scaled.nii -b rh.pial.epi_vol.scaled.nii -expr 'a + b ' -prefix pial_vol.scaled.nii -overwrite
3dcalc -a lh.WM.epi_vol.scaled.nii -b rh.WM.epi_vol.scaled.nii -expr 'a + b ' -prefix WM_vol.scaled.nii -overwrite
3dLocalstat -nbhd 'SPHERE(0.3)' -stat mean -overwrite -prefix filled_fill.scaled.nii fill.scaled.nii
3dcalc -a filled_fill.scaled.nii -b fill.scaled.nii -expr 'step(step(a-0.5)+b)' -overwrite -prefix filled_fill.scaled.nii
3dcalc -a filled_fill.scaled.nii -b pial_vol.scaled.nii -c WM_vol.scaled.nii -expr 'step(a-b-c)' -overwrite -prefix GM_robbon4_manual_corr.scaled.nii
3dcalc -a filled_fill.scaled.nii -b pial_vol.scaled.nii -c WM_vol.scaled.nii -expr 'a + b + 2*c ' -prefix rim_auto.scaled.nii -overwrite



#mkdir -p $layer_dir

#cp filled_fill.scaled.nii  ${layer_dir}
#cp pial_vol.scaled.nii     ${layer_dir}
#cp WM_vol.scaled.nii       ${layer_dir}
#cp rim_auto.scaled.nii     ${layer_dir}
#cp scaled_EPI.nii   ${layer_dir}
#cp $ANAT_bias       ${layer_dir}
#cp GM_robbon4_manual_corr.scaled.nii ${layer_dir}

3dcalc -a pial_vol.scaled.nii -b WM_vol.scaled.nii -c filled_fill.scaled.nii -expr 'step(a)+2*step(b)+3*step(c)-3*step(a*c)-3*step(b*c)' -prefix rim.scaled.nii -overwrite

#cp rim.scaled.nii ${layer_dir}

#cd ${layer_dir}
