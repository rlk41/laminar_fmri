#!/usr/bin/env python

import os,glob
import nibabel
import numpy
import sklearn
import nilearn.input_data
from nilearn.plotting import plot_roi
from nilearn.image.image import mean_img
from nilearn.plotting import plot_stat_map, show
from nilearn.image import index_img,clean_img
from nilearn.decomposition import CanICA
from sklearn.decomposition import FastICA,PCA

import matplotlib.pyplot as plt
#from nipype.interfaces import fsl, nipy
#from nipype.caching import Memory
#mem = Memory(base_dir='.')

#import sys
#sys.path.append('/home/vagrant/fmri-analysis-vm/analysis/utils')
#from compute_fd_dvars import compute_fd,compute_dvars

#%matplotlib inline

rsfmri_basedir='/data/kleinrl/ds003216/derivatives/sub-01/VASO_func'
rsfmri_files=glob.glob(os.path.join(rsfmri_basedir,'*VASO.nii'))

rsfmri_files.sort()

# load the first image and create the masker object
"""
0,1 VASO.nii runs damaged????
"""
rsfmri_img=nibabel.load(rsfmri_files[2])

masker= nilearn.input_data.NiftiMasker(mask_strategy='epi')
masker.fit(rsfmri_img)
mask_img = masker.mask_img_


rsfmri={}  # nifti handle to cleaned image
fmri_masked=None
# load and clean each image
for f in rsfmri_files:
    rsfmri_img=nibabel.load(f)
    runnum=int(f.split('_')[3].split('-')[1])
    rsfmri[runnum]=nilearn.image.smooth_img(nilearn.image.clean_img(rsfmri_img),'fast')
    print('loaded run',runnum)
    motparfile=f.replace('nii.gz','par')
    mp=numpy.loadtxt(motparfile)
    if fmri_masked is None:
        fmri_masked=masker.transform(rsfmri[runnum])
        motpars=mp
    else:
        fmri_masked=numpy.vstack((fmri_masked,masker.transform(rsfmri[runnum])))
        motpars=numpy.vstack((motpars,mp))


# calculate mean image for the background
mean_func_img = '/home/vagrant/data/ds031/sub-01/ses-105/mcflirt/mcflirt_target.nii.gz'

plot_roi(mask_img, mean_func_img, display_mode='y', 
         cut_coords=4, title="Mask")


# import nibabel as nib
# import argparse
# import numpy as np
# from matplotlib import pyplot as plt
# import time 
# from scipy import signal 
# from sklearn.preprocessing import normalize
# import os




# def main(seed, layers, columns, epi, outdir):

#     if not os.path.exists(outdir):
#         os.makedirs(outdir)



#     out_prefix = seed.split('/')[-1].strip('.nii')

#     start = time.perf_counter()


#     nii_seed = nib.load(seed)
#     data_seed = nii_seed.get_fdata()


#     nii_layers = nib.load(layers)
#     data_layers = nii_layers.get_fdata()

#     nii_columns = nib.load(columns)
#     data_columns = nii_columns.get_fdata()

#     nii_epi = nib.load(epi)
#     data_epi = nii_epi.get_fdata()


#     ind_seed = np.where(data_seed == 1)
#     affine = nii_seed.affine
#     ss = data_seed.shape

#     del nii_seed, nii_layers, nii_columns, nii_epi 
    

#     out = np.zeros((ss[0], ss[1], ss[2],len(np.unique(data_layers))-1))
#     out_ff = np.zeros((ss[0], ss[1], ss[2],1))
#     out_fb = np.zeros((ss[0], ss[1], ss[2],1))
#     out_other = np.zeros((ss[0], ss[1], ss[2],1))
#     out_deep = np.zeros((ss[0], ss[1], ss[2],1))
#     out_super = np.zeros((ss[0], ss[1], ss[2],1))




