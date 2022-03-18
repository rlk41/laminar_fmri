#!/usr/bin/env python

import nibabel.freesurfer.mghformat as mgh
import nibabel.freesurfer.io as fsio 
from re import match
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
import argparse
import time 
import random 


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
    # layers = regressors 
    plot_path           = params['plot_path']
    seed_control_title  = params['seed_control_VASO']
    layers_title        = params['layers_VASO']
    plot_verts          = params['plot_verts']

    if plot_verts: 
        fig = plt.figure(figsize=(10, 17), dpi=400)

        ax1 = fig.add_subplot(4,1,1)
        plt.title('Mean Time Courses: {}'.format(seed_control_title))
        plt.plot(seed, label='L_LGN')
        plt.plot(control, label='L_MT')
        plt.plot(glm_inputs['R_V1'], label='R_V1')
        plt.legend()

        ############
        ax2 = fig.add_subplot(4,1,2)
        plt.title('Residuals')
        plt.plot(preproc(glm_inputs['L_MT - L_LGN']), label='L_MT ~ L_LGN')
        plt.plot(preproc(glm_inputs['L_LGN - L_MT']), label='L_LGN ~ L_MT')
        plt.legend()


    n=layers.shape[1]
    if n == 110: 
        n = layers.shape[0]

    colors = pl.cm.jet(np.linspace(0,1,n))

    if plot_verts:
        ###############
        ax3 = fig.add_subplot(4,1,3)
        plt.title("Layers (n=3): {}".format(layers_title))
        for l in range(n):
            plt.plot(layers[:,l], label='V1_l{}'.format(l), color=colors[l])
        plt.legend()




    coefs = {}
    k_i = 0 

    xts =  ['Seed: L_Thalamus\nControl: L_MT\nTarget: L_V1', 
            'Seed: L_MT\nControl: L_Thalamus\nTarget: L_V1',
            'Seed: R_V1\nControl: None\nTarget: L_V1']
    axs = [] 

    for k in ['L_LGN - L_MT', 'L_MT - L_LGN', 'R_V1']:

        reg = linear_model.LinearRegression()
        reg.fit(layers, glm_inputs[k])
        coef = reg.coef_

        sp = 10+k_i 


        if plot_verts:
            axs.append(fig.add_subplot(4,3,sp))
            plt.title(xts[k_i])
            plt.xticks([-1,n], ['CSF','WM'])
            plt.plot(coef)


        k_i += 1 
        coefs[k] = coef
    

    if plot_verts: 
        fig.savefig(plot_path, bbox_inches='tight')
        plt.close() 

    return coefs

