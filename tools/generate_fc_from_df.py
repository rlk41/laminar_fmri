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
#from correlation_stats import corrcoef
from scipy.special import betainc


def corrcoef(matrix):
    r = np.corrcoef(matrix)
    rf = r[np.triu_indices(r.shape[0], 1)]
    df = matrix.shape[1] - 2 # n-2 = df
    ts = rf * rf * (df / (1 - rf * rf)) # r^2 * df/(1 - r^2)
    pf = betainc(0.5 * df, 0.5, df / (df + ts))
    p = np.zeros(shape=r.shape)
    p[np.triu_indices(p.shape[0], 1)] = pf
    p[np.tril_indices(p.shape[0], -1)] = p.T[np.tril_indices(p.shape[0], -1)]
    p[np.diag_indices(p.shape[0])] = np.ones(p.shape[0])
    return r, p

def highlight_cell(x,y, ax=None, **kwargs):
    # https://stackoverflow.com/questions/56654952/how-to-mark-cells-in-matplotlib-pyplot-imshow-drawing-cell-borders
    # highlight_cell(2,1, color="limegreen", linewidth=3)
    #rect = plt.Rectangle((x-.5, y-.5), 1,1, fill=False, **kwargs)
    rect = plt.Circle((x,y), .25, fill=False, **kwargs)
    ax = ax or plt.gca()
    ax.add_patch(rect)
    return rect

def gen_fc_quick(path, rois=None, dist='pearson', plot=True):
    '''
    path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/dataframe.hcpl3_thalamic.preprocd'
    rois = ['L_Thalamus','L_V1']
    rois = ['L_Thalamus','L_V1'] ,'L_V2','L_V3','L_V3A','L_V3B','L_V3CD','L_V4','L_V4t','L_V6']

    rois=['L_Thalamus', 'L_V1', 'L_V2', 'L_V3A', 'L_A1', 'L_STSda', 'L_STSdp']
    path='/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/bandettini_data/ts_numpy_extract_n10_dataframe'
    :param path:
    :param roi_name:
    :return:
    '''
    save_path = path.replace('dataframe','plots')

    if not os.path.exists(save_path):
        os.makedirs(save_path)


    labs = pd.read_pickle(glob(os.path.join(path,'*.pkl'))[0])
    a   = np.load(glob(os.path.join(path,'*.npy'))[0])


    # fix
    labs.loc[labs['roi'] == 'L_thalamus', 'roi'] = 'L_Thalamus'
    labs.loc[labs['roi'] == 'R_thalamus', 'roi'] = 'R_Thalamus'

    if dist == 'pearson':
        #c = np.corrcoef(a)
        c,p = corrcoef(a)
        print("min {} \n max {}".format(np.min(p), np.max(p)))
    elif dist == 'cosine':
        c = 1 - cosine_similarity(a)


    # get number of ROIs gependent on whether you specify a list or use all in matrix
    # if non specified us all
    # may want to order these in way that makes sense
    if rois == None:
        rois = labs['roi'].values

    len_rois = len(rois)

    # fig = plt.figure(constrained_layout=True, figsize=[len_rois*5,len_rois*5])
    # gs = gridspec.GridSpec(len_rois, len_rois, figure=fig)
    #
    # ax = []
    o_list = []
    o_pval_list = []

    r1_list = []
    r2_list = []
    len_v1_list = []
    len_v2_list = []
    v1_labs_list = []
    v2_labs_list = []

    for i1 in range(len_rois):
        for i2 in range(len_rois):

            r1 = rois[i1]
            r2 = rois[i2]

            #ax.append(plt.subplot(gs[i1, i2]))

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

            o_pval = p[x,y]
            o_pval = o_pval.reshape(len_v1,len_v2)

            o_list.append(o)
            o_pval_list.append(o_pval)

            r1_list.append(r1)
            r2_list.append(r2)
            len_v1_list.append(len_v1)
            len_v2_list.append(len_v2)
            v1_labs_list.append(v1_labs)
            v2_labs_list.append(v2_labs)
    #
    #         im = ax[-1].imshow(o) #, vmin=0,vmax=1) #0.25
    #         #plt.colorbar(im, ax=ax[-1])
    #
    #         ax[-1].set(xlabel=r2, ylabel=r1) #, font)
    #
    #         ax[-1].set_yticks(np.arange(len_v1))
    #         ax[-1].set_yticklabels(v1_labs)
    #
    #         ax[-1].set_xticks(np.arange(len_v2))
    #         ax[-1].set_xticklabels(v2_labs, rotation=90)
    #
    # for aa in ax:
    #     aa.label_outer()
    # #plt.show()
    #

    if plot:
        fig = plt.figure(constrained_layout=True, figsize=[len_rois*5,len_rois*5])
        gs = gridspec.GridSpec(len_rois, len_rois, figure=fig)
        ax = []
        i_list = 0

        for i1 in range(len_rois):
            for i2 in range(len_rois):

                ax.append(plt.subplot(gs[i1, i2]))

                o       = o_list[i_list]
                o_pval  = o_pval_list[i_list]
                r1      = r1_list[i_list]
                r2      = r2_list[i_list]
                len_v1  = len_v1_list[i_list]
                len_v2  = len_v2_list[i_list]
                v1_labs = v1_labs_list[i_list]
                v2_labs = v2_labs_list[i_list]

                i_list += 1

                im = ax[-1].imshow(o)#, vmin=-1,vmax=1) #0.25
                #plt.colorbar(im, ax=ax[-1])

                for p_x in range(o_pval.shape[0]):
                    for p_y in range(o_pval.shape[1]):
                        pval = o_pval[p_x,p_y]
                        if pval < 0.00000000000000000000000000000001:
                            highlight_cell(p_y,p_x, color='white',ax=ax[-1], linewidth=3)



                ax[-1].set(xlabel=r2, ylabel=r1) #, font)

                ax[-1].set_yticks(np.arange(len_v1))
                ax[-1].set_yticklabels(v1_labs)

                ax[-1].set_xticks(np.arange(len_v2))
                ax[-1].set_xticklabels(v2_labs, rotation=90)

        for aa in ax:
            aa.label_outer()
        #plt.show()

        plt.savefig(os.path.join(save_path,'-'.join(rois)))
        plt.close()


    # for i_list in range(len(o_list)):
    #     o       = o_list[i_list]
    #     r1      = r1_list[i_list]
    #     r2      = r2_list[i_list]
    #     len_v1  = len_v1_list[i_list]
    #     len_v2  = len_v2_list[i_list]
    #     v1_labs = v1_labs_list[i_list]
    #     v2_labs = v2_labs_list[i_list]
    #
    #     np.savetxt(os.path.join(save_path,'-'.join([r1, r2])+'.txt'),o)



