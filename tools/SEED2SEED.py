#!/usr/bin/env python

import nibabel as nib
import argparse
import numpy as np
from matplotlib import pyplot as plt
import time 
from scipy import signal 
from sklearn.preprocessing import normalize
import os


def extract_rim_to_array(): 
    print('extracting and creating dataframe')

def regress_out(): 
    print('regressing out')


def correlations(): 
    print('print runnign corrs')

def build_nifti():
    print('building nifti')




#@numba.jit(parallel=True) # 105 
# without 99 
def main(seed, layers, columns, epi, outdir):

    if not os.path.exists(outdir):
        os.makedirs(outdir)



    out_prefix = seed.split('/')[-1].strip('.nii')

    start = time.perf_counter()


    nii_seed = nib.load(seed)
    data_seed = nii_seed.get_fdata()


    nii_layers = nib.load(layers)
    data_layers = nii_layers.get_fdata()

    nii_columns = nib.load(columns)
    data_columns = nii_columns.get_fdata()

    nii_epi = nib.load(epi)
    data_epi = nii_epi.get_fdata()


    ind_seed = np.where(data_seed == 1)
    affine = nii_seed.affine
    ss = data_seed.shape

    del nii_seed, nii_layers, nii_columns, nii_epi 
    

    out = np.zeros((ss[0], ss[1], ss[2],len(np.unique(data_layers))-1))
    out_ff = np.zeros((ss[0], ss[1], ss[2],1))
    out_fb = np.zeros((ss[0], ss[1], ss[2],1))
    out_other = np.zeros((ss[0], ss[1], ss[2],1))
    out_deep = np.zeros((ss[0], ss[1], ss[2],1))
    out_super = np.zeros((ss[0], ss[1], ss[2],1))





    # average epi
    seed_ts_s = data_epi[ind_seed]
    seed_mean = np.mean(seed_ts_s,0)

    print("ts size: {}".format(seed_mean.size))

    seed_ts_dt = signal.detrend(seed_mean, type='linear')
    seed_ts_dt_n = (seed_ts_dt - np.mean(seed_ts_dt))/ np.std(seed_ts_dt)



    #plt.plot(seed_ts)
    #plt.show()

    #plt.plot(seed_ts_dt)
    #plt.show()

    #plt.plot(seed_ts_dt_n)
    #plt.show()

    seed_ts = seed_ts_dt_n

    unq_columns = np.unique(data_columns)
    unq_columns = unq_columns[1:]

    unq_layers = np.unique(data_layers)
    unq_layers = unq_layers[1:]

    out_strs = [] 

    for c in unq_columns:
        layer_corrs = []
        for l in unq_layers:
            w = np.where((data_layers == l) & (data_columns == c))
            s =  w[0].size
            corrs = []
            for i in range(s):
                x,y,z = w[0][i], w[1][i], w[2][i]

                epi_ts = data_epi[x,y,z]
                epi_ts_dt = signal.detrend(epi_ts, type='linear')
                epi_ts_dt_n = (epi_ts_dt - np.mean(epi_ts_dt))/ np.std(epi_ts_dt)
                #plt.plot(epi_ts_dt_n)
                #plt.show()

                corr = np.corrcoef(seed_ts, epi_ts_dt_n)[0,1]
                corrs.append(corr)

            corr_mean = np.mean(corrs)
            layer_corrs.append(corr_mean)



        wc = np.where(data_columns == c)
        s = wc[0].size
        for i in range(s):

            str_ff, str_fb, str_deep, str_super, str_other = 0,0,0,0,0


            # build profile nifti 
            for ii in range(len(layer_corrs)):
                x,y,z = wc[0][i],wc[1][i],wc[2][i]
                out[x,y,z,ii] = layer_corrs[ii]

            # INPUT - layer 1 greater 0,2 
            if (layer_corrs[0] < layer_corrs[1]) & (layer_corrs[2] < layer_corrs[1]):
                out_ff[x,y,z] = layer_corrs[1]
                
                str_ff = 1
            
            # OUTPUT - layers 0,2 greater than 1
            elif (layer_corrs[0] > layer_corrs[1]) & (layer_corrs[2] > layer_corrs[1]):
                layer_corrs.sort()
                out_fb[x,y,z] = layer_corrs[-1] 
                
                str_fb = 1

            # DEEP - layer 0 greater than 1,2
            elif (layer_corrs[0] > layer_corrs[1]) & (layer_corrs[0] > layer_corrs[2]):
                out_deep[x,y,z] = layer_corrs[0] 

                str_deep = 1
                
            # SUPERFICIAL - layer 2 greater 0,1 
            elif (layer_corrs[2] > layer_corrs[0]) & (layer_corrs[2] > layer_corrs[1]):
                out_super[x,y,z] = layer_corrs[2] 

                str_super = 1

            else: 
                out_other[x,y,z] = 1 

                str_other = 1 


            # output data to text 

            # c  l1 l2 l3 ff fb deep super other
            #ID   r  r  r 01 01   01    01    01 
            
            # s_out = "{} {} {} {} {} {}".format(c, 
            # layer_corrs[0], layer_corrs[1], layer_corrs[2], 
            # str_ff, str_fb, str_deep, str_super, str_other)

            # out_strs.append(s_out)




        print("column done: {}".format(c))


    nii_out = nib.Nifti1Image(out, affine)
    nib.save(nii_out, '{}/{}.SEED2SEED.profile.nii'.format(outdir, out_prefix))
    
    nii_out_ff = nib.Nifti1Image(out_ff, affine)
    nib.save(nii_out_ff, '{}/{}.SEED2SEED.ff.nii'.format(outdir, out_prefix))
    
    nii_out_fb = nib.Nifti1Image(out_fb, affine)
    nib.save(nii_out_fb, '{}/{}.SEED2SEED.fb.nii'.format(outdir, out_prefix))

    nii_out_other = nib.Nifti1Image(out_other, affine)
    nib.save(nii_out_other, '{}/{}.SEED2SEED.other.nii'.format(outdir, out_prefix))
    
    nii_out_deep= nib.Nifti1Image(out_deep, affine)
    nib.save(nii_out_deep, '{}/{}.SEED2SEED.deep.nii'.format(outdir, out_prefix))
    
    nii_out_super = nib.Nifti1Image(out_super, affine)
    nib.save(nii_out_super, '{}/{}.SEED2SEED.super.nii'.format(outdir, out_prefix))
    

    # with open('table.csv') as f: 
    #     f.write("c  l1 l2 l3 ff fb deep super other")
    #     for s in out_strs: 
    #         f.write(s)

    
    end = time.perf_counter()
    diff = end - start 
    print(diff)







