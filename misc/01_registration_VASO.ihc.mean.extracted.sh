i='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/derivatives/sub-01/average_across_days/VASO_LN_across_days.ihc.mean.nii'
i_path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/derivatives/sub-01/average_across_days'

cd ${i_path}
cp ${i} uncorr.nii

cp /home/richard/bin/layerfmri_repo/bias_field_corr/Bias_field_script_job.m ./Bias_field_script_job.m
matlab -nodesktop -nosplash -r "cd ${i_path}; addpath(genpath('/home/richard/matlab_toolbox')); run('${i_path}/Bias_field_script_job.m')"


3dcalc -a muncorr.nii -prefix muncorr.nii -overwrite -expr 'a' -datum short
rm uncorr.nii
mv muncorr.nii ${i_path}/muncorr.nii


3dcalc -a ${i_path}'/c1uncorr.nii' \
-b ${i_path}'/c2uncorr.nii' \
-c ${i_path}'/c3uncorr.nii' \
-expr '(a+b+c)' \
-prefix ${i_path}'/c123.nii.gz'


fslmaths ${i_path}'/muncorr.nii' \
	-mas  ${i_path}'/c123.dil'${dil}'.nii.gz' \
	${i_path}'/muncorr.dil.extracted.nii.gz'

fslmaths ${i_path}'/muncorr.nii' \
	-mas  ${i_path}'/c123.nii.gz' \
	${i_path}'/muncorr.extracted.nii.gz'


fslmaths ${i} \
-mas  ${i_path}'/c123.dil'${dil}'.nii.gz' \
${i_path}'/VASO.ihc.mean.dil.extracted.nii.gz'

fslmaths ${i} \
-mas  ${i_path}'/c123.nii.gz' \
${i_path}'/VASO.ihc.mean.extracted.nii.gz'

#fslmaths ${i_path}'/sub-01_ses-01_run-01_T1w.nii' \
#	-mas  ${i_path}'/c123.dil'${dil}'.nii.gz' \
#	${i_path}'/T1.extracted.nii.gz'


# -mas  ${i_path}'/c1234.nii.gz' \
#bet ${i} ${i_path}'/sub-01_ses-01_run-01_T1w.bet.nii.gz' -f 0.2 -m -A -R -s
# -f ${bet_f} -g ${bet_g} #sub-01_ses-01_run-01_T1w.nii


# pial mask
3dcalc -a ${i_path}'/c1uncorr.nii' \
-b ${i_path}'/c2uncorr.nii' \
-expr '(a+b)' \
-prefix ${i_path}'/c12.nii.gz'


fslmaths ${i_path}'/muncorr.nii' \
	-mas  ${i_path}'/c12.nii.gz' \
	${i_path}'/pial_mask.nii.gz'

SUBJECTS_DIR='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects'
i_path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/derivatives/sub-01/average_across_days'
file='muncorr.extracted'
recon_dir=${SUBJECTS_DIR}/${file}
i=${i_path}'/muncorr.extracted.nii.gz'

recon-all -autorecon1 -hires \
  -i ${i} \
  -subjid ${file} \
  -parallel -openmp 40 \
  -expert ${SUBJECTS_DIR}/expert.opts



# mri_gcut -110 wm.mgz wm.gcut.mgz
# cp wm.gcut.mgz wm.mgz
# pial mask
cp ../../../ds003216-download/derivatives/sub-01/average_across_days/pial_mask.nii.gz  .
mri_convert pial_mask.nii.gz pial_mask.mgz
cp pial_mask.mgz brainmask.mgz


#
recon-all -autorecon2 -hires \
  -subjid ${file} \
  -parallel -openmp 40


#https://surfer.nmr.mgh.harvard.edu/fswiki/FsTutorial/TroubleshootingData


recon-all -autorecon3 -hires \
  -subjid ${file} \
  -parallel -openmp 40