#     # GET SEED DATA, AVERAGE, DETREND, NORMALIZE 
#     # TODO: MAYBE VOXEL BY VOXEL - SEED TO TARGET 
#     # average epi
#     seed_ts_s = data_epi[ind_seed]
#     seed_mean = np.mean(seed_ts_s,0)

#     print("ts size: {}".format(seed_mean.size))

#     seed_ts_dt = signal.detrend(seed_mean, type='linear')
#     seed_ts_dt_n = (seed_ts_dt - np.mean(seed_ts_dt))/ np.std(seed_ts_dt)
#     seed_ts = seed_ts_dt_n

#     unq_columns = np.unique(data_columns)
#     unq_columns = unq_columns[1:]

#     unq_layers = np.unique(data_layers)
#     unq_layers = unq_layers[1:]


#     data_layer_by_col_vox_ts = []
#     data_layer_by_col_vox_l = []
#     data_layer_by_col_vox_c = []
#     data_layer_by_col_vox_fill_c = []

#     for c in unq_columns:
#         layer_corrs = []
#         for l in unq_layers:
#             bin_col = data_columns == c
#             bin_layer = data_layers == l
            
#             w = np.where((bin_col) & (bin_layer))

#             fill_col = np.where(bin_col)


#             s =  w[0].size

#             target_ts_list = [] 

#             if s == 0: 
#                 continue 

#             for i in range(s):
#                 x,y,z       = w[0][i], w[1][i], w[2][i]
#                 target_ts   = data_epi[x,y,z]
#                 target_ts_list.append(target_ts)

#             target_ts_mean          = np.mean(target_ts_list,0)
#             target_ts_mean_dt       = signal.detrend(target_ts_mean, type='linear')
#             target_ts_mean_dt_norm  = (target_ts_mean_dt - 
#                                         np.mean(target_ts_mean_dt))/ np.std(target_ts_mean_dt)

#             data_layer_by_col_vox_ts.append(target_ts_mean_dt_norm)
#             data_layer_by_col_vox_l.append(l)
#             data_layer_by_col_vox_c.append(c)
#             data_layer_by_col_vox_fill_c.append(fill_col)


#     data_layer_by_col_vox_ts.append(seed_ts)
#     data_layer_by_col_vox_l.append('seed')
#     data_layer_by_col_vox_c.append('seed')
#     data_layer_by_col_vox_fill_c.append('seed')

    
#     d = np.array(data_layer_by_col_vox_ts)

#     d_corr = np.corrcoef(d)


#     out_strs = [] 

#     # TODO this could be sped up by just iterating
#     for i in range(0, d_corr.shape[0]-1, 3): # shape-1 to account for last row seed
#         print('{} {} {} {}'.format(
#             data_layer_by_col_vox_c[i], 
#             data_layer_by_col_vox_l[i], 
#             data_layer_by_col_vox_l[i+1],
#             data_layer_by_col_vox_l[i+2]))

#         layer_corrs = d_corr[-1,i:i+3]
#         c = data_layer_by_col_vox_c[i]

#         print("c: {} layers: {}".format(c,layer_corrs))



#         str_ff, str_fb, str_deep, str_super, str_other = 0,0,0,0,0


#         # build profile nifti 
#         for ii in range(len(layer_corrs)):
#             x,y,z = data_layer_by_col_vox_fill_c[i]
#             out[x,y,z,ii] = layer_corrs[ii]

#         # INPUT - layer 1 greater 0,2 
#         if (layer_corrs[0] < layer_corrs[1]) & (layer_corrs[2] < layer_corrs[1]):
#             out_ff[x,y,z] = layer_corrs[1]
            
#             str_ff = 1
        
#         # OUTPUT - layers 0,2 greater than 1
#         elif (layer_corrs[0] > layer_corrs[1]) & (layer_corrs[2] > layer_corrs[1]):
#             layer_corrs.sort()
#             out_fb[x,y,z] = layer_corrs[-1] 
            
