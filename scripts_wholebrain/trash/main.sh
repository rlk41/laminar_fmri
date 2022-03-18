
# spm for motion correction and segmentation
# https://layerfmri.com/2017/11/26/getting-layers-in-epi-space/



i='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/derivatives/sub-01/average_across_days/VASO_LN_across_days.ihc.mean.nii'
i_path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/derivatives/sub-01/average_across_days'

cd ${i_path}
cp ${i} uncorr.nii

cp /home/richard/bin/layerfmri_repo/bias_field_corr/Bias_field_script_job.m ./Bias_field_script_job.m
matlab -nodesktop -nosplash -r "cd ${i_path}; addpath(genpath('/home/richard/matlab_toolbox')); run('${i_path}/Bias_field_script_job.m')"


3dcalc -a muncorr.nii -prefix muncorr.nii -overwrite -expr 'a' -datum short
rm uncorr.nii
mv muncorr.nii ${i_path}/muncorr.nii




# ITK SNAP -
#   1. manual align
#   2. automatic align
#   3. export registration as initial_matrix.txt
#   4. run ANTs
#   5. recon-all
#         fix wm
#         fix pial



#mat='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/derivatives/sub-01/average_across_days/affine_MI_SEG_4x_2x_v2_USE.txt'
mat='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/derivatives/sub-01/average_across_days/initial_matrix.txt'
MP2RAGE='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w.nii'
EPI='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/derivatives/sub-01/average_across_days/muncorr.nii'
#ANAT2EPI='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w.affine_MI_SEG_4x_2x_v2_USE.nii'


w='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/getting-layers-in-epi-space'
cd $w

# copy to working directory
cp ${mat} initial_matrix.txt
cp ${EPI}  EPI.nii
cp ${MP2RAGE} MP2RAGE.nii

#cp ${ANAT2EPI} MP2RAGE.nii


#antsApplyTransforms --interpolation BSpline[5] -d 3 -i ${MP2RAGE} -r ${EPI} -t ${mat} -o ${ANAT2EPI}
antsApplyTransforms --interpolation BSpline[5] -d 3 -i MP2RAGE.nii -r EPI.nii -t initial_matrix.txt -o registered_applied.nii

freeview  MP2RAGE.nii EPI.nii  registered_applied.nii


echo "I expect 2 filed. the T1_weighted EPI.nii and a MP2RAGE_orig.nii"
#  bet MP2RAGE_orig.nii MP2RAGE.nii -f 0.05
3dcalc -a MP2RAGE.nii -datum short -expr 'a' -prefix MP2RAGE.nii -overwrite
ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=45
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS
echo "*****************************************"
echo "************* starting with ANTS ********"
echo "*****************************************"
#2 steps
antsRegistration \
--verbose 1 \
--dimensionality 3 \
--float 1 \
--output [registered_,registered_Warped.nii.gz,registered_InverseWarped.nii.gz] \
--interpolation Linear \
--use-histogram-matching 0 \
--winsorize-image-intensities [0.005,0.995] \
--initial-moving-transform initial_matrix.txt \
--transform Rigid[0.05] \
--metric CC[EPI.nii,MP2RAGE.nii,0.7,32,Regular,0.1] \
--convergence [1000x500,1e-6,10] \
--shrink-factors 2x1 \
--smoothing-sigmas 1x0vox \
--transform Affine[0.1] \
--metric MI[EPI.nii,MP2RAGE.nii,0.7,32,Regular,0.1] \
--convergence [1000x500,1e-6,10] \
--shrink-factors 2x1 \
--smoothing-sigmas 1x0vox \
--transform SyN[0.1,2,0] \
--metric CC[EPI.nii,MP2RAGE.nii,1,2] \
--convergence [500x100,1e-6,10] \
--shrink-factors 2x1 \
--smoothing-sigmas 1x0vox

#antsApplyTransforms -d 3 -i MP2RAGE.nii -o warped_MP2RAGE.nii -r MP2RAGE.nii-t registered_1Warp.nii.gz -t registered_0GenericAffine.mat
antsApplyTransforms -d 3 -i MP2RAGE.nii -o warped_MP2RAGE.nii -r MP2RAGE.nii -t registered_1Warp.nii.gz -t registered_0GenericAffine.mat

3dcalc -a warped_MP2RAGE.nii -datum short -expr 'a' -prefix warped_MP2RAGE.nii -overwrite




# warped_MP2RAGE
SUBJECTS_DIR='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects'
i_path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/getting-layers-in-epi-space'
file='warped_MP2RAGE'
recon_dir=${SUBJECTS_DIR}/${file}
i=${i_path}'/warped_MP2RAGE.nii'
epi=${i_path}'/EPI.nii'
mp2rage = i
# freeview $i $epi

recon-all -all -hires \
  -i ${i} \
  -subjid ${file} \
  -parallel -openmp 40 \
  -expert ${SUBJECTS_DIR}/expert.opts