if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument('--seed', type=str)
    parser.add_argument('--layers', type=str)
    parser.add_argument('--columns', type=str)
    parser.add_argument('--epi', type=str)
    parser.add_argument('--outdir', type=str)

    args = parser.parse_args()

    seed        = args.seed
    layers      = args.layers
    columns     = args.columns
    epi         = args.epi
    outdir      = args.outdir 

    '''
    epi='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/derivatives/sub-01/VASO_func/sub-01_ses-06_task-movie_run-05_VASO.nii'
    #epi='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/derivatives/sub-01/VASO_func/sub-01_ses-06_task-movie_run-05_VASO.N4bias.detrend.pol2.nii'
    layers='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/warped_leaky_layers_n3.nii'
    columns='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/columns_equivol_1000/warped_rim_columns1000.nii'
    seed='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/rois.thalamic.l3/8209.Right-LGN.nii'
    '''

    print("seed: " + seed)
    print("layers: " + layers)
    print("columns: " + columns)
    print("epi: " + epi)

    main(seed, layers, columns, epi, outdir)





    #     unq_columns = np.unique(data_columns)
    #     unq_columns = unq_columns[1:]

    #     unq_layers = np.unique(data_layers)
    #     unq_layers = unq_layers[1:]

    #     for c in unq_columns:
    #         layer_corrs = []
    #         for l in unq_layers:
    #             w = np.where((data_layers == l) & (data_columns == c))
    #             s =  w[0].size
    #             corrs = []
    #             for i in range(s):
    #                 x,y,z = w[0][i], w[1][i], w[2][i]

    #                 epi_ts = data_epi[x,y,z]
    #                 epi_ts_dt = signal.detrend(epi_ts, type='linear')
    #                 epi_ts_dt_n = (epi_ts_dt - np.mean(epi_ts_dt))/ np.std(epi_ts_dt)
    #                 #plt.plot(epi_ts_dt_n)
    #                 #plt.show()

    #                 corr = np.corrcoef(seed_ts, epi_ts_dt_n)[0,1]
    #                 corrs.append(corr)

    #             corr_mean = np.mean(corrs)
    #             layer_corrs.append(corr_mean)

    #         wc = np.where(data_columns == c)
    #         s = wc[0].size
    #         for i in range(s):

    #             # build profile nifti 
    #             for ii in range(len(layer_corrs)):
    #                 x,y,z = wc[0][i],wc[1][i],wc[2][i]
    #                 out[x,y,z,ii] = layer_corrs[ii]

    #             # INPUT - layer 1 greater 0,2 
    #             if (layer_corrs[0] < layer_corrs[1]) & (layer_corrs[2] < layer_corrs[1]):
    #                 out_ff[x,y,z] = layer_corrs[1]
                
    #             # OUTPUT - layers 0,2 greater than 1
    #             elif (layer_corrs[0] > layer_corrs[1]) & (layer_corrs[2] > layer_corrs[1]):
    #                 layer_corrs.sort()
    #                 out_fb[x,y,z] = layer_corrs[-1] 
                    
    #             # DEEP - layer 0 greater than 1,2
    #             elif (layer_corrs[0] > layer_corrs[1]) & (layer_corrs[0] > layer_corrs[2]):
    #                 out_deep[x,y,z] = layer_corrs[0] 
                    
    #             # SUPERFICIAL - layer 2 greater 0,1 
    #             elif (layer_corrs[2] > layer_corrs[0]) & (layer_corrs[2] > layer_corrs[1]):
    #                 out_super[x,y,z] = layer_corrs[2] 
    #             else: 
    #                 out_other[x,y,z] = 1 
    #         print("column done: {}".format(c))


    # nii_out = nib.Nifti1Image(out, affine)
    # nib.save(nii_out, '{}.SEED2SEED.profile.nii'.format(out_prefix))
    
    # nii_out_ff = nib.Nifti1Image(out_ff, affine)
    # nib.save(nii_out_ff, '{}.SEED2SEED.ff.nii'.format(out_prefix))
    
    # nii_out_fb = nib.Nifti1Image(out_fb, affine)
    # nib.save(nii_out_fb, '{}.SEED2SEED.fb.nii'.format(out_prefix))

    # nii_out_other = nib.Nifti1Image(out_other, affine)
    # nib.save(nii_out_other, '{}.SEED2SEED.other.nii'.format(out_prefix))
    
    # nii_out_deep= nib.Nifti1Image(out_deep, affine)
    # nib.save(nii_out_deep, '{}.SEED2SEED.deep.nii'.format(out_prefix))
    
    # nii_out_super = nib.Nifti1Image(out_super, affine)
    # nib.save(nii_out_super, '{}.SEED2SEED.super.nii'.format(out_prefix))
    
    
    # end = time.perf_counter()
    # diff = end - start 
    # print(diff)


    # @numba.jit(parallel=True, nopython=True)
    # def calc(data_layers, data_columns, data_epi):
    #     unq_columns = np.unique(data_columns)
    #     unq_columns = unq_columns[1:]

    #     unq_layers = np.unique(data_layers)
    #     unq_layers = unq_layers[1:]

    #     for c in unq_columns:
    #         layer_corrs = []
    #         for l in unq_layers:
    #             w = np.where((data_layers == l) & (data_columns == c))
    #             s =  w[0].size
    #             corrs = []
    #             for i in range(s):
    #                 x,y,z   = w[0][i], w[1][i], w[2][i]

    #                 epi_ts  = data_epi[x,y,z]
    #                 epi_ts_dt = signal.detrend(epi_ts, type='linear')

    #                 epi_ts_dt_n = (epi_ts_dt - np.mean(epi_ts_dt))/ np.std(epi_ts_dt)
    #                 corr = np.corrcoef(seed_ts, epi_ts_dt_n)[0,1]
    #                 corrs.append(corr)

    #             corr_mean = np.mean(corrs)
    #             layer_corrs.append(corr_mean)

    #         wc = np.where(data_columns == c)
    #         s = wc[0].size
    #         for i in range(s):

    #             # build profile nifti 
    #             for ii in range(len(layer_corrs)):
    #                 x,y,z = wc[0][i],wc[1][i],wc[2][i]
    #                 out[x,y,z,ii] = layer_corrs[ii]

    #             # INPUT - layer 1 greater 0,2 
    #             if (layer_corrs[0] < layer_corrs[1]) & (layer_corrs[2] < layer_corrs[1]):
    #                 out_ff[x,y,z] = layer_corrs[1]
                
    #             # OUTPUT - layers 0,2 greater than 1
    #             elif (layer_corrs[0] > layer_corrs[1]) & (layer_corrs[2] > layer_corrs[1]):
    #                 layer_corrs.sort()
    #                 out_fb[x,y,z] = layer_corrs[-1] 
                    
    #             # DEEP - layer 0 greater than 1,2
    #             elif (layer_corrs[0] > layer_corrs[1]) & (layer_corrs[0] > layer_corrs[2]):
    #                 out_deep[x,y,z] = layer_corrs[0] 
                    
    #             # SUPERFICIAL - layer 2 greater 0,1 
    #             elif (layer_corrs[2] > layer_corrs[0]) & (layer_corrs[2] > layer_corrs[1]):
    #                 out_super[x,y,z] = layer_corrs[2] 
    #             else: 
    #                 out_other[x,y,z] = 1 
    #         print("column done: {}".format(c))

    #         d = {'out':out, 'out_ff': out_ff, 'out_fb': out_fb, 'out_deep': out_deep, 
    #         'out_super': out_super, 'out_other': out_other}

    #     return d

    # d = calc(data_layers, data_columns, data_epi)


    # out         = d['out']
    # out_ff      = d['out_ff'] 
    # out_fb      = d['out_fb']
    # out_deep    = d['out_deep']
    # out_super   = d['out_super']
    # out_other   = d['out_other']