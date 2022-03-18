#!/usr/bin/env python

import nibabel as nib 
import numpy as np 


layers = nib.load('/data/kleinrl/Wholebrain2.0/ANAT/dwscaled/dwscaled_layers.nii')
data = layers.get_fdata()

out = data 

unq_data = np.unique(data)



for x in unq_data[2:-1]:
    print(x)
    inds = np.where(data == x )

    out[inds] = 3

inds = np.where(data == 1 )
out[inds] = 2 

inds = np.where(data == 7 )
out[inds] = 1 

out_img = nib.Nifti1Image(out, layers.affine, layers.header)
nib.save(out_img, '/data/kleinrl/Wholebrain2.0/ANAT/dwscaled/dwscaled_rim.nii')
