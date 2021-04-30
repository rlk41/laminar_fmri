
'''

# recon-all output dir
SUBJECTS_DIR='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects'

path='./ds003216-download/derivatives/sub-01/average_across_days/'
file='VASO_LN_across_days'

# params for fslmath thrshold thr (lower) uthr (upper)
thr=0
uthr=140

# params for bet - bet_f is worth playing around with might be able to get better results
bet_f=0.15      #0.7
bet_g=0.00      #0.10

dil=5

# 1) bias correction for each volume in 4d (not sure if I can do tsnr first and then bias? difference between mulitple
# 3d volumes and  one 3d volume. 2) tsnr 3) threshold tsnr

#N4BiasFieldCorrection -d 4 -i ${path}${file}.nii -o ${path}${file}.ihc.nii
#3dTstat -tsnr -prefix ${path}${file}.ihc.tsnr.nii ${path}${file}.ihc.nii
#fslmaths ${path}${file}.ihc.tsnr.nii -thr ${thr} -uthr ${uthr} ${path}${file}.ihc.tsnr.thr${thr}.uthr${uthr}.nii

# get mean for later
#fslmaths  ${path}${file}.ihc.nii -Tmean ${path}${file}.ihc.mean.nii

# m = binary mask (not currently using the mask), A = extract scalp and skull (not using but just in case), R= "robust" brain center estimation
bet ${path}${file}.ihc.tsnr.thr${thr}.uthr${uthr}.nii ${path}${file}.ihc.tsnr.thr${thr}.uthr${uthr}.betf${bet_f}.betg${bet_g}.nii -f ${bet_f} -g ${bet_g} -m -A -R

# fill any holes in mask
fslmaths ${path}${file}.ihc.tsnr.thr${thr}.uthr${uthr}.betf${bet_f}.betg${bet_g}.nii -fillh ${path}${file}.ihc.tsnr.thr${thr}.uthr${uthr}.betf${bet_f}.betg${bet_g}.fillh.nii

# dilate
c3d ${path}${file}.ihc.tsnr.thr${thr}.uthr${uthr}.betf${bet_f}.betg${bet_g}.fillh.nii -dilate 1 ${dil}x${dil}x${dil}vox -o ${path}${file}.ihc.tsnr.thr${thr}.uthr${uthr}.betf${bet_f}.betg${bet_g}.fillh.dil${dil}.nii  # 3x3x3vox

# extract from mean image using mask
fslmaths ${path}${file}.ihc.mean.nii \
	-mas ${path}${file}.ihc.tsnr.thr${thr}.uthr${uthr}.betf${bet_f}.betg${bet_g}.fillh.dil${dil}.nii \
	${file}.ihc.tsnr.thr${thr}.uthr${uthr}.betf${bet_f}.betg${bet_g}.fillh.dil${dil}.extracted.nii.gz

# view in itksnap
itksnap 	${file}.ihc.tsnr.thr${thr}.uthr${uthr}.betf${bet_f}.betg${bet_g}.fillh.dil${dil}.extracted.nii.gz

recon-all -all -hires \
  -i ${path}${file}.ihc.tsnr.thr${thr}.uthr${uthr}.betf${bet_f}.betg${bet_g}.fillh.dil${dil}.extracted.nii.gz \
  -subjid ${file}.ihc.tsnr.thr${thr}.uthr${uthr}.betf${bet_f}.betg${bet_g}.fillh.dil${dil}.extracted \
  -parallel -openmp 20







file='VASO_LN_across_days'

3dTstat -tsnr -prefix ${path}${file}.tsnr.nii ${path}${file}.nii

N4BiasFieldCorrection -d 3 -i ${path}${file}.tsnr.nii -o ${path}${file}.tsnr.ihc.nii

fslmaths ${path}${file}.tsnr.ihc.nii -thr 0 -uthr 140 ${path}${file}.tsnr.ihc.uthr140.nii
fslmaths ${path}${file}.tsnr.ihc.nii -thr 20 -uthr 140 ${path}${file}.tsnr.ihc.uthr140.nii


bet ${path}${file}.tsnr.ihc.uthr140.nii ${path}${file}.tsnr.ihc.uthr140.bet0.10.nii -f 0.10 -g 0 -m
bet ${path}${file}.tsnr.ihc.uthr140.nii ${path}${file}.tsnr.ihc.uthr140.bet0.15.nii -f 0.15 -g 0 -m

fslmaths ${path}${file}.tsnr.ihc.uthr140.bet0.10.nii -fillh ${path}${file}.tsnr.ihc.uthr140.bet0.10.filled.nii
fslmaths ${path}${file}.tsnr.ihc.uthr140.bet0.15.nii -fillh ${path}${file}.tsnr.ihc.uthr140.bet0.15.filled.nii



c3d ${path}${file}.tsnr.ihc.uthr140.bet0.10.filled.nii -dilate 1 3x3x3vox -o ${path}${file}.tsnr.ihc.uthr140.bet0.10.filled.dil1.nii
c3d ${path}${file}.tsnr.ihc.uthr140.bet0.10.filled.nii -dilate 2 3x3x3vox -o ${path}${file}.tsnr.ihc.uthr140.bet0.10.filled.dil2.nii
c3d ${path}${file}.tsnr.ihc.uthr140.bet0.10.filled.nii -dilate 3 3x3x3vox -o ${path}${file}.tsnr.ihc.uthr140.bet0.10.filled.dil3.nii
c3d ${path}${file}.tsnr.ihc.uthr140.bet0.10.filled.nii -dilate 4 3x3x3vox -o ${path}${file}.tsnr.ihc.uthr140.bet0.10.filled.dil4.nii




c3d ${path}${file}.tsnr.ihc.uthr140.bet0.15.nii -dilate 5 3x3x3vox -o ${path}${file}.tsnr.ihc.uthr140.bet0.15.dil5.nii






























bet ${path}${file}.tsnr.ihc.uthr140.nii ${path}${file}.tsnr.ihc.uthr140.bet0.2.nii -f 0.2 -g 0 -m
bet ${path}${file}.tsnr.ihc.uthr140.nii ${path}${file}.tsnr.ihc.uthr140.bet0.15.nii -f 0.15 -g 0 -m

fslmaths ${path}${file}.tsnr.ihc.uthr140.bet0.15.nii -fillh ${path}${file}.tsnr.ihc.uthr140.bet0.15.filled.nii

3dTstat -tsnr -prefix tsnr+VASO_LN_across_days.nii VASO_LN_across_days.nii                  #GOOD threshold 0 - 200
fslmaths tsnr+VASO_LN_across_days.nii -thr 0 -uthr 140 tsnr+uthr140+VASO_LN_across_days.nii
bet tsnr+uthr_140+VASO_LN_across_days.nii tsnr+uthr_140+VASO_LN_across_days_brain0.2.nii -f 0.2 -g 0
bet tsnr+uthr_140+VASO_LN_across_days.nii tsnr+uthr_140+VASO_LN_across_days_brain0.15.nii -f 0.15 -g 0



# mask -m
# g gradient 1=bottom_bigger -1=top_bigger



tsnr+uthr_140+VASO_LN_across_days_brain0.15.nii


fslmaths lesion -fillh lesion -odt char
fslmaths lesion -kernel gauss 0.1 -fmean -bin lesion_smooth
erode.sh lesion_smooth 1 3D

SUBJECTS_DIR='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandetinni/subjects'
recon-all -subject tsnr+uthr140+VASO_LN_across_days -i ./ds003216-download/derivatives/sub-01/average_across_days/tsnr+uthr140+VASO_LN_across_days.nii.gz -openmp 20 -all




### WORKING ON THE FUNC DATA (NOT AVERAGE)

3dTstat -tsnr -prefix sub-01_ses-01_task-test_run-01_bold+tsnr.nii sub-01_ses-01_task-test_run-01_bold.nii

recon-all -subject sub-01_ses-01_task-test_run-01_bold -i ./ds003216-download/sub-01/ses-01/func/sub-01_ses-01_task-test_run-01_bold.nii -openmp 20 -all




##################################################





SUBJECTS_DIR='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandetinni/subjects'
recon-all -subject sub-01_mean+average_across_days -i ./ds003216-download/derivatives/sub-01/average_across_days/mean+VASO_LN_across_days.nii -openmp 20 -all

# ANAT
SUBJECTS_DIR='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandetinni/subjects'
recon-all -subject sub-01_ses-01_run-01_T1w -i ./ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w.nii  -openmp 20 -all








fslmaths tsnr+VASO_LN_across_days.nii -thr 0 -uthr 200 tsnr+uthr_200+VASO_LN_across_days.nii
bet tsnr+uthr_0+VASO_LN_across_days.nii bet+tsnr+uthr_0+VASO_LN_across_days.nii


3dTstat -mean -prefix mean+VASO_LN_across_days.nii VASO_LN_across_days.nii
3dTstat -stdev -prefix stdev+VASO_LN_across_days.nii VASO_LN_across_days.nii                #bad
3dTstat -stdevNOD -prefix stdevNOD+VASO_LN_across_days.nii VASO_LN_across_days.nii          #bad

3dTstat -skewness -prefix skewness+VASO_LN_across_days.nii VASO_LN_across_days.nii
3dTstat -kurtosis -prefix kurtosis+VASO_LN_across_days.nii VASO_LN_across_days.nii

Skew = 3 * (Mean – Median) / Standard Deviation


-MAD
-DW

 -median
 -bmv


 -MSSD      = Von Neumann's Mean of Successive Squared Differences\n"
 "               = average of sum of squares of first time difference\n"
 " -MSSDsqrt  = Sqrt(MSSD)\n"
 " -MASDx     = Median of absolute values of first time differences\n"
 "               times 1.4826 (to scale it like standard deviation)\n"
 "               = a robust alternative to MSSDsqrt\n"
 " -autocorr n = compute autocorrelation function and return\n"
 "               first n coefficients\n"
 " -autoreg n = compute autoregression coef

-skewness
-kurtosis
-firstvalue
 -sum       = compute sum of input voxels
 -abssum    = compute absolute sum of input voxels
 -sos       = compute sum of squares
 -l2norm    = compute L2 norm (sqrt(sum squares))
 -mean      = compute mean of input voxels
 -slope     = compute the slope of input voxels vs. time

 -stdev     = compute standard deviation of input voxels
              NB: input is detrended by first removing mean+slope
 -stdevNOD



IDEAS:
    align using ventricles
    ensemble model for warping

'''