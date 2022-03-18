#!/usr/bin/env python

import nibabel as nib
import argparse
import numpy as np
from matplotlib import pyplot as plt
import time 
from scipy import signal 
import scipy.stats as sp 
from sklearn.preprocessing import normalize
import os
import pandas as pd # for using pandas daraframe
import numpy as np # for som math operations
from sklearn.preprocessing import StandardScaler # for standardizing the Data
from sklearn.decomposition import PCA # for PCA calculation
import matplotlib.pyplot as plt # for plotting
from glob import glob 
from sklearn import linear_model
import numpy as np
import matplotlib.pylab as pl
from glob import glob
import pickle
from multiprocessing import Pool 
from nilearn.input_data import NiftiMasker
from nilearn.masking import apply_mask
from statsmodels.formula.api import ols


'''
TODO
columns 
plot columns 

preproc

pcas 

nifti masker 

'''

n_cores = 10


def parallelize(df_list, func, n_cores=4):
    '''
    func accepts a list of dfs
    :param df_list:
    :param func:
    :param n_cores:
    :return:
    '''
    '''
    async_result = pool.map_async(process_single_df, listOfDfs)
    allDfs = async_result.get()
    '''
    pool = Pool(n_cores)
    df = pool.map(func, df_list)
    pool.close()
    pool.join()

    if type(df) == type(pd.DataFrame()):
        result = {}
        for d in df:
            result.update(d)
        return result
    else:
        return df
    return

def get_pcas(X, num_components=None, num_timeseries=None):
    # time on rows, X
    # voxels on columns, Y

    scaler = StandardScaler()
    X_std = scaler.fit_transform(X) 

    ###########################
    # #NUMBER COMPONENTS 
    if num_components is not None: 
        #pca = PCA()
        #X_pca = pca.fit(X_std)
        #X_pca.explained_variance_.shape 
        #num_components = 4

        pca = PCA(num_components)  
        X_pca = pca.fit_transform(X_std)
        
        ret = X_pca

    ##########################
    # VARIANCE EXPLAINED 
    elif num_timeseries is not None: 
        pca             = PCA(n_components = 0.99)
        X_pca           = pca.fit_transform(X_std) 
        n_pcs           = pca.n_components_ 

        most_important          = [ np.abs(pca.components_[i]).argmax() for i in range(n_pcs)]
        initial_feature_names   = [ x for x in range(0,X_std.shape[1])]
        most_important_names    = [ initial_feature_names[most_important[i]] for i in range(n_pcs)]

        #num_timeseries = 4
        most_important_timeseries = [ X_std[:,x] for x in most_important_names[0:num_timeseries] ]
        
        ret = most_important_timeseries

    else: 
        print('specify param')

    return ret

def preproc(ts): 
    #target_ts_mean          = np.mean(target_ts_list,0)
    target_ts_mean_dt       = signal.detrend(ts, type='linear')
    target_ts_mean_dt_norm  = (target_ts_mean_dt - 
                        np.mean(target_ts_mean_dt))/ np.std(target_ts_mean_dt)

    return target_ts_mean_dt_norm 