def regress_layers(seed, control, glm_inputs, layers, params): 

    #glm_input = control - seed 
    # layers = regressors 
    plot_path           = params['plot_path']
    seed_control_title  = params['seed_control_VASO']
    layers_title        = params['layers_VASO']


    # fig = plt.figure(figsize=(10, 17), dpi=400)

    # ax1 = fig.add_subplot(4,1,1)
    # plt.title('Mean Time Courses: {}'.format(seed_control_title))
    # plt.plot(seed, label='L_LGN')
    # plt.plot(control, label='L_MT')
    
    # # plt.plot(glm_inputs['L_LGN - L_MT'], label='L_LGN ~ L_MT')
    # # plt.plot(glm_inputs['L_MT - L_LGN'], label='L_MT ~ L_LGN')
    
    # plt.plot(glm_inputs['R_V1'], label='R_V1')







    # # for k in glm_inputs.keys():
    # #     plt.plot(glm_inputs[k], label=k)
    # plt.legend()

    # ############
    # ax2 = fig.add_subplot(4,1,2)
    # #plt.plot(preproc(seed), label='L_LGN')
    # #plt.plot(preproc(control), label='L_MT')
    # #plt.plot(preproc(glm_inputs['L_LGN - L_MT']), label='L_LGN ~ L_MT')
    # #plt.plot(preproc(glm_inputs['L_LGN - L_MT X_out']), label='L_LGN ~ L_MT X_out')
    
    # plt.title('Residuals')
    # plt.plot(preproc(glm_inputs['L_MT - L_LGN']), label='L_MT ~ L_LGN')
    # plt.plot(preproc(glm_inputs['L_LGN - L_MT']), label='L_LGN ~ L_MT')


    # #plt.plot(glm_inputs['L_MT - L_LGN'], label='L_MT ~ L_LGN')
    # plt.legend()


    n=layers.shape[1]
    if n == 110: 
        n = layers.shape[0]

    colors = pl.cm.jet(np.linspace(0,1,n))
    #colors = ['red','orange','green']


    # ###############
    # ax3 = fig.add_subplot(4,1,3)
    # plt.title("Layers (n=3): {}".format(layers_title))
    # for l in range(n):
    #     plt.plot(layers[:,l], label='V1_l{}'.format(l), color=colors[l])
    # plt.legend()

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
        reg.fit(layers, glm_inputs[k])
        coef = reg.coef_

        sp = 10+k_i 


        # axs.append(fig.add_subplot(4,3,sp))

        # plt.title(xts[k_i])
        
        # plt.xticks([-1,4], ['CSF','WM'])
        # #plt.xlabels(['CSF','WM'])

        # plt.plot(coef)
        k_i += 1 
        coefs[k] = coef
    
    # plt.subplot(326)
    # plt.title("Regression weights (detrended and normalized)")
    # plt.plot(preproc(coefs))

    # fig.savefig(plot_path, bbox_inches='tight')
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
    column_ids_in_roi = column_ids_in_roi.astype(int)
    column_ids_in_roi = column_ids_in_roi[column_ids_in_roi != 0]

    #column_ind        = np.where(column_data == 1)
    #column_epi        = epi_data[column_ind]
    #column_epi_mean   = np.mean(column_epi, 0)
    #column_pcas       = get_pcas(column_epi.T, num_timeseries=4)
    #del column_nii, column_data, column_ind
    #column_ids_in_rois = [ c for c in column_ids_in_roi if c is not 0]

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
    data                = job['data']
    plot_dir            = job['plot_dir']
    plot_verts          = job['plot_verts']


    regressors = data

    os.makedirs(plot_dir, exist_ok=True) 

    plot_path   = plot_dir + '/'+'vert_{}.png'.format(cs[0])

    params = {  'plot_path': plot_path, 
                'seed_control_VASO': seed_control_VASO,
                'layers_VASO': layer4EPI_base,
                'plot_verts': plot_verts }

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

def get_verts_for_label(roi_name, verts, labels):
    '''
    roi_name = 
    labels = hcp_lh_labels
    verts = hcp_lh_verts 
    '''

    def get_roi_id(roi_name, labels): 
        for i in range(len(labels)): 
            if labels[i] == roi_name: 
                print("{} == {}; ID: {}".format(roi_name, labels[i], i))
                return i 


    id = get_roi_id(roi_name, labels)

    id_verts = np.where(verts == id)[0]

    print("ROI: {}\nid: {}\nlen_verts: {}".format(roi_name, id, len(id_verts)))

    return id_verts
        
def get_layer_vert_matrix(vert_ids, layers, normalize=True):
    '''
    vert_ids = L_V1_verts
    layers = lh_vert_layers
    '''
    layers.sort()
    layer_array = [] 

    for l in layers: 
        layer = mgh.load(l) 
        layer_data = layer.get_fdata() 
        layer_data_ids = layer_data[vert_ids]
        layer_data_ids = np.concatenate(layer_data_ids)
        layer_data_ids = np.squeeze(layer_data_ids)

        if normalize == True: 
            layer_data_ids = preproc(layer_data_ids)

        layer_array.append(layer_data_ids)


    layer_array_c = np.stack(layer_array)

    return layer_array_c

