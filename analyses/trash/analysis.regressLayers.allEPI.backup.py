import nibabel as nib
import argparse
import numpy as np
from matplotlib import pyplot as plt
import time 
from scipy import signal 
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




def get_pcas(X, num_timeseries=4):
    # time on rows, X
    # voxels on columns, Y

    scaler = StandardScaler()
    X_std = scaler.fit_transform(X) 

    ###########################
    # #NUMBER COMPONENTS 
    # pca = PCA()
    # X_pca = pca.fit(X_std)
    # X_pca.explained_variance_.shape 

    # num_components = 4
    # pca = PCA(num_components)  
    # X_pca = pca.fit_transform(X_std)

    ##########################
    # VARIANCE EXPLAINED 
    pca             = PCA(n_components = 0.99)
    X_pca           = pca.fit_transform(X_std) 
    n_pcs           = pca.n_components_ 

    most_important          = [ np.abs(pca.components_[i]).argmax() for i in range(n_pcs)]
    initial_feature_names   = [ x for x in range(0,X_std.shape[1])]
    most_important_names    = [ initial_feature_names[most_important[i]] for i in range(n_pcs)]

    #num_timeseries = 4
    most_important_timeseries = [ X_std[:,x] for x in most_important_names[0:num_timeseries] ]

    return most_important_timeseries

def preproc(ts): 
    #target_ts_mean          = np.mean(target_ts_list,0)
    target_ts_mean_dt       = signal.detrend(ts, type='linear')
    target_ts_mean_dt_norm  = (target_ts_mean_dt - 
                        np.mean(target_ts_mean_dt))/ np.std(target_ts_mean_dt)

    return target_ts_mean_dt_norm 


def plot_and_regress_layers(seed, control, layers ):
    #glm_input = epi_seed_mean - epi_control_mean
    #glm_input = pcas_seed[0] - pcas_control[0]


    seed = preproc(seed)
    control = preproc(control)
    
    layers = [preproc(l) for l in layers ]
    
    
    
    glm_input = seed - control 
    
    plt.figure()
    plt.plot(seed)
    plt.plot(control)
    plt.plot(glm_input)
    
    
    reg = linear_model.LinearRegression()

    reg.fit(layers.T, glm_input)



    coefs = reg.coef_
    
    plt.figure()
    plt.plot(coefs)


def plot_regress_layers(seed, control, glm_input, layers, plot_path): 

    #glm_input = control - seed 

    plt.subplot(411)
    #plt.figure()
    plt.plot(seed, label='seed (LGN)')
    plt.plot(control, label='control (MT)')
    plt.plot(glm_input, label='control - seed (glm_input)')
    plt.legend()

    n=len(layers)
    colors = pl.cm.jet(np.linspace(0,1,n))
    colors = ['red','orange','green']


    plt.subplot(421)
    #plt.figure()
    for l in range(len(layers)):
        plt.plot(layers[l], label='V1_l{}'.format(l), color=colors[l])
    plt.legend()



    reg = linear_model.LinearRegression()
    reg.fit(layers.T, glm_input)
    coefs = reg.coef_

    plt.subplot(412)
    #plt.figure()
    plt.plot(coefs)
    
    plt.subplot(422)
    #plt.figure()
    plt.plot(preproc(coefs))

    plt.savefig(plot_path)
    plt.close() 

    return coefs




outdir='/home/kleinrl/regress_layers'

if not os.path.exists(outdir):
    os.makedirs(outdir)

VASO_dir='/data/kleinrl/ds003216/derivatives/sub-01/VASO_func/'
recon_dir="/data/kleinrl/ds003216/sub-01/ses-01/anat/" + \
            "sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/"

EPIs=glob(VASO_dir + '*VASO.nii')

coefs = [] 



for epi in EPIs: 
    # epi = EPIs[4]

    #epi='/data/kleinrl/ds003216/derivatives/sub-01/VASO_func/sub-01_ses-06_task-movie_run-05_VASO.nii'
    layer4EPI_base = epi.split('/')[-1].split('.')[0]
    layer4EPI      = recon_dir + '/LAYNII_'+layer4EPI_base


    seed     = glob(layer4EPI + '/rois.thalamic.l3/8109.lh.LGN.nii' )[0]
    control  = glob(layer4EPI + '/rois.hcp/1023.L_MT.nii')[0]
    #target  = layer4EPI + 'rois.hcp/1001.L_V1.nii'  
    target   = glob(layer4EPI + '/rois.hcp.l3/1001.L_V1.*.nii')  


    #out_prefix = '.'.join(target[0].split('/')[-1].strip('.nii').split('.')[0:-1])
    out_prefix = target[0].split('/')[-1].strip('.nii')

    #start = time.perf_counter()


    # INDS ########################
    # SEED 
    nii_seed = nib.load(seed)
    data_seed = nii_seed.get_fdata()
    ind_seed = np.where(data_seed == 1)

    # TARGET 
    ind_targets = [] 
    for t in target:
        nii_target = nib.load(t)
        data_target = nii_target.get_fdata()
        ind_target = np.where(data_target == 1)
        ind_targets.append(ind_target)


    # CONTROL 
    nii_control = nib.load(control)
    data_control = nii_control.get_fdata()
    ind_control = np.where(data_control == 1)


    ###############
    # DATA 
    nii_epi = nib.load(epi)
    data_epi = nii_epi.get_fdata()


    # get TSs 
    epi_seed = data_epi[ind_seed]
    epi_seed_mean = np.mean(epi_seed, 0)
    pcas_seed = get_pcas(epi_seed.T, num_timeseries=4)


    epi_control = data_epi[ind_control]
    epi_control_mean = np.mean(epi_control, 0) 
    pcas_control = get_pcas(epi_control.T, num_timeseries=4)


    epi_targets = []
    epi_targets_mean = [] 
    pcas_targets = [] 

    for t in ind_targets: 
        epi_targets.append(data_epi[t])
        epi_targets_mean.append(np.mean(data_epi[t], 0))
        pcas_targets.append(get_pcas(data_epi[t].T, num_timeseries=4))

    epi_targets_mean = np.array(epi_targets_mean)

    epi_target_mean = np.mean(epi_targets_mean, 0)
    epi_targets_mean = epi_targets_mean - epi_target_mean 



    glm_input = epi_seed_mean - epi_control_mean
    glm_input = pcas_seed[0] - pcas_control[0]




    seed = preproc(epi_seed_mean)
    control = preproc(epi_control_mean)

    layers = [preproc(l) for l in epi_targets_mean ]
    layers = np.array(layers) 
    layers.shape


    plot_path = 'plots/'+layer4EPI_base +'.png'
    coef = plot_regress_layers(seed, control, glm_input, layers, plot_path)

    coefs.append(coef) 
