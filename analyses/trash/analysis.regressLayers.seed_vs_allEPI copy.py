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

def plot_regress_layers(seed, control, glm_input, layers, params): 

    #glm_input = control - seed 

    plot_path           = params['plot_path']
    seed_control_title  = params['seed_control_VASO']
    layers_title        = params['layers_VASO']


    plt.figure(figsize=(10, 10), dpi=400)

    plt.subplot(311)
    plt.title('Seed and Control: {}'.format(seed_control_title))
    plt.plot(seed, label='seed (LGN)')
    plt.plot(control, label='control (MT)')
    plt.plot(glm_input, label='control - seed (glm_input)')
    plt.legend()

    n=len(layers)
    colors = pl.cm.jet(np.linspace(0,1,n))
    colors = ['red','orange','green']


    plt.subplot(312)
    plt.title("Layers (n=3): {}".format(layers_title))
    for l in range(len(layers)):
        plt.plot(layers[l], label='V1_l{}'.format(l), color=colors[l])
    plt.legend()



    reg = linear_model.LinearRegression()
    reg.fit(layers.T, glm_input)
    coefs = reg.coef_

    plt.subplot(325)
    plt.title('Regression weights (L1_wm->L3_csf)')
    plt.plot(coefs)
    
    plt.subplot(326)
    plt.title("Regression weights (detrended and normalized)")
    plt.plot(preproc(coefs))

    plt.savefig(plot_path)
    plt.close() 

    return coefs

def plot_group_regress_layers(seed, control, glm_input, layers, plot_path): 

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
seed_pcas       = get_pcas(seed_epi.T, num_timeseries=4)
del seed_nii, seed_data, seed_ind

# CONTROL ROI
control         = glob(layer4EPI + '/rois.hcp/1023.L_MT.nii')[0]
control_nii     = nib.load(control)
control_data    = control_nii.get_fdata()
control_ind     = np.where(control_data == 1)
control_epi     = epi_data[control_ind]
control_epi_mean= np.mean(control_epi, 0) 
pcas_control    = get_pcas(control_epi.T, num_timeseries=4)
del control_nii, control_data, control_ind


# normalize each voxel .. 
seed_epi_mean       = preproc(seed_epi_mean)
control_epi_mean    = preproc(control_epi_mean)

glm_input           = seed_epi_mean - control_epi_mean 
glm_input           = preproc(glm_input)

for epi in EPIs: 

    layer4EPI_base = epi.split('/')[-1].split('.')[0]
    layer4EPI      = recon_dir + '/LAYNII_'+layer4EPI_base

    target   = glob(layer4EPI + '/rois.hcp.l3/1001.L_V1.*.nii')  
    target.sort()

    targets = [] 
    for t in target:
        target_nii      = nib.load(t)
        target_data     = target_nii.get_fdata()
        target_ind      = np.where(target_data == 1)
        target_epi      = epi_data[target_ind]
        target_epi_mean = np.mean(target_epi, 0)
        target_epi_pcas = get_pcas(target_epi.T, num_timeseries=4)

        targets.append(target_epi_mean)

    

    seed        = preproc(seed_epi_mean)
    control     = preproc(control_epi_mean)

    layers      = [preproc(l) for l in targets ]
    layers      = np.array(layers) 

    #out_prefix = target[0].split('/')[-1].strip('.nii')
    plot_dir    ='plots_regressLayers_grp'
    os.makedirs(plot_dir, exist_ok=True) 
    plot_path   = plot_dir + '/' + layer4EPI_base + '.png'
    
    params = {  'plot_path': plot_path, 
                'seed_control_VASO': seed_control_VASO,
                'layers_VASO': layer4EPI_base }

    coef        = plot_regress_layers(seed, control, glm_input, layers, params)


    layers_list.append(layers)
    coef_list.append(coef) 


#plot_group_regress_layers(seed, control, glm_input, layers_list, plot_path)

coef_means = np.mean(coef_list,0)
coef_std   = np.std(coef_list,0)

plt.figure()
plt.subplot(221)
for coef in coef_list: 
    plt.plot(coef)
plt.subplot(222)

plt.savefig('grp.png')



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