def plot_regress_layers(seed, control, glm_inputs, layers, params): 

    #glm_input = control - seed 

    plot_path           = params['plot_path']
    seed_control_title  = params['seed_control_VASO']
    layers_title        = params['layers_VASO']


    fig = plt.figure(figsize=(10, 17), dpi=400)

    ax1 = fig.add_subplot(4,1,1)
    plt.title('Mean Time Courses: {}'.format(seed_control_title))
    plt.plot(seed, label='L_LGN')
    plt.plot(control, label='L_MT')
    
    # plt.plot(glm_inputs['L_LGN - L_MT'], label='L_LGN ~ L_MT')
    # plt.plot(glm_inputs['L_MT - L_LGN'], label='L_MT ~ L_LGN')
    
    plt.plot(glm_inputs['R_V1'], label='R_V1')







    # for k in glm_inputs.keys():
    #     plt.plot(glm_inputs[k], label=k)
    plt.legend()

    ############
    ax2 = fig.add_subplot(4,1,2)
    #plt.plot(preproc(seed), label='L_LGN')
    #plt.plot(preproc(control), label='L_MT')
    #plt.plot(preproc(glm_inputs['L_LGN - L_MT']), label='L_LGN ~ L_MT')
    #plt.plot(preproc(glm_inputs['L_LGN - L_MT X_out']), label='L_LGN ~ L_MT X_out')
    
    plt.title('Residuals')
    plt.plot(preproc(glm_inputs['L_MT - L_LGN']), label='L_MT ~ L_LGN')
    plt.plot(preproc(glm_inputs['L_LGN - L_MT']), label='L_LGN ~ L_MT')


    #plt.plot(glm_inputs['L_MT - L_LGN'], label='L_MT ~ L_LGN')
    plt.legend()

    n=len(layers)
    colors = pl.cm.jet(np.linspace(0,1,n))
    colors = ['red','orange','green']


    ###############
    ax3 = fig.add_subplot(4,1,3)
    plt.title("Layers (n=3): {}".format(layers_title))
    for l in range(len(layers)):
        plt.plot(layers[l], label='V1_l{}'.format(l), color=colors[l])
    plt.legend()

    coefs = {}

    k_i = 0 
    #for k in ['seed - control', 'control - seed', 'R_V1']:

    xts =  ['Seed: L_Thalamus\nControl: L_MT\nTarget: L_V1', 
            'Seed: L_MT\nControl: L_Thalamus\nTarget: L_V1',
            'Seed: R_V1\nControl: None\nTarget: L_V1']
    axs = [] 

    for k in ['L_LGN - L_MT', 'L_MT - L_LGN', 'R_V1']:
        #glm_inputs.keys():

        reg = linear_model.LinearRegression()
        reg.fit(layers.T, glm_inputs[k])
        coef = reg.coef_

        sp = 10+k_i 


        axs.append(fig.add_subplot(4,3,sp))

        plt.title(xts[k_i])
        
        plt.xticks([-1,4], ['CSF','WM'])
        #plt.xlabels(['CSF','WM'])

        plt.plot(coef)
        k_i += 1 
        coefs[k] = coef
    
    # plt.subplot(326)
    # plt.title("Regression weights (detrended and normalized)")
    # plt.plot(preproc(coefs))

    fig.savefig(plot_path, bbox_inches='tight')
    plt.close() 

    # plt.title('Seed and Control: {}'.format(seed_control_title))
    # plt.plot(seed, label='L_LGN')
    # plt.plot(control, label='L_MT')
    # # plt.plot(glm_inputs['L_LGN - L_MT'], label='L_LGN - L_MT')
    # # plt.plot(glm_inputs['L_MT - L_LGN'], label='L_MT - L_LGN')
    # plt.plot(glm_inputs['R_V1'], label='R_V1')

    # # for k in glm_inputs.keys():
    # #     plt.plot(glm_inputs[k], label=k)
    # plt.legend()

    # ############
    # plt.subplot(412)
    # plt.plot(glm_inputs['L_LGN - L_MT'], label='L_LGN - L_MT')
    # plt.plot(glm_inputs['L_MT - L_LGN'], label='L_MT - L_LGN')
    # plt.legend()

    # n=len(layers)
    # colors = pl.cm.jet(np.linspace(0,1,n))
    # colors = ['red','orange','green']


    # ###############
    # plt.subplot(413)
    # plt.title("Layers (n=3): {}".format(layers_title))
    # for l in range(len(layers)):
    #     plt.plot(layers[l], label='V1_l{}'.format(l), color=colors[l])
    # plt.legend()

    # coefs = {}

    # k_i = 0 
    # #for k in ['seed - control', 'control - seed', 'R_V1']:

    # xts =  ['Seed: L_Thalamus\nControl: L_MT\nTarget: L_V1', 
    #         'Seed: L_MT\nControl: L_Thalamus\nTarget: L_V1',
    #         'Seed: R_V1\nControl: None\nTarget: L_V1']

    # for k in ['L_LGN - L_MT', 'L_MT - L_LGN', 'R_V1']:
    #     #glm_inputs.keys():

    #     reg = linear_model.LinearRegression()
    #     reg.fit(layers.T, glm_inputs[k])
    #     coef = reg.coef_

    #     sp = 4310+k_i 

    #     plt.subplot(sp)
    #     plt.title(xts[k_i])
        
    #     plt.xticks([-1,4], ['CSF','WM'])
    #     #plt.xlabels(['CSF','WM'])

    #     plt.plot(coef)
    #     k_i += 1 
    #     coefs[k] = coef
    
    # # plt.subplot(326)
    # # plt.title("Regression weights (detrended and normalized)")
    # # plt.plot(preproc(coefs))

    # plt.savefig(plot_path)
    # plt.close() 

    return coefs