'''
fixed wm.mgz in freeview wm.manualedit_2,3.mgz
cp wm.mgz wm.backup.mgz
cp wm.manualedit_3.mgz wm.mgz
'''
SUBJECTS_DIR='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects'
i_path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/getting-layers-in-epi-space'
file='warped_MP2RAGE'
recon_dir=${SUBJECTS_DIR}/${file}
i=${i_path}'/warped_MP2RAGE.nii'
epi=${i_path}'/EPI.nii'

recon-all -autorecon2-wm -hires \
  -subjid ${file} \
  -parallel -openmp 40 \

recon-all -autorecon3 -hires \
  -subjid ${file} \
  -parallel -openmp 40 \


freeview -v mri/T1.mgz \
-f surf/lh.white:edgecolor=yellow \
-f surf/lh.pial:edgecolor=red \
-f surf/rh.white:edgecolor=yellow \
-f surf/rh.pial:edgecolor=red


# fix pial surface - brainmask.manualedits.mgz
# cp brainmask.mgz brainmask.backup.mgz
# cp brainmask.manualedit_4.mgz brainmask.mgz
recon-all -autorecon-pial -hires \
  -subjid ${file} \
  -parallel -openmp 40



cd $(recon_dir)

@SUMA_Make_Spec_FS -sid subject_name -NIFTI
cd SUMA
#cp ../../EPI.nii ./
#cp ../../warped_MP2RAGE.nii ./
cp ${epi} .
cp ${mp2rage} .

layer_dir='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/getting-layers-in-epi-space'

echo "************* upscaling EPI.nii ******************************"
#module load afni
delta_x=$(3dinfo -di EPI.nii)
delta_y=$(3dinfo -dj EPI.nii)
delta_z=$(3dinfo -dk EPI.nii)
sdelta_x=$(echo "(($delta_x / 4))"|bc -l)
sdelta_y=$(echo "(($delta_x / 4))"|bc -l)
sdelta_z=$(echo "(($delta_z / 4))"|bc -l)
echo "$sdelta_x"
echo "$sdelta_y"
echo "$sdelta_z"
3dresample -dxyz $sdelta_x $sdelta_y $sdelta_z -rmode Li -overwrite -prefix scaled_EPI.nii -input EPI.nii
#get obliquity matrix
3dWarp -card2oblique EPI.nii -verb warped_MP2RAGE.nii -overwrite > orinentfile.txt
# 3dWarp -card2oblique EPI.nii -verb warped_MP2RAGE.nii -overwrite &amp;gt; orinentfile.txt

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
3dSurf2Vol -spec std_lh.ld564.lh.pial.obl.spec -surf_A std_lh.ld564.lh.pial.obl.gii -map_func mask -gridset scaled_EPI.nii -prefix lh.pial.epi_vol.nii -sv T1.nii -overwrite
3dSurf2Vol -spec std_lh.ld564.lh.smoothwm.obl.spec -surf_A std_lh.ld564.lh.smoothwm.obl.gii -map_func mask -gridset scaled_EPI.nii -prefix lh.WM.epi_vol.nii -sv T1.nii -overwrite
3dSurf2Vol -spec std_BOTH.ld564.lh.orient.spec -surf_A std_lh.ld564.lh.smoothwm.obl.gii -surf_B std_lh.ld564.lh.pial.obl.gii -sv T1.nii -gridset scaled_EPI.nii -map_func mask -f_steps 40 -f_index points -f_p1_fr 0.07 -f_pn_fr -0.05 -prefix ribbonmask_564_lh.nii -overwrite
# is fill should be bigger
#3dSurf2Vol -spec std_BOTH.ld564.lh.orient.spec -surf_A std_lh.ld564.lh.smoothwm.obl.gii -surf_B std_lh.ld564.lh.pial.obl.gii -sv T1.nii -gridset scaled_EPI.nii -map_func mask -f_steps 40 -f_index points -f_p1_fr -0.05 -f_pn_fr 0.05 -prefix ribbonmask_564_lh.nii -overwrite

