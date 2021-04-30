

SUBJECTS_DIR='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects'

path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/derivatives/sub-01/average_across_days/'

file='sub-01_ses-01_run-01_T1w_hires'

i='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w.nii'

recon_dir=${SUBJECTS_DIR}/${file}


recon-all -all -hires \
  -i ${i} \
  -subjid ${file} \
  -parallel -openmp 40 \
  -expert ${SUBJECTS_DIR}/expert.opts


mris_volmask --save_ribbon ${file}
#mris_volmask --save_ribbon VASO_LN_across_days.ihc.tsnr.thr0.uthr140.betf0.15.betg0.00.fillh.dil5.extracted



freeview $recon_dir/mri/T1.mgz \
$recon_dir/mri/aseg.mgz  \
-f $recon_dir/surf/lh.white \
-f $recon_dir/surf/rh.white \
-f $recon_dir/surf/lh.pial \
-f $recon_dir/surf/rh.pial

mkdir -p ${recon_dir}/reg
## BBERGISTER
bbregister --s ${file}  --mov  ${path}/mean+VASO_LN_across_days.nii --reg ${recon_dir}/reg/mean+VASO2hiresT1w.dat --init-fsl --t1





#editing brainmask
freeview -v mri/T1.mgz \
mri/brainmask.mgz:colormap=heat:visible=false \



-f surf/lh.white:edgecolor=yellow \
surf/lh.pial:edgecolor=red \
surf/rh.white:edgecolor=yellow \
surf/rh.pial:edgecolor=red

mri/aseg+aparc.mgz \


# fix skullstrip



cd /media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects/sub-01_ses-01_run-01_T1w_hires_fixskullstrip

SUBJECTS_DIR='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects'
file='sub-01_ses-01_run-01_T1w_hires_fixskullstrip'

WATERSHED_PREFLOOD_HEIGHTS='30 32 34 36 38 40'
setenv WATERSHED_PREFLOOD_HEIGHTS '30 31 32 33 34 35 36 37 38 39 40'

recon-all -multistrip -clean-bm -s ${file} -no-isrunning

#h=1
#recon-all -skullstrip -wsthresh 40 -clean-bm -subjid ${file} -no-wsgcaatlas
recon-all -hires -skullstrip -wsthresh 30 -clean-bm -subjid ${file} -no-isrunning  #-no-wsgcaatlas
recon-all -hires -skullstrip -clean-bm -subjid ${file} -no-isrunning -expert ${SUBJECTS_DIR}/expert.opts #-no-wsgcaatlas

freeview -v mri/T1.mgz \
mri/brainmask.mgz

recon-all -hires -skullstrip -clean-bm -gcut -subjid ${file} -no-isrunning

tkmedit ${file} T1.mgz -segmentation brainmask.gcuts.mgz



recon-all -expert /expert.opts




###################################


i='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w.nii'
i_path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat'



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

dil=10
c3d ${i_path}'/c123.nii.gz' \
-dilate 1 ${dil}x${dil}x${dil}vox \
-o ${i_path}'/c123.dil'${dil}'.nii.gz'  # 3x3x3vox


fslmaths ${i_path}'/muncorr.nii' \
	-mas  ${i_path}'/c123.dil'${dil}'.nii.gz' \
	${i_path}'/muncorr.extracted.nii.gz'
#fslmaths ${i_path}'/sub-01_ses-01_run-01_T1w.nii' \
#	-mas  ${i_path}'/c123.dil'${dil}'.nii.gz' \
#	${i_path}'/T1.extracted.nii.gz'


# -mas  ${i_path}'/c1234.nii.gz' \
#bet ${i} ${i_path}'/sub-01_ses-01_run-01_T1w.bet.nii.gz' -f 0.2 -m -A -R -s
# -f ${bet_f} -g ${bet_g} #sub-01_ses-01_run-01_T1w.nii

SUBJECTS_DIR='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects'
file='sub-01_ses-01_run-01_T1w_expert_muncorr_extracted'
recon_dir=${SUBJECTS_DIR}/${file}
#i='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/muncorr.extracted.nii.gz'
i='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/muncorr.extracted.nii.gz'


recon-all -all -hires \
  -i ${i} \
  -subjid ${file} \
  -parallel -openmp 40 \
  -expert ${SUBJECTS_DIR}/expert.opts

recon-all -make all -hires \
  -subjid ${file} \
  -parallel -openmp 40

mri_gcut -110 wm.mgz wm.gcut.mgz
cp wm.gcut.mgz wm.mgz

recon-all -autorecon2-wm -hires \
  -subjid ${file} \
  -parallel -openmp 40
#https://surfer.nmr.mgh.harvard.edu/fswiki/FsTutorial/TroubleshootingData


recon-all -autorecon3 -hires \
  -subjid ${file} \
  -parallel -openmp 40

recon-all -make all -hires \
  -subjid ${file}
  -parallel -openmp 40


mris_volmask --save_ribbon ${file}

freeview -v mri/T1.mgz \
-f surf/lh.white:edgecolor=yellow \
-f surf/lh.pial:edgecolor=red \
-f surf/rh.white:edgecolor=yellow \
-f surf/rh.pial:edgecolor=red

#mri/brainmask.mgz:colormap=heat:visible=false \

recon-all -autorecon1

# cp new brainmask
## try using c1.nii as brainmask; gcut then ... or gcut wm -> inflate
# wm edits
#

recon-all -autorecon2

mkdir -p ${recon_dir}/reg

mov='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/func/sub-01_ses-01_task-test_run-01_bold.nii'
mov='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/func/sub-01_ses-01_task-test_run-01_bold.nii'
mov='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/derivatives/sub-01/average_across_days/muncorr.dil.extracted.nii.gz'

bbregister --s ${file}  --mov  ${mov} --reg ${recon_dir}/reg/sub-01_task-test_run-01_bold-2-hiresT1w.dat --init-spm --bold


mov='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/derivatives/sub-01/average_across_days/muncorr.dil.extracted.nii.gz'
bbregister --s ${file}  --mov  ${mov} --reg ${recon_dir}/reg/sub-01_task-test_run-01_bold-2-hiresT1w.dat --init-spm --t1





## MATLAB recursive_boundary


tvm_useBbregister(configureation)



# boundary based
# gm/wm do vary linearly seperable locally (non-linear globably - dependent on location)