def plot_group_regress_layers(competed_jobs, plot_path): 
    #def plot_group_regress_layers(seed, control, glm_inputs, layers, plot_path): 

    #glm_input = control - seed 
    
    plt.figure(figsize=(10, 10), dpi=400)

    plt.subplot(311)
    #plt.figure()
    plt.plot(seed, label='seed (LGN)')
    plt.plot(control, label='control (MT)')
    plt.plot(glm_input, label='control - seed (glm_input)')
    plt.legend()

    n=len(layers)
    colors = pl.cm.jet(np.linspace(0,1,n))
    colors = ['red','orange','green']


    plt.subplot(312)
    #plt.figure()
    for l in range(len(layers)):
        plt.plot(layers[l], label='V1_l{}'.format(l), color=colors[l])
    plt.legend()



    reg = linear_model.LinearRegression()
    reg.fit(layers.T, glm_input)
    coefs = reg.coef_

    plt.subplot(325)
    #plt.figure()
    plt.plot(coefs)
    
    plt.subplot(326)
    #plt.figure()
    plt.plot(preproc(coefs))

    plt.savefig(plot_path)
    plt.close() 

    return coefs

def get_columns_by_roi(column_file, roi_file): 
    '''
    returns column_id that are within ROI file 
    '''

    column_nii        = nib.load(column_file)
    column_data       = column_nii.get_fdata()


    roi_nii        = nib.load(roi_file)
    roi_data       = roi_nii.get_fdata()
    roi_ind        = np.where(roi_data == 1)

    columns_in_roi = column_data[roi_ind]
    column_ids_in_roi = np.unique(columns_in_roi)

    #column_ind        = np.where(column_data == 1)
    #column_epi        = epi_data[column_ind]
    #column_epi_mean   = np.mean(column_epi, 0)
    #column_pcas       = get_pcas(column_epi.T, num_timeseries=4)
    #del column_nii, column_data, column_ind

    return column_ids_in_roi

def regress_across_columns(job):
    seed                = job['seed']
    control             = job['control']
    glm_inputs          = job['glm_inputs']
    cs                  = job['cs']
    ls                  = job['ls']
    inds                = job['inds']  
    layer4EPI_base      = job['layer4EPI_base']
    seed_control_VASO   = job['seed_control_VASO']


    regressors = []
    for i in range(len(inds)): 
        #print(ls[i])
        ind = inds[i]
        ind_epi = epi_data[ind]
        ind_epi_mean = preproc(np.mean(ind_epi, 0))
        regressors.append(ind_epi_mean) 
    regressors      = np.array(regressors) 


    plot_dir    ='/home/kleinrl/plots/regressLayers_roi' #+layer4EPI_base
    os.makedirs(plot_dir, exist_ok=True) 
    #plot_path   = plot_dir + '.png'
    plot_path   = plot_dir + '/' + layer4EPI_base + '.png'

    params = {  'plot_path': plot_path, 
                'seed_control_VASO': seed_control_VASO,
                'layers_VASO': layer4EPI_base }

    coefs        = plot_regress_layers(seed, control, glm_inputs, regressors, params)


    job['coefs'] = coefs 
    
    return job 

def regress_out_control_signal(X, Y):
    # seed = ( a * control ) - b
    # Y = (a X) + b 
    # Y* = Y - aX
    # a = (X' X ) ^ -1 X'Y
    # Y* = Y - ((X' X) ^ -1 X'Y)X 
    '''
    X = seed_epi_mean
    Y = control_epi_mean 

    '''

    # X_ = np.array([ [i, X[i]] for i in range(len(X)) ])
    # Y_ = np.array([ [i, Y[i]] for i in range(len(Y)) ])

    # #bh = np.dot(np.linalg.inv(np.dot(X.T,X)),np.dot(X.T,Y))
    # #print('\nbh')
    # #print(bh)
    
    # z,resid,rank,sigma = np.linalg.lstsq(X_,Y_, rcond=None)
    # print('\nnp.linalg.lstsq')
    # print('z: {}'.format(z))
    # print('resid: {}'.format(resid))

    # Y_out = [ Y_[i,1]-(resid[0]+(resid[1]*X_[i,1])) for i in range(X_.shape[0])]

    
    data = pd.DataFrame({'X':X,'Y':Y})
    res = ols('X ~ Y', data).fit()
    y_int = res.params[0]
    slope = res.params[1]

    X_out = [ ( ( slope * X[i] ) + y_int ) for i in range(X.shape[0])]
    Y_out = [  Y[i] - X_out[i] for i in range(len(X_out))]

    #Y_out = [ Y[i] - ( ( slope * X[i] ) + y_int ) for i in range(X.shape[0])]

    return Y_out, X_out