def main(EPI_seed, EPI_target, pkl_dir, n_cores=10, plot_verts=False):



    VASO_dir='/data/kleinrl/ds003216/derivatives/sub-01/VASO_func/'
    recon_dir="/data/kleinrl/ds003216/sub-01/ses-01/anat/" + \
                "sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/"

    SUBJECTS_DIR = os.environ['SUBJECTS_DIR']
    '''
    EPIs_to_run=glob(VASO_dir + '*movie*VASO.scaled.nii.gz')
    EPIs_to_run=glob(VASO_dir + '*movie*VASO.gsr.scaled.nii.gz')
    EPIs_to_run=glob(VASO_dir + '*movie*VASO.nii')
    EPIs_to_run.sort()
    
    -----PARAMS ----------------

    EPI_seed    = EPIs_to_run[5]
    EPI_target  = EPIs_to_run[2]
    plot_verts  = False 
    n_cores     = 10
    main_dir    = '/data/kleinrl/plots/'
    seed                    = glob(layer4EPI + '/rois.thalamic.l3/8109.lh.LGN.nii' )[0]
    control                 = glob(layer4EPI + '/rois.hcp/1023.L_MT.nii')[0]
    roi2_file               = layer4EPI + '/rois.hcp/2001.R_V1.nii'
    
    analysis_type           = 'surf' # 'vol'
    seed_pca = 
    '''

    analysis_type           = 'vol'

    layer4EPI_base_seed     = EPI_seed.split('/')[-1].split('.')[0]
    layer4EPI_seed          = recon_dir + '/LAYNII_'+layer4EPI_base_seed

    main_dir                = '/data/kleinrl/plots/'
    seed                    = layer4EPI_seed +  '/rois.scaled.thalamic.l3/8109.lh.LGN.nii' 
    control                 = layer4EPI_seed +  '/rois.scaled.hcp/1023.L_MT.nii'
    roi2_file               = layer4EPI_seed +  '/rois.scaled.hcp/2001.R_V1.nii'


    layer4EPI_base_target   = EPI_target.split('/')[-1].split('.')[0]
    layer4EPI_target        = recon_dir + '/LAYNII_'+layer4EPI_base_target

    target_roi_file         = layer4EPI_target + '/rois.scaled.hcp/1001.L_V1.nii'
    target_column_file      = layer4EPI_target + '/warped_columns_ev_10000_borders.scaled.nii'
    target_layer_file       = layer4EPI_target + '/warped_equi_distance_layers_n10.scaled.nii'



    # main_dir                = '/data/kleinrl/plots/'
    # seed                    = glob(layer4EPI + '/rois.thalamic.l3/8109.lh.LGN.nii' )[0]
    # control                 = glob(layer4EPI + '/rois.hcp/1023.L_MT.nii')[0]
    # roi2_file               = layer4EPI + '/rois.hcp/2001.R_V1.nii'


    # target_column_file =layer4EPI + '/warped_rim_columns10000.resample2muncorr.nii'
    # target_roi_file    =layer4EPI + '/rois.hcp/1001.L_V1.nii'
    # target_layer_file  =layer4EPI + '/warped_equi_volume_layers_n3.resample2muncorr.nii'



    #seed_control_VASO   = layer4EPI_base_seed
    #seed_base           = layer4EPI_base_seed
    
    #main_dir        = '/data/kleinrl/plots/'
    plot_dir_top    = '/regressLayers_{}/'.format(layer4EPI_base_seed)
    reports_dir     = main_dir + plot_dir_top + '/reports'
    os.makedirs(reports_dir, exist_ok=True) 


    # SEED ROI
    #seed                    = glob(layer4EPI + '/rois.thalamic.l3/8109.lh.LGN.nii' )[0]
    seed_masker             = NiftiMasker(mask_img=seed) 
    seed_masker_epi         = seed_masker.fit(EPI_seed)
    seed_masker_epi_report  = seed_masker_epi.generate_report()
    save_path               = reports_dir+'/seed_report.html'
    seed_masker_epi_report.save_as_html(save_path)

    seed_epi        = seed_masker.fit_transform(EPI_seed)
    seed_epi_mean   = np.mean(seed_epi, 1)
    seed_pcas_ts    = get_pcas(seed_epi, num_timeseries=4)
    seed_pcas_ncomp = get_pcas(seed_epi, num_components=4)


    # CONTROL ROI
    #control                 = glob(layer4EPI + '/rois.hcp/1023.L_MT.nii')[0]
    control_masker          = NiftiMasker(mask_img=control) 
    control_masker_epi      = control_masker.fit(EPI_seed)
    control_masker_epi_report = seed_masker_epi.generate_report()
    control_path            = reports_dir+'/control_report.html'
    control_masker_epi_report.save_as_html(save_path) 

    control_epi = control_masker.fit_transform(EPI_seed)
    control_epi_mean = np.mean(control_epi,1)


    control_pcas_ts    = get_pcas(control_epi, num_timeseries=4)
    control_pcas_ncomp = get_pcas(control_epi, num_components=4)
    
    # ROI 2
    #roi2_file               = layer4EPI + '/rois.hcp/2001.R_V1.nii'
    roi2_masker             = NiftiMasker(mask_img=roi2_file)
    roi2_epi                = roi2_masker.fit_transform(EPI_seed)
    roi2_epi_mean           = np.mean(roi2_epi, 1)

    # # Global Signal - brain mask 
    # brain_file               = layer4EPI + '/warped_brainmask.bin.nii'
    # brain_masker             = NiftiMasker(mask_img=brain_file)
    # brain_epi                = brain_masker.fit_transform(EPI_seed)
    # brain_epi_mean           = np.mean(brain_epi, 1)

    
    if analysis_type == 'surf':

        #columns_rh_surf = SUBJECTS_DIR+'/fsaverage.surf/rim_columns10000.rh.white.fsaverage.mgh'  
        #columns_lh_surf = SUBJECTS_DIR+'/fsaverage.surf/rim_columns10000.lh.white.fsaverage.mgh'

        annot_hcp_rh = SUBJECTS_DIR+'/fsaverage.surf/rh.HCPMMP1.annot'
        annot_hcp_lh = SUBJECTS_DIR+'/fsaverage.surf/lh.HCPMMP1.annot'

        #columns_rh_surf_file = mgh.load(columns_rh_surf)
        #columns_lh_surf_file = mgh.load(columns_lh_surf)    

        #columns_rh_surf_data = columns_rh_surf_file.get_fdata()
        #columns_lh_surf_data = columns_lh_surf_file.get_fdata()

        annot_hcp_rh_data = fsio.read_annot(annot_hcp_rh)
        annot_hcp_lh_data = fsio.read_annot(annot_hcp_lh)

        hcp_lh_verts = annot_hcp_lh_data[0]
        hcp_lh_LUT   = annot_hcp_lh_data[1]
        hcp_lh_labels   =  [ a.decode('UTF-8') for a in annot_hcp_lh_data[2]] 

        hcp_rh_verts = annot_hcp_rh_data[0]
        hcp_rh_LUT   = annot_hcp_rh_data[1]
        hcp_rh_labels=  [ a.decode('UTF-8') for a in annot_hcp_rh_data[2]] 

        L_V1_verts = get_verts_for_label('L_V1_ROI', hcp_lh_verts, hcp_lh_labels)
        R_V1_verts = get_verts_for_label('R_V1_ROI', hcp_rh_verts, hcp_rh_labels)

        L_MT_verts = get_verts_for_label('L_MT_ROI', hcp_lh_verts, hcp_lh_labels)


    inputs = []
    for seed_pca in [seed_epi_mean]: 
        for control_pca in [control_epi_mean]: 
            seed_epi_mean = seed_pca 
            control_epi_mean = control_pca 
    #for seed_pca_i in range(seed_pcas_ncomp.shape[1]): 
    #    for control_pca_i in range(control_pcas_ncomp.shape[1]): 
    #        seed_epi_mean = seed_pcas_ncomp[:,seed_pca_i]
    #        control_epi_mean = control_pcas_ncomp[:,control_pca_i]

            glm_inputs = {}

            glm_inputs['L_LGN']                     = preproc(seed_epi_mean)
            glm_inputs['L_MT']                      = preproc(control_epi_mean)  

            Y_out, X_out                            = regress_out_control_signal(preproc(seed_epi_mean), preproc(control_epi_mean))
            glm_inputs['L_LGN - L_MT']              = preproc(Y_out)
            glm_inputs['L_LGN - L_MT X_out']        = X_out

            Y_out, X_out                            = regress_out_control_signal(preproc(control_epi_mean), preproc(seed_epi_mean))
            glm_inputs['L_MT - L_LGN']              = preproc(Y_out)
            glm_inputs['L_MT - L_LGN X_out']        = X_out

            glm_inputs['R_V1']                      = preproc(roi2_epi_mean)

            d = {'seed':preproc(seed_epi_mean), 'control': preproc(control_epi_mean), 'glm_inputs': glm_inputs}

            inputs.append(d)



    completed_jobs_per_input = [] 
    for d_i in range(len(inputs)): 

        completed_jobs_per_EPI = []
        #for e_i in range(len(EPIs_to_run)):
        '''
        d_i, e_i = 0, 2
        '''

        #EPI_target = EPIs_to_run[e_i]

        seed            = d['seed']
        control         = d['control']
        glm_inputs      = d['glm_inputs']

        #layer4EPI_base  = EPI_target.split('/')[-1].split('.')[0]
        #layer4EPI       = recon_dir + '/LAYNII_'+layer4EPI_base 
        target_base     = layer4EPI_base_target

        plot_dir        = main_dir + plot_dir_top + layer4EPI_base_target + "_i-{}".format(d_i)
        os.makedirs(plot_dir, exist_ok=True) 



        if analysis_type == 'surf':
            surf_dir = SUBJECTS_DIR + '/' + layer4EPI_base_target + '/surf'

            rh_vert_layers = glob(surf_dir + '/*movie*rh*white.surf-fwhm-2.fsaverage.mgh')
            lh_vert_layers = glob(surf_dir + '/*movie*lh*white.surf-fwhm-2.fsaverage.mgh')

            rh_vert_layers.sort()
            lh_vert_layers.sort()

            if rh_vert_layers == [] or lh_vert_layers == []:
                print("missing verts for {}".format(layer4EPI_base_target))
                continue

            L_V1_layers_data = get_layer_vert_matrix(L_V1_verts, lh_vert_layers, normalize=True)
            R_V1_layers_data = get_layer_vert_matrix(R_V1_verts, rh_vert_layers, normalize=True)
            L_MT_layers_data = get_layer_vert_matrix(L_MT_verts, lh_vert_layers, normalize=True)

            column_ids  = range(L_V1_layers_data.shape[1])
            layer_ids   = range(L_V1_layers_data.shape[0])


            ind_jobs = []         
            for c in column_ids: 
                inds, cs, ls, data = [], [], [], []
                data = L_V1_layers_data[:,c,:].T
                cs.append(c)

                # TODO add d seed, control, glm_input here 
                job = {'inds': inds, 'cs': cs, 'ls': ls, 'data':data,
                        'seed': seed, 'control': control, 'glm_inputs': glm_inputs, 
                        'layer4EPI_base': layer4EPI_base_target, 
                        'seed_control_VASO': layer4EPI_base_seed,
                        'plot_dir': plot_dir, 
                        'plot_verts': plot_verts  }
                
                ind_jobs.append(job)


        elif analysis_type == 'vol':
            # extract layer/column ts 
            print("analysis_type == 'vol' ")


            column_nii        = nib.load(target_column_file)
            column_data       = column_nii.get_fdata()

            layer_nii        = nib.load(target_layer_file)
            layer_data       = layer_nii.get_fdata()



            column_ids  = get_columns_by_roi(column_file=target_column_file, roi_file=target_roi_file)


            #layer_ids   = [3, 2, 1]
            layer_ids   = [3, 2, 1]




            if np.any(column_nii.affine != layer_nii.affine):
                print("affines dont match")


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
                    print('layer column mismatch')
                    continue 
            
                # TODO add d seed, control, glm_input here 
                job = {'inds': inds, 'cs': cs, 'ls': ls, 
                        'seed': seed, 'control': control, 'glm_inputs': glm_inputs, 
                        'layer4EPI_base': layer4EPI_base_target, 
                        'seed_control_VASO': layer4EPI_base_seed }
                

                ind_jobs.append(job)


         
                

        '''
        completed_jobs = parallelize(ind_jobs[0:10], regress_across_columns, n_cores=10)
        '''
        try: 
            completed_jobs = parallelize(ind_jobs, regress_across_columns, n_cores=n_cores)
            #pkl_dir        = main_dir #+ plot_dir_top #+ layer4EPI_base + "_i-{}".format(d_i)
            os.makedirs(pkl_dir, exist_ok=True) 

            with  open('{}/completed_jobs.seed_{}.target_{}.i_{}.pkl'.format(pkl_dir, layer4EPI_base_seed, layer4EPI_base_target, d_i), "wb" )  as f: 
                pickle.dump(completed_jobs,f)
        
        except Exception as e: 
            print('ERROR: ', e)