# do

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
3dSurf2Vol -spec std_rh.ld564.rh.pial.obl.spec -surf_A std_rh.ld564.rh.pial.obl.gii -map_func mask -gridset scaled_EPI.nii -prefix rh.pial.epi_vol.nii -sv T1.nii -overwrite
3dSurf2Vol -spec std_rh.ld564.rh.smoothwm.obl.spec -surf_A std_rh.ld564.rh.smoothwm.obl.gii -map_func mask -gridset scaled_EPI.nii -prefix rh.WM.epi_vol.nii -sv T1.nii -overwrite
3dSurf2Vol -spec std_BOTH.ld564.rh.orient.spec -surf_A std_rh.ld564.rh.smoothwm.obl.gii -surf_B std_rh.ld564.rh.pial.obl.gii -sv T1.nii -gridset scaled_EPI.nii -map_func mask -f_steps 40 -f_index points -f_p1_fr 0.07 -f_pn_fr -0.05 -prefix ribbonmask_564_rh.nii -overwrite
#3dLocalstat -nbhd 'SPHERE(0.2)' -prefix filled_ribbonmask_564 ribbonmask_564+orig
3dcalc -a ribbonmask_564_rh.nii -b ribbonmask_564_lh.nii -expr 'a + b ' -prefix fill.nii -overwrite
3dcalc -a lh.pial.epi_vol.nii -b rh.pial.epi_vol.nii -expr 'a + b ' -prefix pial_vol.nii -overwrite
3dcalc -a lh.WM.epi_vol.nii -b rh.WM.epi_vol.nii -expr 'a + b ' -prefix WM_vol.nii -overwrite
3dLocalstat -nbhd 'SPHERE(0.3)' -stat mean -overwrite -prefix filled_fill.nii fill.nii
3dcalc -a filled_fill.nii -b fill.nii -expr 'step(step(a-0.5)+b)' -overwrite -prefix filled_fill.nii
3dcalc -a filled_fill.nii -b pial_vol.nii -c WM_vol.nii -expr 'step(a-b-c)' -overwrite -prefix GM_robbon4_manual_corr.nii
3dcalc -a filled_fill.nii -b pial_vol.nii -c WM_vol.nii -expr 'a + b + 2*c ' -prefix rim_auto.nii -overwrite

#cp filled_fill.nii ../../
#cp pial_vol.nii ../../
#cp WM_vol.nii ../../
#cp rim_auto.nii ../../
#cp scaled_EPI.nii ../../
#cp GM_robbon4_manual_corr.nii ../../

cp filled_fill.nii  ${layer_dir}
cp pial_vol.nii     ${layer_dir}
cp WM_vol.nii       ${layer_dir}
cp rim_auto.nii     ${layer_dir}
cp scaled_EPI.nii   ${layer_dir}
cp GM_robbon4_manual_corr.nii ${layer_dir}

cd ${layer_dir}
3dcalc -a pial_vol.nii -b WM_vol.nii -c filled_fill.nii -expr 'step(a)+2*step(b)+3*step(c)-3*step(a*c)-3*step(b*c)' -prefix rim.nii -overwrite

# SUMA
# https://layerfmri.com/2017/11/26/getting-layers-in-epi-space/

# https://layerfmri.com/2020/04/24/equivol/


## Equi-distance and Equi-volume layers with Faruk’s implementation as follows:
#../LN2_LAYERS -rim sc_rim.nii -equivol
##for the optional application of medium spatial smoothing, use the following flag.
#-iter_smooth 50
#
#
##Equi-distance layers with Renzo’s implementation as follows:
#../LN_GROW_LAYERS -rim sc_rim.nii
#
##Laplace-like layers with Renzo’s implementation as follows:
#../LN_LEAKY_LAYERS -rim sc_rim.nii

# Equi-volume layers with Renzo’s implementation as follows:
LN_GROW_LAYERS -rim rim.nii -N 1000 -vinc 60 -threeD
LN_LEAKY_LAYERS -rim rim.nii -nr_layers 1000 -iterations 100

LN_LOITUMA -equidist rim_layers.nii -leaky rim_leaky_layers.nii -FWHM 1 -nr_layers 10
cp leaky_layers.nii leaky_layers_n10.nii

LN_LOITUMA -equidist rim_layers.nii -leaky rim_leaky_layers.nii -FWHM 1 -nr_layers 3
cp leaky_layers.nii leaky_layers_n3.nii
cp equi_distance_layers.nii equi_distance_layers_n3.nii
cp equi_volume_layers.nii leaky_volume_layers_n3.nii

# LN2_LAYERS might do all nto sure
# use debug to get _columns.nii file
LN2_LAYERS -rim rim.nii -equivol -iter_smooth 50 -debug

# https://github.com/layerfMRI/LAYNII/issues/13
# can use equidist/equivol
# https://thingsonthings.org/ln2_columns/

# PARAMS ###################################
col_type='equivol'
col_num=1000
############################################
col_dir='columns_'${col_type}'_'${col_num}
echo 'col_dir: ' ${col_dir}
mkdir ${col_dir}
cp rim.nii rim_midGM_equi* ${col_dir}/
cd ${col_dir}
LN2_COLUMNS -rim rim.nii -midgm rim_midGM_${col_type}.nii -nr_columns ${col_num}
cd ..
################################################
# PARAMS ###################################
col_type='equidist'
col_num=38000
############################################
col_dir='columns_'${col_type}'_'${col_num}
echo 'col_dir: ' ${col_dir}
mkdir ${col_dir}
cp rim.nii rim_midGM_equi* ${col_dir}/
cd ${col_dir}
LN2_COLUMNS -rim rim.nii -midgm rim_midGM_${col_type}.nii -nr_columns ${col_num}
cd ..
################################################



