
# recon-all output dir
SUBJECTS_DIR='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects'

path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/derivatives/sub-01/average_across_days/'
file='VASO_LN_across_days'

# params for fslmath thrshold thr (lower) uthr (upper)
thr=0
uthr=140

# params for bet - bet_f is worth playing around with might be able to get better results
bet_f=0.07      #0.7
bet_g=0.00      #0.10

dil=3

# 1) bias correction for each volume in 4d (not sure if I can do tsnr first and then bias? difference between mulitple
# 3d volumes and  one 3d volume. 2) tsnr 3) threshold tsnr

if [ ! -f ${path}${file}.ihc.nii.gz ]; then
  N4BiasFieldCorrection -d 4 -i ${path}${file}.nii -o ${path}${file}.ihc.nii.gz
  3dTstat -tsnr -prefix ${path}${file}.ihc.tsnr.nii.gz ${path}${file}.ihc.nii.gz
  fslmaths ${path}${file}.ihc.tsnr.nii.gz -thr ${thr} -uthr ${uthr} \
      ${path}${file}.ihc.tsnr.thr${thr}.uthr${uthr}.nii.gz
fi

# get mean for later
fslmaths  ${path}${file}.ihc.nii -Tmean ${path}${file}.ihc.mean.nii.gz

# m = binary mask (not currently using this outputted mask), A = extract scalp and skull (not using but just in case), R= "robust" brain center estimation
bet ${path}${file}.ihc.tsnr.thr${thr}.uthr${uthr}.nii.gz \
    ${path}${file}.ihc.tsnr.thr${thr}.uthr${uthr}.betf${bet_f}.betg${bet_g}.nii.gz \
    -f ${bet_f} -g ${bet_g} -m -A -R

# fill any holes in mask
fslmaths ${path}${file}.ihc.tsnr.thr${thr}.uthr${uthr}.betf${bet_f}.betg${bet_g}.nii.gz \
  -fillh ${path}${file}.ihc.tsnr.thr${thr}.uthr${uthr}.betf${bet_f}.betg${bet_g}.fillh.nii.gz

# dilate
c3d ${path}${file}.ihc.tsnr.thr${thr}.uthr${uthr}.betf${bet_f}.betg${bet_g}.fillh.nii.gz \
-dilate 1 ${dil}x${dil}x${dil}vox \
-o ${path}${file}.ihc.tsnr.thr${thr}.uthr${uthr}.betf${bet_f}.betg${bet_g}.fillh.dil${dil}.nii.gz  # 3x3x3vox

# extract from mean image using mask
fslmaths ${path}${file}.ihc.mean.nii.gz \
	-mas ${path}${file}.ihc.tsnr.thr${thr}.uthr${uthr}.betf${bet_f}.betg${bet_g}.fillh.dil${dil}.nii.gz \
	${path}${file}.ihc.tsnr.thr${thr}.uthr${uthr}.betf${bet_f}.betg${bet_g}.fillh.dil${dil}.extracted.nii.gz

# view in itksnap
#itksnap 	${file}.ihc.tsnr.thr${thr}.uthr${uthr}.betf${bet_f}.betg${bet_g}.fillh.dil${dil}.extracted.nii.gz

freeview 	${path}${file}.ihc.mean.nii \
${path}${file}.ihc.tsnr.thr${thr}.uthr${uthr}.betf${bet_f}.betg${bet_g}.fillh.dil${dil}.extracted.nii.gz:opacity=0.5 \
${path}${file}.ihc.tsnr.thr${thr}.uthr${uthr}.betf${bet_f}.betg${bet_g}.fillh.dil${dil}.nii.gz \
${path}${file}.ihc.tsnr.thr${thr}.uthr${uthr}.betf${bet_f}.betg${bet_g}.fillh.nii.gz &







recon-all -all -hires \
  -i ${path}${file}.ihc.tsnr.thr${thr}.uthr${uthr}.betf${bet_f}.betg${bet_g}.fillh.dil${dil}.extracted.nii.gz \
  -subjid ${file}.ihc.tsnr.thr${thr}.uthr${uthr}.betf${bet_f}.betg${bet_g}.fillh.dil${dil}.extracted \
  -parallel -openmp 40

recon_dir=${SUBJECTS_DIR}/${file}.ihc.tsnr.thr${thr}.uthr${uthr}.betf${bet_f}.betg${bet_g}.fillh.dil${dil}.extracted

mris_volmask --save_ribbon ${file}.ihc.tsnr.thr${thr}.uthr${uthr}.betf${bet_f}.betg${bet_g}.fillh.dil${dil}.extracted
#mris_volmask --save_ribbon VASO_LN_across_days.ihc.tsnr.thr0.uthr140.betf0.15.betg0.00.fillh.dil5.extracted

mkdir -p $recon_dir/manual_edits

mri_convert $recon_dir/mri/T1.mgz $recon_dir/manual_edits/T1.nii.gz
mri_convert $recon_dir/mri/ribbon.mgz $recon_dir/manual_edits/ribbon.nii.gz


freeview $recon_dir/mri/T1.mgz \
$recon_dir/mri/aseg.mgz  \
-f $recon_dir/surf/lh.white \
-f $recon_dir/surf/rh.white \
-f $recon_dir/surf/lh.pial \
-f $recon_dir/surf/rh.pial \
#$recon_dir/mri/ribbon.mgz
#$recon_dir/mri/aseg.auto.mgz \
#$recon_dir/mri/wm.seg.mgz \


