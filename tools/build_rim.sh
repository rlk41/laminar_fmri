#!/bin/bash

set -e 

echo "Running 'SUMA_Make_Spec_FS' "
echo "creating meshes and rim file on the MP2RAGE ANAT volume (as opposed to EPI)"
echo "based on Renzo's code https://layerfmri.com/2017/11/26/getting-layers-in-epi-space/#more-115"

#cd $recon_dir 

# running SUMA to create surfaces
@SUMA_Make_Spec_FS -sid subject_name -NIFTI

cd SUMA
#cd $suma_dir
#cp $ANAT_warped ./warped_MP2RAGE.nii


echo "dense mesh starting"
#get dense mesh
MapIcosahedron -spec subject_name_lh.spec -ld 564 -prefix std_lh.ld564. -overwrite
MapIcosahedron -spec subject_name_rh.spec -ld 564 -prefix std_rh.ld564. -overwrite

echo "************************ get surfaces in oblique orientation left"
quickspec -tn gii std_lh.ld564.lh.pial.gii
mv quick.spec std_lh.ld564.lh.pial.spec
quickspec -tn gii std_lh.ld564.lh.smoothwm.gii
mv quick.spec std_lh.ld564.lh.smoothwm.spec
inspec -LRmerge std_lh.ld564.lh.smoothwm.spec std_lh.ld564.lh.pial.spec -detail 2 -prefix std_BOTH.ld564.lh.orient.spec -overwrite

echo " **************************"
echo " get binary mask of surface left"
echo " **************************"
3dSurf2Vol -spec std_lh.ld564.lh.pial.spec -surf_A std_lh.ld564.lh.pial.gii -map_func mask -gridset T1.nii -prefix lh.pial.epi_vol.nii -sv T1.nii -overwrite
3dSurf2Vol -spec std_lh.ld564.lh.smoothwm.spec -surf_A std_lh.ld564.lh.smoothwm.gii -map_func mask -gridset T1.nii -prefix lh.WM.epi_vol.nii -sv T1.nii -overwrite
3dSurf2Vol -spec std_BOTH.ld564.lh.orient.spec -surf_A std_lh.ld564.lh.smoothwm.gii -surf_B std_lh.ld564.lh.pial.gii -sv T1.nii -gridset T1.nii -map_func mask -f_steps 40 -f_index points -f_p1_fr 0.07 -f_pn_fr -0.05 -prefix ribbonmask_564_lh.nii -overwrite
# is fill should be bigger
#3dSurf2Vol -spec std_BOTH.ld564.lh.orient.spec -surf_A std_lh.ld564.lh.smoothwm.obl.gii -surf_B std_lh.ld564.lh.pial.obl.gii -sv T1.nii -gridset scaled_EPI.nii -map_func mask -f_steps 40 -f_index points -f_p1_fr -0.05 -f_pn_fr 0.05 -prefix ribbonmask_564_lh.nii -overwrite

echo " **************************"
echo " *******DONE WITH LEFT HEMISHPERE"
echo " **************************"
echo "************************ get surfaces in oblique orientation left"
quickspec -tn gii std_rh.ld564.rh.pial.gii
mv quick.spec std_rh.ld564.rh.pial.spec
quickspec -tn gii std_rh.ld564.rh.smoothwm.gii
mv quick.spec std_rh.ld564.rh.smoothwm.spec
inspec -LRmerge std_rh.ld564.rh.smoothwm.spec std_rh.ld564.rh.pial.spec -detail 2 -prefix std_BOTH.ld564.rh.orient.spec -overwrite
echo " **************************"
echo " get binary mask of surface right"
echo " **************************"
3dSurf2Vol -spec std_rh.ld564.rh.pial.spec -surf_A std_rh.ld564.rh.pial.gii -map_func mask -gridset T1.nii -prefix rh.pial.epi_vol.nii -sv T1.nii -overwrite
3dSurf2Vol -spec std_rh.ld564.rh.smoothwm.spec -surf_A std_rh.ld564.rh.smoothwm.gii -map_func mask -gridset T1.nii -prefix rh.WM.epi_vol.nii -sv T1.nii -overwrite
3dSurf2Vol -spec std_BOTH.ld564.rh.orient.spec -surf_A std_rh.ld564.rh.smoothwm.gii -surf_B std_rh.ld564.rh.pial.gii -sv T1.nii -gridset T1.nii -map_func mask -f_steps 40 -f_index points -f_p1_fr 0.07 -f_pn_fr -0.05 -prefix ribbonmask_564_rh.nii -overwrite
#3dLocalstat -nbhd 'SPHERE(0.2)' -prefix filled_ribbonmask_564 ribbonmask_564+orig

3dcalc -a ribbonmask_564_rh.nii -b ribbonmask_564_lh.nii -expr 'a + b ' -prefix fill.nii -overwrite
3dcalc -a lh.pial.epi_vol.nii -b rh.pial.epi_vol.nii -expr 'a + b ' -prefix pial_vol.nii -overwrite
3dcalc -a lh.WM.epi_vol.nii -b rh.WM.epi_vol.nii -expr 'a + b ' -prefix WM_vol.nii -overwrite
3dLocalstat -nbhd 'SPHERE(0.3)' -stat mean -overwrite -prefix filled_fill.nii fill.nii
3dcalc -a filled_fill.nii -b fill.nii -expr 'step(step(a-0.5)+b)' -overwrite -prefix filled_fill.nii
3dcalc -a filled_fill.nii -b pial_vol.nii -c WM_vol.nii -expr 'step(a-b-c)' -overwrite -prefix GM_robbon4_manual_corr.nii
3dcalc -a filled_fill.nii -b pial_vol.nii -c WM_vol.nii -expr 'a + b + 2*c ' -prefix rim_auto.nii -overwrite



#mkdir -p $layer_dir
mkdir -p ../LAYNII

# cp filled_fill.nii  ${layer_dir}
# cp pial_vol.nii     ${layer_dir}
# cp WM_vol.nii       ${layer_dir}
# cp rim_auto.nii     ${layer_dir}
# #cp scaled_EPI.nii   ${layer_dir}
# cp $ANAT_bias       ${layer_dir}
# cp GM_robbon4_manual_corr.nii ${layer_dir}

#cd ${layer_dir}
# TODO: i'm not sure why we dont do this earlier
3dcalc -a pial_vol.nii -b WM_vol.nii -c filled_fill.nii -expr 'step(a)+2*step(b)+3*step(c)-3*step(a*c)-3*step(b*c)' -prefix rim.nii -overwrite


cp rim.nii ../LAYNII