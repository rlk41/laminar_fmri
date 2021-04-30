
SUBJECTS_DIR='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects'
i_path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/derivatives/sub-01/average_across_days'
file='pial_mask'
recon_dir=${SUBJECTS_DIR}/${file}
i=${i_path}'/pial_mask.nii.gz'

recon-all -autorecon1 -hires \
  -i ${i} \
  -subjid ${file} \
  -parallel -openmp 40 \
  -expert ${SUBJECTS_DIR}/expert.opts

# chekc brain mask

recon-all -autorecon2 -hires \
  -subjid ${file} \
  -parallel -openmp 40 \

# replace wm

recon-all -autorecon2-wm -hires \
  -subjid ${file} \
  -parallel -openmp 40 \



recon-all -autorecon3 -hires \
  -subjid ${file} \
  -parallel -openmp 40 \