if __name__ == "__main__":

    '''
    regressLayers.surf.py --EPI $EPI --n_cores 40 
    
    '''

    parser = argparse.ArgumentParser(description='regressLayers')
    parser.add_argument('--EPI_seed', type=str)
    parser.add_argument('--EPI_target', type=str)
    parser.add_argument('--n_cores', type=int, default=10)
    parser.add_argument('--pkl_dir', type=str)

    args = parser.parse_args()

    EPI_seed    = args.EPI_seed
    EPI_target  = args.EPI_target
    n_cores     = args.n_cores 
    pkl_dir     = args.pkl_dir 


    start = time.time() 
    print('START time: {}'.format(start) )
    print("   ")
    print('RUNNING: {}'.format(EPI_target))
    print('using n_cores: {}'.format(n_cores))


    main(EPI_seed, EPI_target, pkl_dir, n_cores=n_cores, plot_verts=False)



    end = time.time()
    print(end)
    print("END time: {}".format(end - start))









    #     completed_jobs_per_EPI.append(completed_jobs)

    # completed_jobs_per_input.append(completed_jobs_per_EPI)



    # xts =  ['Seed: L_Thalamus Control: L_MT\nTarget: L_V1 (n={})'.format(len(completed_jobs)), 
    #             'Seed: L_MT Control: L_Thalamus\nTarget: L_V1 (n={})'.format(len(completed_jobs)),
    #             'Seed: R_V1 Control: None\nTarget: L_V1 (n={})'.format(len(completed_jobs))]

    # fig, axs = plt.subplots(ncols=3, sharex=True, figsize=(12,4))
    # axs_i = 0 
    # for k in completed_jobs[0]['coefs'].keys():
        
    #     coefs = []
    #     for cj in completed_jobs:
    #             coefs.append(cj['coefs'][k])

    #     m   = np.mean(coefs,0) 
    #     se  = sp.sem(coefs) 
    #     x = range(len(m))

    #     axs[axs_i].errorbar(x, m, yerr=se, fmt='-o') #[upper, lower]
    #     axs[axs_i].set_title(xts[axs_i])

    #     axs[axs_i].set_xticks([0, coefs.shape[1]])
    #     axs[axs_i].set_xticklabels(['CSF','WM'])

    #     axs_i += 1 

    # plt.savefig('{}/{}.i_{}.png'.format(plot_dir,layer4EPI_base,d_i))
    # plt.close()
















            # plot_dir    ='/data/kleinrl/plots/regressLayers_columns_'+layer4EPI_base
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
