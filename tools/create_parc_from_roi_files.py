import argparse
from glob import glob
import os
import nibabel as nib

def main(roi_dir):
    rois = glob(os.path.join(roi_dir,'*.nii'))

    out = nib.load(rois[0])
    out_data = out.get_data()

    num = 2
    for roi in rois[1:]:
        r = nib.load(roi)
        r_data = r.get_data()
        r_data = r_data * num
        out_data = out_data + r_data
        num += 1

    save = nib.Nifti1Image(out_data, out.affine, out.header)
    basepath = '/'.join(roi_dir.split('/')[0:-1])
    basename = roi_dir.split('/')[-1]
    nib.save(save,os.path.join(basepath, '{}_parc.nii'.format(basename)))

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--roi_dir")

    """
    roi_dir='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/ROIs_columns'
    """
    roi_dir=args.roi_dir

    main(roi_dir)