#             str_fb = 1

#         # DEEP - layer 0 greater than 1,2
#         elif (layer_corrs[0] > layer_corrs[1]) & (layer_corrs[0] > layer_corrs[2]):
#             out_deep[x,y,z] = layer_corrs[0] 

#             str_deep = 1
            
#         # SUPERFICIAL - layer 2 greater 0,1 
#         elif (layer_corrs[2] > layer_corrs[0]) & (layer_corrs[2] > layer_corrs[1]):
#             out_super[x,y,z] = layer_corrs[2] 

#             str_super = 1

#         else: 
#             out_other[x,y,z] = 1 

#             str_other = 1 


#         # output data to text 

#         # c  l1 l2 l3 ff fb deep super other
#         #ID   r  r  r 01 01   01    01    01 
        
#         s_out = "{} {} {} {} {} {}\n".format(c, 
#         layer_corrs[0], layer_corrs[1], layer_corrs[2], 
#         str_ff, str_fb, str_deep, str_super, str_other)

#         out_strs.append(s_out)




#         print("column done: {}".format(c))


#     nii_out = nib.Nifti1Image(out, affine)
#     nib.save(nii_out, '{}/{}.SEED2SEED.profile.nii'.format(outdir, out_prefix))
    
#     nii_out_ff = nib.Nifti1Image(out_ff, affine)
#     nib.save(nii_out_ff, '{}/{}.SEED2SEED.ff.nii'.format(outdir, out_prefix))
    
#     nii_out_fb = nib.Nifti1Image(out_fb, affine)
#     nib.save(nii_out_fb, '{}/{}.SEED2SEED.fb.nii'.format(outdir, out_prefix))

#     nii_out_other = nib.Nifti1Image(out_other, affine)
#     nib.save(nii_out_other, '{}/{}.SEED2SEED.other.nii'.format(outdir, out_prefix))
    
#     nii_out_deep= nib.Nifti1Image(out_deep, affine)
#     nib.save(nii_out_deep, '{}/{}.SEED2SEED.deep.nii'.format(outdir, out_prefix))
    
#     nii_out_super = nib.Nifti1Image(out_super, affine)
#     nib.save(nii_out_super, '{}/{}.SEED2SEED.super.nii'.format(outdir, out_prefix))
    

#     with open('{}/table.csv'.format(outdir),'w') as f: 
#         f.write("c l1 l2 l3 ff fb deep super other\n")
#         for s in out_strs: 
#             f.write(s)
#         f.close()

    

    
#     end = time.perf_counter()
#     diff = end - start 
#     print(diff)







# if __name__ == "__main__":

#     parser = argparse.ArgumentParser()
#     parser.add_argument('--seed', type=str)
#     parser.add_argument('--layers', type=str)
#     parser.add_argument('--columns', type=str)
#     parser.add_argument('--epi', type=str)
#     parser.add_argument('--outdir', type=str)

#     args = parser.parse_args()

#     seed        = args.seed
#     layers      = args.layers
#     columns     = args.columns
#     epi         = args.epi
#     outdir      = args.outdir 

#     '''
#     epi='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/derivatives/sub-01/VASO_func/sub-01_ses-06_task-movie_run-05_VASO.nii'
#     #epi='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/derivatives/sub-01/VASO_func/sub-01_ses-06_task-movie_run-05_VASO.N4bias.detrend.pol2.nii'
#     layers='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/warped_leaky_layers_n3.nii'
#     columns='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/columns_equivol_1000/warped_rim_columns1000.nii'
#     seed='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/rois.thalamic.l3/8209.Right-LGN.nii'
#     #outdir='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/analysis.hcp.l3.SEED2SEED'
#     outdir='test'
#     '''

#     print("seed: " + seed)
#     print("layers: " + layers)
#     print("columns: " + columns)
#     print("epi: " + epi)

#     main(seed, layers, columns, epi, outdir)