VASO_dir='/data/kleinrl/ds003216/derivatives/sub-01/VASO_func/'
recon_dir="/data/kleinrl/ds003216/sub-01/ses-01/anat/" + \
            "sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/"

EPIs=glob(VASO_dir + '*movie*VASO.nii')
#EPIs.sort()

coefs           = [] 
seeds_list      = [] 
controls_list   = []
layers_list     = []
coef_list       = []

# EPI RUN
epi = EPIs[0]
#EPIs = [ EPIs[4] ]
epi_nii         = nib.load(epi)
epi_data        = epi_nii.get_fdata()

layer4EPI_base = epi.split('/')[-1].split('.')[0]
layer4EPI      = recon_dir + '/LAYNII_'+layer4EPI_base
seed_control_VASO = layer4EPI_base

# SEED ROI
seed            = glob(layer4EPI + '/rois.thalamic.l3/8109.lh.LGN.nii' )[0]
seed_nii        = nib.load(seed)
seed_data       = seed_nii.get_fdata()
seed_ind        = np.where(seed_data == 1)
seed_epi        = epi_data[seed_ind]
seed_epi_mean   = np.mean(seed_epi, 0)
seed_pcas_ts    = get_pcas(seed_epi.T, num_timeseries=4)
seed_pcas_ncomp = get_pcas(seed_epi.T, num_components=4)
seed_masker = NiftiMasker(mask_img=seed) 
# , standardize=True, 
#                           memory="nilearn_cache", memory_level=2,
#                           smoothing_fwhm=None) #mask_strategy='epi',
seed_masker_epi = seed_masker.fit(epi)
seed_masker_epi_report = seed_masker_epi.generate_report()
save_path = '/home/kleinrl/plots/reports/seed_report.html'
seed_masker_epi_report.save_as_html(save_path)

del seed_nii, seed_data, seed_ind

# CONTROL ROI
control         = glob(layer4EPI + '/rois.hcp/1023.L_MT.nii')[0]
control_nii     = nib.load(control)
control_data    = control_nii.get_fdata()
control_ind     = np.where(control_data == 1)
control_epi     = epi_data[control_ind]
control_epi_mean= np.mean(control_epi, 0) 

# control_epi2 = apply_mask(epi, control)
# control_epi2_mean= np.mean(control_epi2, 0) 
# plt.figure()
# plt.plot(control_epi_mean)
# plt.plot(control_epi2_mean)
# plt.savefig('/home/kleinrl/comp_extract.png')

control_pcas_ts    = get_pcas(control_epi.T, num_timeseries=4)
control_pcas_ncomp = get_pcas(control_epi.T, num_components=4)
# control_masker      = NiftiMasker(standardize=True, mask_strategy='epi',
#                          memory="nilearn_cache", memory_level=2,
#                          smoothing_fwhm=None)
# control_masker_epi = control_masker.fit(epi)
# control_masker_epi_report = seed_masker_epi.generate_report()
# control_path = '/home/kleinrl/plots/reports/control_report.html'
# control_masker_epi_report.save_as_html(save_path) 


del control_nii, control_data, control_ind

# TODO get pca voxels for plotting 

roi2_file        = layer4EPI + '/rois.hcp/2001.R_V1.nii'
roi2_nii         = nib.load(roi2_file)
roi2_data        = roi2_nii.get_fdata()
roi2_ind         = np.where(roi2_data == 1)
roi2_epi         = epi_data[roi2_ind]
roi2_epi_mean    = np.mean(roi2_epi, 0) 
roi2_pcas_ncomp  = get_pcas(roi2_epi, num_components=4)