def generate_fc_from_df(path, rois=None):
    '''
    path='/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract_n3_dataframe'
    rois = ['L_thalamus','L_V1','L_V2','L_V3','L_V3A','L_V3B','L_V3CD','L_V4','L_V4t','L_V6']
    :param path:
    :param roi_name:
    :return:
    '''
    save_path = path.replace('dataframe','plots')

    if not os.path.exists(save_path):
        os.makedirs(save_path)

    labs = pd.read_pickle(glob(os.path.join(path,'*.pkl'))[0])
    a   = np.load(glob(os.path.join(path,'*.npy'))[0])

    len_rois = len(rois)

    fig = plt.figure(constrained_layout=True, figsize=[len_rois*5,len_rois*5])
    gs = gridspec.GridSpec(len_rois, len_rois, figure=fig)

    ax = []
    ims = []

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
                for p2 in range(len_r2s):
                #for p2 in range(p1,len_r2s):

                    a1_idx = r1_list[p1]
                    a2_idx = r2_list[p2]

                    o[p1,p2] = np.corrcoef(a[a1_idx,:],a[a2_idx,:])[0,1]
                    #o[p1,p2] = 1-cosine_similarity([a[a1_idx,:],a[a2_idx,:]])[0,1]

            im = ax[-1].imshow(o) #, vmin=0,vmax=1) #0.25
            #im = ax[-1].imshow(o, vmin=0,vmax=1) #0.25
            #plt.colorbar(im, ax=ax[-1])
            #ims.append(im)

            #ax[-1].set(xlabel=r2, ylabel=r1, size=18)
            ax[-1].set_xlabel(r2, fontsize=25)
            ax[-1].set_ylabel(r1, fontsize=25)

            ax[-1].set_xticks(np.arange(len_r2s))
            ax[-1].set_yticks(np.arange(len_r1s))

            ax[-1].set_yticklabels(r1s['layer'].to_list())
            ax[-1].set_xticklabels(r2s['layer'].to_list(), rotation=90)

    for aa in ax:
        aa.label_outer()
    #plt.show()

    #save_path = path.replace('dataframe','plots')

    plt.savefig(os.path.join(save_path,'-'.join(rois)))
    np.savetxt(os.path.join(save_path,'-'.join(rois)+'.txt'),o)

    #for im in ims:
    #    plt.colorbar(im, ax=ax[-1])
    #plt.savefig(os.path.join(path,'-'.join(rois)+'_cb'))

    plt.close()

if __name__ == "__main__":


    parser = argparse.ArgumentParser(description='generate layer profile')
    parser.add_argument('--path', type=str)
    parser.add_argument('--rois', nargs='+')
    parser.add_argument('--plot', type=bool, default=True)
    parser.add_argument('--quick', action='store_true')
    args = parser.parse_args()
    #path='/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract'
    # rois = ['L_V1', ]

    path = args.path
    rois = args.rois
    quick = args.quick
    plot = args.plot

    print("\n Creating Plot  \n"
          "   ROI:{}  \n"
          "   path:{} \n".format(rois, path))
    #generate_func_network(path, rois)
    '''
    path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/dataframe.hcpl3_thalamic.preprocd' \
    rois = ['L_V1', 'L_V2'] , 'L_V3', 'L_V4']
    '''
    if not quick:
        print('not quick')
        generate_fc_from_df(path, rois)
    else:
        print('quick')
        if plot:
            print('plotting')
        gen_fc_quick(path, rois, plot=plot)

    '''
    path='/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/bandettini_data/ts_numpy_extract_n10_dataframe'
    rois=['L_thalamus', 'L_V1', 'L_V2', 'L_V3', 'L_V3A', 'L_A1'] 
    '''

    '''
    python ./generate_fc_from_df.py \
    --path '/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/dataframe.hcpl3_thalamic.preprocd' \
    --rois L_thalamic L_TGd L_TGv L_TE2a L_TE2p L_TE1a L_TE1m L_STSvp L_STSdp L_STSva L_STSda L_STGa L_TF

    python ./generate_fc_from_df.py \
    --path '/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract_dataframe' \
    --rois L_thalamus L_V1 L_V2 L_V3 L_V3A L_V3B L_V3CD L_V4 L_V4t L_V6 

    '''