## upscale the epi data
echo "************* upscaling run_file.nii ******************************"

vaso_dir='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/derivatives/sub-01/VASO_func'
cd $vaso_dir

for run_file in *; do

  echo $run_file


  warped_MP2RAGE='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/getting-layers-in-epi-space/warped_MP2RAGE.nii'

  delta_x=$(3dinfo -di ${run_file})
  delta_y=$(3dinfo -dj ${run_file})
  delta_z=$(3dinfo -dk ${run_file})
  sdelta_x=$(echo "(($delta_x / 4))"|bc -l)
  sdelta_y=$(echo "(($delta_x / 4))"|bc -l)
  sdelta_z=$(echo "(($delta_z / 4))"|bc -l)
  echo "$sdelta_x"
  echo "$sdelta_y"
  echo "$sdelta_z"
  3dresample -dxyz $sdelta_x $sdelta_y $sdelta_z -rmode Li -overwrite -prefix /mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/scaled_runs/scaled_${run_file} -input ${run_file}
  #get obliquity matrix
  #3dWarp -card2oblique ${run_file} -verb ${warped_MP2RAGE} -overwrite > orinentfile_${run_file}.txt
  # 3dWarp -card2oblique EPI.nii -verb warped_MP2RAGE.nii -overwrite &amp;gt; orinentfile.txt

done


# build hcp-mmp parecelation
# download annotation files:
# https://figshare.com/articles/dataset/HCP-MMP1_0_projected_on_fsaverage/3498446/2

# https://cjneurolab.org/2016/11/22/hcp-mmp1-0-volumetric-nifti-masks-in-native-structural-space/
#SUBJECTS_DIR='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects'
#cp ~/bin/parcellations/HCPMMP/* $SUBJECTS_DIR/fsaverage/label
#cp ~/bin/parcellations/HCPMMP/create_subj_volume_parcellation.sh $SUBJECTS_DIR/
#cp /usr/local/freesurfer/FreeSurferColorLUT.txt $SUBJECTS_DIR/
#
#cd $SUBJECTS_DIR
#
#touch subject_list.txt < warped_MP2RAGE
#bash create_subj_volume_parcellation.sh -L subject_list.txt -f1 -l 1 -a HCPMMP1 -d HCPMMP_parcellation -s YES -m YES


#SUBJECTS_DIR='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects'
#file='warped_MP2RAGE'

# BUILD atlas hcpmmp usign multiAtlasTT
conda activate openneuro
''' set these params in script
export atlasBaseDir=~/bin/multiAtlasTT/atlas_data
export scriptBaseDir=~/bin/multiAtlasTT
'''
./warped_MP2RAGE_run_maTT2.sh

run_file='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects/warped_MP2RAGE/multiAtlasTT/hcp-mmp-b/hcp-mmp-b.nii.gz'
out_file='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects/warped_MP2RAGE/multiAtlasTT/hcp-mmp-b/scaled_hcp-mmp-b.nii.gz'
master='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/getting-layers-in-epi-space/scaled_EPI.nii'
3dresample -master ${master} -rmode NN -overwrite -prefix ${out_file} -input ${run_file}

run_file='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects/warped_MP2RAGE/multiAtlasTT/shen268cort/shen268cort.nii.gz'
out_file='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects/warped_MP2RAGE/multiAtlasTT/shen268cort/scaled_shen268cort.nii.gz'
master='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/getting-layers-in-epi-space/scaled_EPI.nii'
3dresample -master ${master} -rmode NN -overwrite -prefix ${out_file} -input ${run_file}

run_file='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects/warped_MP2RAGE/multiAtlasTT/shen268cort/shen268cort_rmap.nii.gz'
out_file='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects/warped_MP2RAGE/multiAtlasTT/shen268cort/scaled_shen268cort_rmap.nii.gz'
master='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/getting-layers-in-epi-space/scaled_EPI.nii'
3dresample -master ${master} -rmode NN -overwrite -prefix ${out_file} -input ${run_file}

freeview \
getting-layers-in-epi-space/leaky_layers_n3.nii \
getting-layers-in-epi-space/scaled_EPI.nii \
subjects/warped_MP2RAGE/multiAtlasTT/warped_MP2RAGE_both_mask.nii.gz  \
subjects/warped_MP2RAGE/multiAtlasTT/hcp-mmp-b/scaled_hcp-mmp-b.nii.gz

freeview \
getting-layers-in-epi-space/leaky_layers_n10.nii \
getting-layers-in-epi-space/scaled_EPI.nii \
subjects/warped_MP2RAGE/multiAtlasTT/warped_MP2RAGE_both_mask.nii.gz  \
subjects/warped_MP2RAGE/multiAtlasTT/hcp-mmp-b/scaled_hcp-mmp-b.nii.gz



# THALMIC PARCELLATION