inputs = []
# for seed_pca in seed_pcas_ncomp: 
#     for control_pca in control_pcas_ncomp: 
for seed_pca in [seed_epi_mean]: 
    for control_pca in [control_epi_mean]: 

        glm_inputs = {}
        glm_inputs['L_LGN']                     = seed_epi_mean
        glm_inputs['L_MT']                      = control_epi_mean      
        
        #glm_inputs['L_LGN']                     = preproc(seed_epi_mean)
        #glm_inputs['L_MT']                      = preproc(control_epi_mean)  

        #glm_inputs['L_LGN - L_MT']              = preproc(preproc(seed_epi_mean)    - preproc(control_epi_mean))
        #glm_inputs['L_MT - L_LGN']              = preproc(preproc(control_epi_mean) - preproc(seed_epi_mean))
        

        Y_out, X_out                            = regress_out_control_signal(seed_epi_mean, control_epi_mean)
        glm_inputs['L_LGN - L_MT']              = Y_out
        glm_inputs['L_LGN - L_MT X_out']        = X_out

        Y_out, X_out                            = regress_out_control_signal(control_epi_mean, seed_epi_mean)
        glm_inputs['L_MT - L_LGN']              = Y_out
        glm_inputs['L_MT - L_LGN X_out']        = X_out



        #glm_inputs['L_LGN - L_MT']              = regress_out_control_signal(seed_epi_mean, control_epi_mean)
        #glm_inputs['L_MT - L_LGN']              = regress_out_control_signal(control_epi_mean, seed_epi_mean)
        

        #glm_inputs['L_LGN - L_MT']              = preproc(seed_epi_mean    - control_epi_mean)
        #glm_inputs['L_MT - L_LGN']              = preproc(control_epi_mean - seed_epi_mean)
        
        #glm_inputs['R_V1']                      = preproc(roi2_epi_mean)
        glm_inputs['R_V1']                      = roi2_epi_mean

        
        d = {'seed':preproc(seed_epi_mean), 'control': preproc(control_epi_mean), 'glm_inputs': glm_inputs}
        inputs.append(d)



'''
EPIs    = [EPIs[0]]
inputs  = [inputs[0]]
'''
completed_jobs = [] 

for e_i in range(len(EPIs)):
    for d_i in range(len(inputs)): 
        


        epi = EPIs[e_i]
        d   = inputs[d_i]
        




        print("seed/control-perms: {}/{} EPIs: {}/{} total: {}/{}"
        .format(d_i, len(inputs), 
                e_i, len(EPIs), 
                (d_i*len(EPIs))+e_i,
                len(inputs)*len(EPIs)))
        

        '''
        d = inputs[0]
        epi = EPIs[4]
        '''
        seed        = d['seed']
        control     = d['control']
        glm_inputs   = d['glm_inputs']


        layer4EPI_base = epi.split('/')[-1].split('.')[0]
        layer4EPI      = recon_dir + '/LAYNII_'+layer4EPI_base







        #column_file =layer4EPI + '/warped_rim_columns10000.resample2muncorr.nii'
        roi_file    =layer4EPI + '/rois.hcp/1001.L_V1.nii'
        layer_file  =layer4EPI + '/warped_equi_volume_layers_n3.resample2muncorr.nii'

        try:
            roi_masker      = NiftiMasker(mask_img=roi_file) 
            roi_masker_epi  = roi_masker.fit(epi)
            roi_masker_epi_report = roi_masker_epi.generate_report()
            save_path = '/home/kleinrl/plots/reports/roi_report_{}.html'.format(layer4EPI_base)
            roi_masker_epi_report.save_as_html(save_path)
            plt.close()
        except Exception as e: 
            print(e)

        #try: 
        #    column_ids  = get_columns_by_roi(column_file=column_file, roi_file=roi_file)
        #except Exception as e: 
        #    print('fix missing ROI')
        #    print(e)

        layer_ids   = [3, 2, 1]


        #column_nii        = nib.load(column_file)
        #column_data       = column_nii.get_fdata()

        layer_nii        = nib.load(layer_file)
        layer_data       = layer_nii.get_fdata()

        

        try: 
            roi_nii         = nib.load(roi_file)
            roi_data        = roi_nii.get_fdata()
            roi_ind         = np.where(roi_data == 1)
            roi_epi         = epi_data[roi_ind]
            roi_epi_mean    = np.mean(roi_epi, 0) 
            roi_pcas_ncomp  = get_pcas(roi_epi, num_components=4)

        except: 
            print('fix this - missing rois')
            print(roi_file)
            continue 

        #columns_in_roi = column_data[roi_ind]


        column_ids = np.unique(roi_data)
        column_data = roi_data 

        ind_jobs = []         
        for c in column_ids: 
            inds, cs, ls = [], [], [] 

            p = 0 
            for l in layer_ids:
                ind = np.where( (column_data == c) & (layer_data == l) )
                inds.append(ind)
                cs.append(c)
                ls.append(l)
                if ind[0].size != 0: 
                    p += 1 

            if p < 3: 
                continue 
        
            # TODO add d seed, control, glm_input here 
            job = {'inds': inds, 'cs': cs, 'ls': ls, 
                    'seed': seed, 'control': control, 'glm_inputs': glm_inputs, 
                    'layer4EPI_base': layer4EPI_base, 
                    'seed_control_VASO': seed_control_VASO }
            

            ind_jobs.append(job)


        #plot_regress_layers(seed, control, glm_inputs, layers, params)

        

        '''
        completed_jobs = parallelize(ind_jobs[0:10], regress_across_columns, n_cores=10)
        regress_across_columns(ind_jobs[0])
        '''

        
        # try: 
        #     completed_jobs = parallelize(ind_jobs, regress_across_columns, n_cores=n_cores)
        # except Exception as e: 
        #     print('ERROR - {}'.format(ind_jobs[0]['layer4EPI_base']))
        #     print(e)

        completed_jobs.append(regress_across_columns(ind_jobs[0]))

