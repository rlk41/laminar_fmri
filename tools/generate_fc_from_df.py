import os
import numpy as np
import nibabel as nib
from glob import glob
import time
import pandas as pd
import argparse
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from sklearn.metrics.pairwise import cosine_similarity, cosine_distances, paired_cosine_distances

def gen_fc_quick(path, rois=None, dist='cosine'):
    '''
    path='/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract_dataframe'
    rois = ['L_thalamus','L_V1','L_V2','L_V3','L_V3A','L_V3B','L_V3CD','L_V4','L_V4t','L_V6']
    :param path:
    :param roi_name:
    :return:
    '''
    labs = pd.read_pickle(glob(os.path.join(path,'*.pkl'))[0])
    a   = np.load(glob(os.path.join(path,'*.npy'))[0])

    if dist == 'pearson':
        c = np.corrcoef(a)
    elif dist == 'cosine':
        c = 1 - cosine_similarity(a)


    len_rois = len(rois)

    fig = plt.figure(constrained_layout=True, figsize=[len_rois*5,len_rois*5])
    gs = gridspec.GridSpec(len_rois, len_rois, figure=fig)

    ax = []

    for i1 in range(len_rois):
        for i2 in range(len_rois):

            r1 = rois[i1]
            r2 = rois[i2]

            ax.append(plt.subplot(gs[i1, i2]))

            v1 = labs[labs['roi'] == r1].sort_values('plot')['i'].values
            v2 = labs[labs['roi'] == r2].sort_values('plot')['i'].values

            v1_labs = labs[labs['roi'] == r1].sort_values('plot')['layer'].to_list()
            v2_labs = labs[labs['roi'] == r2].sort_values('plot')['layer'].to_list()

            len_v1 = len(v1)
            len_v2 = len(v2)

            x = []
            y = []
            for v in v1:
                for vv in v2:
                    x.append(v)
                    y.append(vv)

            o = c[x,y]
            o = o.reshape(len_v1,len_v2)

            im = ax[-1].imshow(o) #, vmin=0,vmax=1) #0.25
            #plt.colorbar(im, ax=ax[-1])

            ax[-1].set(xlabel=r2, ylabel=r1) #, font)

            ax[-1].set_yticks(np.arange(len_v1))
            ax[-1].set_yticklabels(v1_labs)

            ax[-1].set_xticks(np.arange(len_v2))
            ax[-1].set_xticklabels(v2_labs, rotation=90)

    for aa in ax:
        aa.label_outer()
    #plt.show()
    plt.savefig(os.path.join(path,'-'.join(rois)))
    plt.close()



def generate_fc_from_df(path, rois=None):
    '''
    path='/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract_n3_dataframe'
    rois = ['L_thalamus','L_V1','L_V2','L_V3','L_V3A','L_V3B','L_V3CD','L_V4','L_V4t','L_V6']
    :param path:
    :param roi_name:
    :return:
    '''
    labs = pd.read_pickle(glob(os.path.join(path,'*.pkl'))[0])
    a   = np.load(glob(os.path.join(path,'*.npy'))[0])

    len_rois = len(rois)

    fig = plt.figure(constrained_layout=True, figsize=[len_rois*5,len_rois*5])
    gs = gridspec.GridSpec(len_rois, len_rois, figure=fig)

    ax = []

    for i1 in range(len_rois):
        for i2 in range(len_rois):
        #for i2 in range(i1, len_rois):

            ax.append(plt.subplot(gs[i1, i2]))

            r1 = rois[i1]
            r1s = labs[labs['roi'] == r1]
            r1s = r1s.sort_values('plot')

            r2 = rois[i2]
            r2s = labs[labs['roi'] == r2]
            r2s = r2s.sort_values('plot')

            r1_list = r1s['i'].values
            r2_list = r2s['i'].values


            len_r1s = len(r1_list)
            len_r2s = len(r2_list)

            o = np.zeros(shape=(len_r1s,len_r2s))

            for p1 in range(len_r1s):
                #for p2 in range(len_r2s):
                for p2 in range(p1,len_r2s):

                    a1_idx = r1_list[p1]
                    a2_idx = r2_list[p2]

                    o[p1,p2] = np.corrcoef(a[a1_idx,:],a[a2_idx,:])[0,1]

            im = ax[-1].imshow(o) #, vmin=0,vmax=1) #0.25
            #plt.colorbar(im, ax=ax[-1])

            ax[-1].set(xlabel=r2, ylabel=r1) #, font)
            ax[-1].set_xticks(np.arange(len_r2s))
            ax[-1].set_yticks(np.arange(len_r1s))

            ax[-1].set_yticklabels(r1s['layer'].to_list())
            ax[-1].set_xticklabels(r2s['layer'].to_list(), rotation=90)

    for aa in ax:
        aa.label_outer()
    #plt.show()
    plt.savefig(os.path.join(path,'-'.join(rois)))
    plt.close()

if __name__ == "__main__":


    parser = argparse.ArgumentParser(description='generate layer profile')
    parser.add_argument('--path', type=str)
    parser.add_argument('--rois', nargs='+')

    args = parser.parse_args()
    #path='/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract'
    # rois = ['L_V1', ]

    path = args.path
    rois = args.rois

    print("\n Creating Plot  \n"
          "   ROI:{}  \n"
          "   path:{} \n".format(rois, path))
    #generate_func_network(path, rois)
    '''
    path='/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract'
    rois = ['L_V1', 'L_V2', 'L_V3', 'L_V4']
    '''

    generate_fc_from_df(path, rois)
    #gen_fc_quick(path, rois)


    '''
    python ./generate_fc_from_df.py \
    --path '/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract_dataframe' \
    --rois L_thalamic L_TGd L_TGv L_TE2a L_TE2p L_TE1a L_TE1m L_STSvp L_STSdp L_STSva L_STSda L_STGa L_TF

    python ./generate_fc_from_df.py \
    --path '/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract_dataframe' \
    --rois L_thalamus L_V1 L_V2 L_V3 L_V3A L_V3B L_V3CD L_V4 L_V4t L_V6 

    '''