# TO INSTALL MATLAB COMPILER
# fs_install_mcr R2014b
#
SUBJECTS_DIR='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects'
segmentThalamicNuclei.sh  warped_MP2RAGE

run_file='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects/warped_MP2RAGE/mri/ThalamicNuclei.v12.T1.mgz'
out='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects/warped_MP2RAGE/mri/ThalamicNuclei.v12.T1.nii.gz'
mri_convert $run_file $out

run_file=$out
out_file='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects/warped_MP2RAGE/mri/scaled_ThalamicNuclei.v12.T1.nii.gz'
master='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/getting-layers-in-epi-space/scaled_EPI.nii'
3dresample -master ${master} -rmode NN -overwrite -prefix ${out_file} -input ${run_file}
#freeview -v nu.mgz -v ThalamicNuclei.v12.T1.mgz:colormap=lut
#A probabilistic atlas of the human thalamic nuclei combining ex vivo MRI and histology
#Iglesias, J.E., Insausti, R., Lerma-Usabiaga, G., Bocchetta, M.,
#Van Leemput, K., Greve, D., van der Kouwe, A., Caballero-Gaudes, C.,
#Paz-Alonso, P. NeuroImage (in press).
#Preprint available at arXiv.org:  https://arxiv.org/abs/1806.08634


# http://freesurfer.net/fswiki/BrainstemSubstructures
segmentBS.sh warped_MP2RAGE
#freeview -v nu.mgz -v brainstemSsLabels.v1x.mgz:colormap=lut
#Iglesias, J.E., Van Leemput, K., Bhatt, P., Casillas, C., Dutt, S., Schuff, N.,
#Truran-Sacrey, D., Boxer, A., and Fischl, B., Bayesian segmentation of brainstem
#structures in MRI. Neuroimage 113, 2015, 184-195.
#http://dx.doi.org/10.1016/j.neuroimage.2015.02.065

# http://freesurfer.net/fswiki/HippocampalSubfieldsAndNucleiOfAmygdala
segmentHA_T1.sh warped_MP2RAGE
#freeview -v nu.mgz -v lh.hippoAmygLabels-T1.v21.mgz:colormap=lut -v rh.hippoAmygLabels-T1.v21.mgz:colormap=lut
#freeview -v nu.mgz -v lh.hippoAmygLabels-T1.v21.HBT.mgz:colormap=lut -v rh.hippoAmygLabels-T1.v21.HBT.mgz:colormap=lut
#freeview -v nu.mgz -v lh.hippoAmygLabels-T1.v21.FS60.mgz:colormap=lut -v rh.hippoAmygLabels-T1.v21.FS60.mgz:colormap=lut
#freeview -v nu.mgz -v lh.hippoAmygLabels-T1.v21.CA.mgz:colormap=lut -v rh.hippoAmygLabels-T1.v21.CA.mgz:colormap=lut

run_file='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects/warped_MP2RAGE/mri/ThalamicNuclei.v12.T1.mgz'
out='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects/warped_MP2RAGE/mri/ThalamicNuclei.v12.T1.nii.gz'
mri_convert $run_file $out

run_file=$out
out_file='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects/warped_MP2RAGE/scaled_ThalamicNuclei.v12.T1.nii.gz'
master='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/getting-layers-in-epi-space/scaled_EPI.nii'
3dresample -master ${master} -rmode NN -overwrite -prefix ${out_file} -input ${run_file}

freeview $out_file $master

#### RENZO's rim
run_file='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/derivatives/sub-01/layerification/sub-01_ses-02_run-01_rim.nii'
out_file='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/derivatives/sub-01/layerification/scaled_sub-01_ses-02_run-01_rim.nii'
master='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/getting-layers-in-epi-space/scaled_EPI.nii'
3dresample -master ${master} -rmode NN -overwrite -prefix ${out_file} -input ${run_file}




############################
# use 02_correlations
./extract_ts_main.py # to generage cmds_extract_ts.txt
./extract_ts.sh

./extract_ts_main_shen268.py # to generage cmds_extract_ts.txt
./extract_ts_shen268.sh

'''
add outdir spec to extract_ts.py
'''

# GENERATE LAYER PROFILE
./generate_layer_profiles.sh -p '/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/bandettini_data/ts_numpy_extract_n10'

./generate_layer_profiles.sh -p '/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/bandettini_data/ts_numpy_extract_n3'


python ./build_dataframe.py --path '/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/bandettini_data/ts_numpy_extract_n10'

python ./build_dataframe.py --path '/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/bandettini_data/ts_numpy_extract_n3'

python ./generate_fc_from_df.py \
--path '/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/bandettini_data/ts_numpy_extract_n10_dataframe' \
--rois L_TGd L_TGv L_TE2a L_TE2p L_TE1a L_TE1m L_STSvp L_STSdp L_STSva L_STSda L_STGa L_TF