xts =  ['Seed: L_Thalamus Control: L_MT\nTarget: L_V1 (n={})'.format(len(completed_jobs)), 
            'Seed: L_MT Control: L_Thalamus\nTarget: L_V1 (n={})'.format(len(completed_jobs)),
            'Seed: R_V1 Control: None\nTarget: L_V1 (n={})'.format(len(completed_jobs))]

fig, axs = plt.subplots(ncols=3, sharex=True, figsize=(12,4))
axs_i = 0 
for k in completed_jobs[0]['coefs'].keys():
    
    coefs = []
    for cj in completed_jobs:
            coefs.append(cj['coefs'][k])

    m = np.mean(coefs,0) 
    s = np.std(coefs,0)
    se = sp.sem(coefs) 

    upper = m + se
    lower = m - se 

    x = range(len(m))

    axs[axs_i].errorbar(x, m, yerr=se, fmt='-o') #[upper, lower]
    axs[axs_i].set_title(xts[axs_i])

    axs[axs_i].set_xticks([0, 2])
    axs[axs_i].set_xticklabels(['CSF','WM'])


    axs_i += 1 

plt.savefig('/home/kleinrl/plots/grp.png')
plt.close()










        # plot_dir    ='/home/kleinrl/plots/regressLayers_columns_'+layer4EPI_base
        # os.makedirs(plot_dir, exist_ok=True) 
        # with  open('{}/completed_jobs.pkl'.format(plot_dir), "wb" )  as f: 
        #     pickle.dump(completed_jobs,f)
          

        #completed_jobs = pickle.load( open( plot_dir+'.pkl', "rb" ) )

        # coef_list = [] 
        # for job in ind_jobs: 
        #     coef = regress_across_columns(job)
        #     coef_list.append(coef) 
            



#plot_group_regress_layers(completed_jobs)


    # coef_means = np.mean(coef_list,0)
    # coef_std   = np.std(coef_list,0)

    # plt.figure()
    # plt.subplot(221)
    # for coef in coef_list: 
    #     plt.plot(coef)
    # plt.subplot(222)

    # plt.savefig('grp.png')



    # PLOT 

    # pca_count = 0
    # for pca_seed in pcas_seed: 
    #     #for pca_control in pcas_control: 
            
    #     seed    = preproc(pca_seed)
    #     control = preproc(epi_control_mean)

    #     layers = [ preproc(l) for l in epi_targets_mean ]
    #     layers = np.array(layers) 
    #     layers.shape

    #     glm_input = control - seed

    #     os.makedirs(outdir) if not os.path.exists(outdir) else print('exists')
    #     plot_path = 'plots_regressLayers/{}_{}.png'.format(layer4EPI_base, pca_count)
    #     coef = plot_regress_layers(seed, control, glm_input, layers, plot_path)
    #     pca_count += 1 
