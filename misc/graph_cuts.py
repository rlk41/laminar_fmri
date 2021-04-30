import os
import numpy as np
import nibabel as nib
import numpy as np
import imcut.pycut as pspc
import matplotlib.pyplot as plt


file_path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/c1uncorr.nii'

img = nib.load(file_path)
#example_filename = os.path.join(data_path, 'example4d.nii.gz')

data = img.get_data()

igc = pspc.ImageGraphCut(data, voxelsize=[1, 1, 1])
seeds = igc.interactivity()