python ./generate_fc_from_df.py \
--path '/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/bandettini_data/ts_numpy_extract_n10_dataframe' \
--rois R_thalamus L_V1 L_V2 L_V3 L_V3A L_V3B L_V3CD L_V4 L_V4t L_V6


python ./generate_fc_from_df.py \
--path '/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/bandettini_data/ts_numpy_extract_n10_dataframe' \
--rois L_MT L_V1

python ./generate_fc_from_df.py \
--path '/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/bandettini_data/ts_numpy_extract_n10_dataframe' \
--rois R_thalamus L_MT L_V1


python ./generate_fc_from_df.py \
--path '/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/bandettini_data/ts_numpy_extract_n10_dataframe' \
--rois L_4 L_3b L_3a L_1 L_2

python ./generate_fc_from_df.py \
--path '/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/bandettini_data/ts_numpy_extract_n10_dataframe' \
--rois L_4 L_3b L_1

python ./generate_fc_from_df.py \
--path '/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/bandettini_data/ts_numpy_extract_n10_dataframe' \
--rois L_33pr	L_p24pr L_a24pr L_p24 L_a24 L_p32pr L_a32pr L_d32 L_p32 L_s32 L_8BM L_9m L_10v L_10r L_25

"""
cat '/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects/warped_MP2RAGE/multiAtlasTT/hcp-mmp-b/LUT_hcp-mmp-b_v2.txt' | grep _3b

"""

R_thalamus L_V1 R_V1

L_V2 L_V3 L_V3A L_V3B L_V3CD L_V4 L_V4t L_V6





python ./generate_fc_from_df.py \
--path '/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/bandettini_data/ts_numpy_extract_n3.mean.dataframe' \
--rois L_TGd L_TGv L_TE2a L_TE2p L_TE1a L_TE1m L_STSvp L_STSdp L_STSva L_STSda L_STGa L_TF


python ./generate_fc_from_df.py \
--path '/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/bandettini_data/ts_numpy_extract_n3.mean.dataframe' \
--rois R_thalamus L_V1 L_V2 L_V3 L_V3A L_V3B L_V3CD L_V4 L_V4t L_V6







#cd '/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/getting-layers-in-epi-space'
#melodic -i /mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/scaled_runs/scaled_sub-01_ses-02_task-movie_run-02_VASO.nii  \
#-o ica.outdir \
#-m /media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/getting-layers-in-epi-space/rim.nii -v #--tr 8.4 #--0stats #--tr

cd '/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/getting-layers-in-epi-space'
melodic -i /media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/derivatives/sub-01/VASO_func/sub-01_ses-02_task-movie_run-02_VASO.nii  \
-o ica.outdir \
-m /media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/derivatives/sub-01/layerification/GM_robbon4_manual_corr2VASO.nii -v --report #--tr 8.4 #--0stats #--tr


cd ica.outdir/report
conda activate openneuro
python /home/richard/Projects/bandettini/tools/display_melodics.py






























#
#mri_annotation2label --subject warped_MP2RAGE \
#  --hemi rh \
#  --annotation HCPMMP1 \
#  --ctab rh.HCPMMP1.txt
#
#mri_annotation2label --subject warped_MP2RAGE \
#  --hemi lh
#  --annotation HCPMMP1
#  --ctab lh.HCPMMP1.txt


#
#
## run warped_MR2RAGE.nii through recon-all
#SUBJECTS_DIR='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects'
#SUBJECTS_DIR='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/getting-layers-in-epi-space/FS'
#i_path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/getting-layers-in-epi-space'
#file='warped_MP2RAGE'
#recon_dir=${SUBJECTS_DIR}/${file}
#i=${i_path}'/warped_MP2RAGE.nii'
#epi=${i_path}'/EPI.nii'

