#!/usr/bin/env python

import nibabel as nib
import argparse
import numpy as np
from matplotlib import pyplot as plt
import time 
from scipy import signal, stats
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




n_cores = 10

'''
reverse for loop order 
pca get 10 components 
scaled_data 


'''



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

def set_pub():
    plt.rcParams.update({
        "font.weight": "bold",  # bold fonts
        "tick.labelsize": 15,   # large tick labels
        "lines.linewidth": 1,   # thick lines
        "lines.color": "k",     # black lines
        "grid.color": "0.5",    # gray gridlines
        "grid.linestyle": "-",  # solid gridlines
        "grid.linewidth": 0.5,  # thin gridlines
        "savefig.dpi": 300,     # higher resolution output.
    })

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


    fig = plt.figure(figsize=(10, 10), dpi=400)

    ax1 = fig.add_subplot(4,1,1)
    plt.title('Seed and Control: {}'.format(seed_control_title))
    plt.plot(seed, label='L_LGN')
    plt.plot(control, label='L_MT')
    # plt.plot(glm_inputs['L_LGN - L_MT'], label='L_LGN - L_MT')
    # plt.plot(glm_inputs['L_MT - L_LGN'], label='L_MT - L_LGN')
    plt.plot(glm_inputs['R_V1'], label='R_V1')

    # for k in glm_inputs.keys():
    #     plt.plot(glm_inputs[k], label=k)
    plt.legend()

    ############
    ax2 = fig.add_subplot(4,1,2)
    plt.plot(glm_inputs['L_LGN - L_MT'], label='L_LGN - L_MT')
    plt.plot(glm_inputs['L_MT - L_LGN'], label='L_MT - L_LGN')
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

    fig.savefig(plot_path)
    fig.close() 

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
    for ind in inds: 
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


#TODO add plot dir to jobs 


VASO_dir='/data/kleinrl/ds003216/derivatives/sub-01/VASO_func/'
recon_dir="/data/kleinrl/ds003216/sub-01/ses-01/anat/" + \
            "sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/"

EPIs=glob(VASO_dir + '*movie*VASO.nii')

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
seed_masker = NiftiMasker(standardize=True, mask_strategy='epi',
                          memory="nilearn_cache", memory_level=2,
                          smoothing_fwhm=None)
seed_masker_epi = seed_masker.fit(epi)


del seed_nii, seed_data, seed_ind

# CONTROL ROI
control         = glob(layer4EPI + '/rois.hcp/1023.L_MT.nii')[0]
control_nii     = nib.load(control)
control_data    = control_nii.get_fdata()
control_ind     = np.where(control_data == 1)
control_epi     = epi_data[control_ind]
control_epi_mean= np.mean(control_epi, 0) 
control_pcas_ts    = get_pcas(control_epi.T, num_timeseries=4)
control_pcas_ncomp = get_pcas(control_epi.T, num_components=4)
#control_masker      = NiftiMasker(standardize=True, mask_strategy='epi',
#                          memory="nilearn_cache", memory_level=2,
#                          smoothing_fwhm=None)
#control_masker_epi = control_masker.fit(epi)
#report 

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
        glm_inputs['L_LGN']                     = preproc(seed_epi_mean)
        glm_inputs['L_MT']                      = preproc(control_epi_mean)
        glm_inputs['L_LGN - L_MT']              = preproc(preproc(seed_epi_mean)    - preproc(control_epi_mean))
        glm_inputs['L_MT - L_LGN']              = preproc(preproc(control_epi_mean) - preproc(seed_epi_mean))
        glm_inputs['R_V1']                      = preproc(roi2_epi_mean)

        
        d = {'seed':preproc(seed_epi_mean), 'control': preproc(control_epi_mean), 'glm_inputs': glm_inputs}
        inputs.append(d)



'''
EPIs    = [EPIs[0]]
inputs  = [inputs[0]]
'''

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

        
        try: 
            completed_jobs = parallelize(ind_jobs, regress_across_columns, n_cores=n_cores)
        except Exception as e: 
            print('ERROR - {}'.format(ind_jobs[0]['layer4EPI_base']))
            print(e)

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

