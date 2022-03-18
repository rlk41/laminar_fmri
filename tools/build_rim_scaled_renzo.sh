#!/bin/bash

set -e 



# scaled_EPI
# EPI 
# warped MPRAGE 

#cp -r SUMA SUMA_2 
#cd SUMA_2

#cp $scaled_EPI . 
#cp $EPI . 
#cp $ANAT . 

#cd $recon_dir/SUMA_2
cd SUMA_2 

3dWarp -card2oblique $scaled_EPI_master -verb $ANAT -overwrite > orinentfile.txt
echo "dense mesh starting"
#get dense mesh
MapIcosahedron -spec subject_name_lh.spec -ld 564 -prefix std_lh.ld564. -overwrite
MapIcosahedron -spec subject_name_rh.spec -ld 564 -prefix std_rh.ld564. -overwrite
echo "************************ get surfaces in oblique orientation left"
ConvertSurface -xmat_1D orinentfile.txt -i std_lh.ld564.lh.pial.gii -o std_lh.ld564.lh.pial.obl.gii -overwrite
ConvertSurface -xmat_1D orinentfile.txt -i std_lh.ld564.lh.smoothwm.gii -o std_lh.ld564.lh.smoothwm.obl.gii -overwrite
#get spec for the new file
quickspec -tn gii std_lh.ld564.lh.pial.obl.gii
mv quick.spec std_lh.ld564.lh.pial.obl.spec
quickspec -tn gii std_lh.ld564.lh.smoothwm.obl.gii
mv quick.spec std_lh.ld564.lh.smoothwm.obl.spec
inspec -LRmerge std_lh.ld564.lh.smoothwm.obl.spec std_lh.ld564.lh.pial.obl.spec -detail 2 -prefix std_BOTH.ld564.lh.orient.spec -overwrite
echo " **************************"
echo " get binary mask of surface left"
echo " **************************"
3dSurf2Vol -spec std_lh.ld564.lh.pial.obl.spec -surf_A std_lh.ld564.lh.pial.obl.gii -map_func mask -gridset $scaled_EPI_master -prefix lh.pial.epi_vol.nii -sv T1.nii -overwrite
3dSurf2Vol -spec std_lh.ld564.lh.smoothwm.obl.spec -surf_A std_lh.ld564.lh.smoothwm.obl.gii -map_func mask -gridset $scaled_EPI_master -prefix lh.WM.epi_vol.nii -sv T1.nii -overwrite
3dSurf2Vol -spec std_BOTH.ld564.lh.orient.spec -surf_A std_lh.ld564.lh.smoothwm.obl.gii -surf_B std_lh.ld564.lh.pial.obl.gii -sv T1.nii -gridset $scaled_EPI_master -map_func mask -f_steps 40 -f_index points -f_p1_fr 0.07 -f_pn_fr -0.05 -prefix ribbonmask_564_lh.nii -overwrite
# is fill should be bigger
#3dSurf2Vol -spec std_BOTH.ld564.lh.orient.spec -surf_A std_lh.ld564.lh.smoothwm.obl.gii -surf_B std_lh.ld564.lh.pial.obl.gii -sv T1.nii -gridset scaled_EPI_master.nii -map_func mask -f_steps 40 -f_index points -f_p1_fr -0.05 -f_pn_fr 0.05 -prefix ribbonmask_564_lh.nii -overwrite
echo " **************************"
echo " *******DONE WITH LEFT HEMISHPERE"
echo " **************************"
echo "************************ get surfaces in oblique orientation left"
ConvertSurface -xmat_1D orinentfile.txt -i std_rh.ld564.rh.pial.gii -o std_rh.ld564.rh.pial.obl.gii -overwrite
ConvertSurface -xmat_1D orinentfile.txt -i std_rh.ld564.rh.smoothwm.gii -o std_rh.ld564.rh.smoothwm.obl.gii -overwrite
#get spec for the new file
quickspec -tn gii std_rh.ld564.rh.pial.obl.gii
mv quick.spec std_rh.ld564.rh.pial.obl.spec
quickspec -tn gii std_rh.ld564.rh.smoothwm.obl.gii
mv quick.spec std_rh.ld564.rh.smoothwm.obl.spec
inspec -LRmerge std_rh.ld564.rh.smoothwm.obl.spec std_rh.ld564.rh.pial.obl.spec -detail 2 -prefix std_BOTH.ld564.rh.orient.spec -overwrite
echo " **************************"
echo " get binary mask of surface right"
echo " **************************"
3dSurf2Vol -spec std_rh.ld564.rh.pial.obl.spec -surf_A std_rh.ld564.rh.pial.obl.gii -map_func mask -gridset $scaled_EPI_master -prefix rh.pial.epi_vol.nii -sv T1.nii -overwrite
3dSurf2Vol -spec std_rh.ld564.rh.smoothwm.obl.spec -surf_A std_rh.ld564.rh.smoothwm.obl.gii -map_func mask -gridset $scaled_EPI_master -prefix rh.WM.epi_vol.nii -sv T1.nii -overwrite
3dSurf2Vol -spec std_BOTH.ld564.rh.orient.spec -surf_A std_rh.ld564.rh.smoothwm.obl.gii -surf_B std_rh.ld564.rh.pial.obl.gii -sv T1.nii -gridset $scaled_EPI_master -map_func mask -f_steps 40 -f_index points -f_p1_fr 0.07 -f_pn_fr -0.05 -prefix ribbonmask_564_rh.nii -overwrite
#3dLocalstat -nbhd 'SPHERE(0.2)' -prefix filled_ribbonmask_564 ribbonmask_564+orig
3dcalc -a ribbonmask_564_rh.nii -b ribbonmask_564_lh.nii -expr 'a + b ' -prefix fill.nii -overwrite
3dcalc -a lh.pial.epi_vol.nii -b rh.pial.epi_vol.nii -expr 'a + b ' -prefix pial_vol.nii -overwrite
3dcalc -a lh.WM.epi_vol.nii -b rh.WM.epi_vol.nii -expr 'a + b ' -prefix WM_vol.nii -overwrite
3dLocalstat -nbhd 'SPHERE(0.3)' -stat mean -overwrite -prefix filled_fill.nii fill.nii
3dcalc -a filled_fill.nii -b fill.nii -expr 'step(step(a-0.5)+b)' -overwrite -prefix filled_fill.nii
3dcalc -a filled_fill.nii -b pial_vol.nii -c WM_vol.nii -expr 'step(a-b-c)' -overwrite -prefix GM_robbon4_manual_corr.nii
3dcalc -a filled_fill.nii -b pial_vol.nii -c WM_vol.nii -expr 'a + b + 2*c ' -prefix rim_auto.nii -overwrite



#mkdir -p ${layer_dir}_2
mkdir -p ../LAYNII_2

# cp filled_fill.nii  ${layer_dir}_2
# cp pial_vol.nii     ${layer_dir}_2
# cp WM_vol.nii       ${layer_dir}_2
# cp rim_auto.nii     ${layer_dir}_2
# #cp scaled_EPI.nii   ${layer_dir}
# cp $ANAT_bias       ${layer_dir}_2
# cp GM_robbon4_manual_corr.nii ${layer_dir}_2

# cd ${layer_dir}_2
# TODO: i'm not sure why we dont do this earlier
3dcalc -a pial_vol.nii -b WM_vol.nii -c filled_fill.nii -expr 'step(a)+2*step(b)+3*step(c)-3*step(a*c)-3*step(b*c)' -prefix rim.nii -overwrite
cp rim.nii ../LAYNII_2 