#
#cd ${i_path}
#cp ${i} uncorr.nii
#
#cp /home/richard/bin/layerfmri_repo/bias_field_corr/Bias_field_script_job.m ./Bias_field_script_job.m
#matlab -nodesktop -nosplash -r "cd ${i_path}; addpath(genpath('/home/richard/matlab_toolbox')); run('${i_path}/Bias_field_script_job.m')"
#
#
#3dcalc -a muncorr.nii -prefix muncorr.nii -overwrite -expr 'a' -datum short
#rm uncorr.nii
#mv muncorr.nii ${i_path}/muncorr.nii
#
#
#3dcalc -a ${i_path}'/c1uncorr.nii' \
#-b ${i_path}'/c2uncorr.nii' \
#-c ${i_path}'/c3uncorr.nii' \
#-expr '(a+b+c)' \
#-prefix ${i_path}'/c123.nii.gz'
#
#3dcalc -a ${i_path}'/c1uncorr.nii' \
#-b ${i_path}'/c2uncorr.nii' \
#-expr '(a+b)' \
#-prefix ${i_path}'/c12.nii.gz'
#
#fslmaths ${i_path}'/c123.nii.gz' -fillh ${i_path}'/c123.fill.nii.gz'
#fslmaths ${i_path}'/c12.nii.gz' -fillh ${i_path}'/c12.fill.nii.gz'
#
#dil=5
#c3d ${i_path}'/c123.fill.nii.gz' \
#-dilate 1 ${dil}x${dil}x${dil}vox \
#-o ${i_path}'/c123.fill.dil'${dil}'.nii.gz'  # 3x3x3vox
#
#dil=10
#c3d ${i_path}'/c123.fill.nii.gz' \
#-dilate 1 ${dil}x${dil}x${dil}vox \
#-o ${i_path}'/c123.fill.dil'${dil}'.nii.gz'  # 3x3x3vox
#
#
#
#
#fslmaths ${i_path}'/muncorr.nii' \
#	-mas  ${i_path}'/c123.nii.gz' \
#	${i_path}'/muncorr.c123.ext.nii.gz'
#
#fslmaths ${i_path}'/muncorr.nii' \
#	-mas  ${i_path}'/c12.nii.gz' \
#	${i_path}'/muncorr.c12.ext.nii.gz'
#
#fslmaths ${i_path}'/muncorr.nii' \
#	-mas  ${i_path}'/c12.fill.nii.gz' \
#	${i_path}'/muncorr.c12.fill.ext.nii.gz'
#
#fslmaths ${i_path}'/muncorr.nii' \
#	-mas  ${i_path}'/c123.fill.nii.gz' \
#	${i_path}'/muncorr.c123.fill.ext.nii.gz'
#
#fslmaths ${i_path}'/muncorr.nii' \
#	-mas  ${i_path}'/c123.fill.dil5.nii.gz' \
#	${i_path}'/muncorr.c123.fill.dil5.ext.nii.gz'
#
#fslmaths ${i_path}'/muncorr.nii' \
#	-mas  ${i_path}'/c123.fill.dil10.nii.gz' \
#	${i_path}'/muncorr.c123.fill.dil10.ext.nii.gz'
#
##
##fslmaths ${i} \
##-mas  ${i_path}'/c123.dil'${dil}'.nii.gz' \
##${i_path}'/VASO.ihc.mean.dil.extracted.nii.gz'
##
##fslmaths ${i} \
##-mas  ${i_path}'/c123.nii.gz' \
##${i_path}'/VASO.ihc.mean.extracted.nii.gz'
##
###fslmaths ${i_path}'/sub-01_ses-01_run-01_T1w.nii' \
###	-mas  ${i_path}'/c123.dil'${dil}'.nii.gz' \
###	${i_path}'/T1.extracted.nii.gz'
##
##
### -mas  ${i_path}'/c1234.nii.gz' \
###bet ${i} ${i_path}'/sub-01_ses-01_run-01_T1w.bet.nii.gz' -f 0.2 -m -A -R -s
### -f ${bet_f} -g ${bet_g} #sub-01_ses-01_run-01_T1w.nii
##
##
### pial mask
##
##
##fslmaths ${i_path}'/muncorr.nii' \
##	-mas  ${i_path}'/c12.nii.gz' \
##	${i_path}'/pial_mask.nii.gz'
##
##
##
##
##
##
#######################
##


#
##./PREP4MANrim pial_vol.nii WM_vol.nii GM_robbon4_manual_corr.nii
#
##
###source /home/richard/bin/laynii
##
##LAYER_VOL_LEAK rim.nii
##GROW_LAYERS rim.nii
##3dcalc -a leak_vol_lay_rim.nii -b equi_dist_layers.nii -expr 'a-b' -overwrite -prefix difference.nii
##SMinMASK difference.nii rim.nii  30
##3dcalc -a smoothed_difference.nii -b leak_vol_lay_rim.nii -expr 'b-2*a' -overwrite -prefix corrected_leak_1.nii
##SMinMASK corrected_leak_1.nii rim.nii  12
##GLOSSY_LAYERS  smoothed_corrected_leak_1.nii
#
#
#
##get mean value
#3dROIstats -mask equi_dist_layers.nii -1DRformat -quiet -nzmean $1 > layer_t.dat
##get standard deviation
#3dROIstats -mask equi_dist_layers.nii -1DRformat -quiet -sigma $1 >> layer_t.dat
##get number of voxels in each layer
#3dROIstats -mask equi_dist_layers.nii -1DRformat -quiet -nzvoxels $1 >> layer_t.dat
##format file to be in columns, so gnuplot can read it.
#WRD=$(head -n 1 layer_t.dat|wc -w); for((i=2;i layer.dat
#
#
#
#
#
#
##runs with:
## gnuplot
## load "gnuplot_Lyer_me_single_TR.txt"
#
#
#set terminal qt enhanced 40
##set terminal postscript enhanced color solid "Helvetica" 25
##set out "profile.ps"
#
#set title "title"
#set ylabel "activity"
#set xlabel "cortical depth (left is WM, right is CSF)"
#
#plot 	"layer.dat" u 0:($1) w lines title "contrast type 1"  linewidth 3 linecolor rgb "blue"  ,\
#        "layer.dat" u 0:($1):($2)/sqrt($3-1) w yerrorbars title "" pt 1  linewidth 2 linecolor rgb "blue"
#
#
#set term qt
#exit
#
#
#
#
#
## c12
#SUBJECTS_DIR='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects'
#i_path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/getting-layers-in-epi-space'
#file='muncorr.c12.ext'
#recon_dir=${SUBJECTS_DIR}/${file}
#i=${i_path}'/muncorr.c12.ext.nii.gz'
#epi=${i_path}'/EPI.nii'
## freeview $i $epi
#
#recon-all -all -hires \
#  -i ${i} \
#  -subjid ${file} \
#  -parallel -openmp 40 \
#  -expert ${SUBJECTS_DIR}/expert.opts
#
#
#
##c123.filled
##SUBJECTS_DIR='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects'
#SUBJECTS_DIR='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/getting-layers-in-epi-space/FS'
#i_path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/getting-layers-in-epi-space'
#file='muncorr.c123.fill.dil5.ext'
#recon_dir=${SUBJECTS_DIR}/${file}
#i=${i_path}'/muncorr.c123.fill.dil5.ext.nii.gz'
#epi=${i_path}'/EPI.nii'
## freeview $i $epi
#
#recon-all -all -hires \
#  -i ${i} \
#  -subjid ${file} \
#  -parallel -openmp 40 \
#  -expert ${SUBJECTS_DIR}/expert.opts
#
#
#
##c123.filled
##SUBJECTS_DIR='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects'
#SUBJECTS_DIR='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/getting-layers-in-epi-space/FS'
#i_path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/getting-layers-in-epi-space'
#file='muncorr.c123.fill.dil10.ext'
#recon_dir=${SUBJECTS_DIR}/${file}
#i=${i_path}'/muncorr.c123.fill.dil10.ext.nii.gz'
#epi=${i_path}'/EPI.nii'
## freeview $i $epi
#
#recon-all -all -hires \
#  -i ${i} \
#  -subjid ${file} \
#  -parallel -openmp 40 \
#  -expert ${SUBJECTS_DIR}/expert.opts
#
#





#
#
#
#mat='mat.txt'
#EPI='EPI.nii'
#MP2RAGE='MP2RAGE.nii'
#
#echo ${MP2RAGE} ${EPI}  ${mat}
#
#
#
##
#################################################
##echo "I expect 2 filed. the T1_weighted EPI.nii and a MP2RAGE_orig.nii"
###  bet MP2RAGE_orig.nii MP2RAGE.nii -f 0.05
##3dcalc -a ${MP2RAGE} -datum short -expr 'a' -prefix ${MP2RAGE} -overwrite
##ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=40
##export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS
##echo "*****************************************"
##echo "************* starting with ANTS ********"
##echo "*****************************************"
###2 steps
##antsRegistration \
##--verbose 1 \
##--dimensionality 3 \
##--float 1 \
##--output [registered_,registered_Warped.nii.gz,registered_InverseWarped.nii.gz] \
##--interpolation Linear \
##--use-histogram-matching 0 \
##--winsorize-image-intensities [0.005,0.995] \
##--initial-moving-transform ${mat} \
##--transform Rigid[0.05] \
##--metric CC[${EPI},${MP2RAGE},0.7,32,Regular,0.1] \
##--convergence [1000x500,1e-6,10] \
##--shrink-factors 2x1 \
##--smoothing-sigmas 1x0vox \
##--transform Affine[0.1] \
##--metric MI[${EPI},${MP2RAGE},0.7,32,Regular,0.1] \
##--convergence [1000x500,1e-6,10] \
##--shrink-factors 2x1 \
##--smoothing-sigmas 1x0vox \
##--transform SyN[0.1,2,0] \
##--metric CC[${EPI},${MP2RAGE},1,2] \
##--convergence [500x100,1e-6,10] \
##--shrink-factors 2x1 \
##--smoothing-sigmas 1x0vox
#
##antsApplyTransforms -d 3 -i MP2RAGE.nii -o warped_MP2RAGE.nii -r MP2RAGE.nii-t registered_1Warp.nii.gz -t registered_0GenericAffine.mat
#antsApplyTransforms -d 3 -i MP2RAGE.nii -o warped_MP2RAGE.nii -r MP2RAGE.nii -t registered_1Warp.nii.gz -t registered_0GenericAffine.mat
#
#3dcalc -a warped_MP2RAGE.nii -datum short -expr 'a' -prefix warped_MP2RAGE.nii -overwrite
#
#
#recon-all -s subject_name -hires  -i warped_MP2RAGE.nii  -all -parallel -openmp 6
#
#
