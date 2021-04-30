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
from scipy import spatial


def generate_func_conn(path, rois):
    '''
    path='/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract'
    roi_name='L_V1'
    :param path:
    :param roi_name:
    :return:
    '''
    # rois = ['L_V1', 'L_V4','thalamic.Left']
    # rois = ['L_TGd','L_TGv', 'L_TE2a'] #,'L_TE2p','L_TE1a','L_TE1m','L_STSvp','L_STSdp','L_STSva','L_STSda','L_STGa','L_TF']
    len_rois = len(rois)

    fig = plt.figure(constrained_layout=True, figsize=[len_rois*5,len_rois*5])
    gs = gridspec.GridSpec(len_rois, len_rois, figure=fig)

    ax = []
    for i_r1 in range(len_rois):
        for i_r2 in range(len_rois): #i_r1,

            ax.append(plt.subplot(gs[i_r1, i_r2]))

            roi_name1 = rois[i_r1]
            roi_files1 = glob('{}/*.{}*.npy'.format(path, roi_name1))
            print('found {} files'.format(len(roi_files1)))

            l1 = []
            a1 = np.zeros(shape=(len(roi_files1),110))
            l_thalamic = 0
            for file_path in roi_files1:
                file    = np.load(file_path)
                mean_ts = np.mean(file,0)
                desc = file_path.split('/')[-1]
                id,roi,layer,_ = desc.split('.')
                try:
                    l = int(layer.strip('L'))
                    l1.append('L{0:02}'.format(l))
                except:

                    l1.append(layer)

                a1[l-1,:] = mean_ts

            roi_name2 = rois[i_r2]
            roi_files2 = glob('{}/*.{}*.npy'.format(path, roi_name2))
            print('found {} files'.format(len(roi_files2)))

            a2 = np.zeros(shape=(len(roi_files2),110))
            for file_path in roi_files2:
                file    = np.load(file_path)
                mean_ts = np.mean(file,0)
                desc = file_path.split('/')[-1]
                id,roi,layer,_ = desc.split('.')
                l = int(layer.strip('L'))
                a2[l-1,:] = mean_ts

            o = np.zeros(shape=(a1.shape[0],a2.shape[0]))
            for i_d1 in range(a1.shape[0]):
                for i_d2 in range(a2.shape[0]):
                    o[i_d1,i_d2] = np.corrcoef(a1[i_d1,:], a2[i_d2,:])[0,1]

            #o = np.triu(o,1).T + o
            #im = ax[-1].imshow(o)
            im = ax[-1].imshow(o, vmin=0.25,vmax=1)
            plt.colorbar(im, ax=ax[-1])

            ax[-1].set(xlabel=roi_name2, ylabel=roi_name1) #, font)
            ax[-1].set_yticks(np.arange(len(roi_files2)))
            ax[-1].set_xticks(np.arange(len(roi_files1)))

    for a in ax:
        a.label_outer()
    plt.show()

    #plt.savefig("{}/{}_grid.png".format(path,'-'.join(rois)))
    #plt.close()


def generate_func_conn_single_mat(path, rois):
    '''
    path='/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract'
    roi_name='L_V1'
    :param path:
    :param roi_name:
    :return:
    '''
    # rois = ['L_V1', 'L_V2', 'L_V3']
    # rois = ['L_TGd','L_TGv', 'L_TE2a','L_TE2p','L_TE1a','L_TE1m','L_STSvp','L_STSdp','L_STSva','L_STSda','L_STGa','L_TF']


    len_rois = len(rois)

    mean_name = []
    mean_array = []
    mean_corr = []
    for r in range(len_rois):

        roi_name = rois[r]

        roi_files = glob('{}/*.{}.*.npy'.format(path, roi_name))
        print('found {} files'.format(len(roi_files)))

        layer_dict = dict()
        for file_path in roi_files:
            file    = np.load(file_path)
            mean_ts = np.mean(file,0)

            desc = file_path.split('/')[-1]
            id,roi,layer,_ = desc.split('.')
            l = int(layer.strip('L'))
            layer = 'L{0:02d}'.format(l)

            mean_name.append("{}_{}".format(roi,layer))
            mean_array.append(mean_ts)


    array = np.stack(mean_array)

    print('len mean_array: {}'.format(len(mean_array)))
    print('shape array: {}'.format(array.shape))

    o = np.corrcoef(array)


    plt.figure()
    plt.imshow(o)
    plt.show()

    #
    #
    # len_rois = len(rois)
    # d = []
    #
    # mean_name = []
    # mean_array = []
    # mean_corr = []
    # for r in range(len_rois):
    #
    #     roi_name = rois[r]
    #     roi_files = glob('{}/*.{}.*.npy'.format(path, roi_name))
    #     print('found {} files'.format(len(roi_files)))
    #
    #     layer_dict = dict()
    #     for file_path in roi_files:
    #         file    = np.load(file_path)
    #         mean_ts = np.mean(file,0)
    #         var_ts  = np.var(file,0)
    #         mean    = np.mean(file)
    #         var     = np.var(file)
    #
    #         desc = file_path.split('/')[-1]
    #         id,roi,layer,_ = desc.split('.')
    #         l = int(layer.strip('L'))
    #         layer = 'L{0:02d}'.format(l)
    #         dct = {'id':id,
    #                'roi':roi,
    #                'layer':layer,
    #                'l':int(l),
    #                'mean':mean,
    #                'var':var}
    #
    #         d.append(dct)
    #         layer_dict[l] = mean_ts
    #
    #
    #
    # df = pd.DataFrame(d)
    # df = df.sort_values(['roi','layer'])
    #
    #
    # np.corrcoef()
    #
    #
    #
    #
    # fig = plt.figure(constrained_layout=True, figsize=[len_rois*2,len_rois*2])
    #
    # gs = gridspec.GridSpec(len_rois, len_rois, figure=fig)
    # ax = []
    # # ax.append(plt.subplot(gs[0, :]))
    # # ax.append(plt.subplot(gs[2, 1]))
    # # ax.append(plt.subplot(gs[2, 0]))
    # # ax.append(plt.subplot(gs[2, 2]))
    #
    #
    # for i_r1 in range(len_rois):
    #     for i_r2 in range(i_r1, len_rois):
    #
    #         ax.append(plt.subplot(gs[i_r1, i_r2]))
    #
    #         roi_name1 = rois[i_r1]
    #         roi_name2 = rois[i_r2]
    #
    #
    #         roi_files1 = glob('{}/*.{}.*.npy'.format(path, roi_name1))
    #         print('found {} files'.format(len(roi_files1)))
    #
    #         roi_files2 = glob('{}/*.{}.*.npy'.format(path, roi_name2))
    #         print('found {} files'.format(len(roi_files2)))
    #
    #
    #
    #     d = []
    #     layer_dict = dict()
    #     for file_path in roi_files:
    #         file    = np.load(file_path)
    #         mean_ts = np.mean(file,0)
    #         var_ts  = np.var(file,0)
    #         mean    = np.mean(file)
    #         var     = np.var(file)
    #
    #         desc = file_path.split('/')[-1]
    #         id,roi,layer,_ = desc.split('.')
    #         l = int(layer.strip('L'))
    #
    #         d.append({'id':id,
    #                   'roi':roi,
    #                   'layer':layer,
    #                   'l':l,
    #                   'mean':mean,
    #                   'var':var})
    #         layer_dict[l] = mean_ts
    #         #ax[1].errorbar([x for x in range(len(mean_ts))], file, yerr=var_ts)
    #         ax[0].errorbar([x for x in range(len(mean_ts))], mean_ts, yerr=var_ts, label=layer)
    #
    #     df = pd.DataFrame(d)
    #     df = df.sort_values('l')
    #     #
    #     # ax[0].set(xlabel='Time (~8.4 sec ea; 921sec/110vols)', ylabel='CBV (a.u.)', title=roi)
    #     # handles, labels = ax[0].get_legend_handles_labels()
    #     # labels, handles = zip(*sorted(zip(labels, handles), key=lambda t: t[0]))
    #     # ax[0].legend(handles, labels, fontsize=5) #'xx-small')
    #     #
    #     # '''REST 0:00-0:20; 4:26-4:43; 8:26-8:45; 11:54-12:13; 13:18-13:36, 15:01-15:21
    #     #    REST 0-20; 266-283; 506-525; 714-733; 798-816, 901-921
    #     #    REST 0-2.38; 266-283; 506-525; 714-733; 798-816, 901-921
    #     #     t_sec=[0,20,266,283,506,525,714,733,798,816,901,921]
    #     #     t_frame=[int((t/921)*110) for t in t_sec ]
    #     #     rest=[ [ t_frame[x], t_frame[x+1] ] for x in range(0,len(t_sec),2) ]
    #     #     110 vols
    #     # '''
    #     # ax[1].errorbar(df['l'], df['mean'], yerr=df['var'])
    #     # ax[1].set(xlabel='Layers', ylabel='CBV (a.u.)', title='mean +- var')#roi)
    #     # ax[1].set_xticks(np.arange(12))
    #     # ax[1].set_xticklabels(['WM'] +[ 'L{}'.format(x) for x in range(1,11) ]+ ['CSF'])
    #     #
    #     # ax[3].errorbar(df['l'], df['var'])
    #     # ax[3].set(xlabel='Layers', ylabel='CBV (a.u.)', title='var')
    #     # ax[3].set_xticks(np.arange(12))
    #     # ax[3].set_xticklabels(['WM'] +[ 'L{}'.format(x) for x in range(1,11) ]+ ['CSF'])
    #     #
    #     #
    #     # # rest time periods
    #     # t_sec=[0,20,266,283,506,525,714,733,798,816,901,921]
    #     # t_frame=[int((t/921)*110) for t in t_sec ]
    #     # rest=[ [ t_frame[x], t_frame[x+1] ] for x in range(0,len(t_sec),2) ]
    #     # for r in rest:
    #     #     ax[0].axvspan(r[0], r[1], alpha=0.5, color='red')
    #
    #     o = np.zeros(shape=(len(roi_files),len(roi_files)))
    #     for x in range(1,11):
    #         for y in range(x,11):
    #             o[x-1,y-1] = np.corrcoef(layer_dict[x], layer_dict[y])[0,1]
    #             #o[x-1,y-1] = 1 - spatial.distance.cosine(layer_dict[x], layer_dict[y]) #[0,1]
    #
    #     o = np.triu(o,1).T + o
    #     #im = plt.imshow(o)
    #     im = ax[2].imshow(o)
    #     plt.colorbar(im, ax=ax[2])
    #
    #     ax[2].set_xticks(np.arange(10))
    #     ax[2].set_yticks(np.arange(10))
    #     ax[2].set_xticklabels([ 'L{}'.format(x) for x in range(1,11) ])
    #     ax[2].set_yticklabels([ 'L{}'.format(x) for x in range(1,11) ])
    #     ax[2].set(xlabel='Layers (WM,L1:L10,CSF)', ylabel='Layers (WM,L1:L10,CSF)', title='temporal correlation'.format(roi))
    #
    # plt.savefig("{}/{}.png".format(path,roi_name))
    # plt.close()



if __name__ == "__main__":


    parser = argparse.ArgumentParser(description='generate layer profile')
    parser.add_argument('--path', type=str)
    parser.add_argument('--rois', type=list)

    args = parser.parse_args()
    #path='/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract'
    # rois = ['L_V1', ]

    path = args.path
    rois = args.rois

    print("Creating Plot: ROI:{} path:{}".format(rois, path))
    #generate_func_network(path, rois)
    '''
    path='/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract'
    rois = ['L_V1', 'L_V2', 'L_V3', 'L_V4']
    '''
    generate_func_conn(path, rois)
    # ./generate_func_conn.py --path '/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract' --roi_name 'L_V1'

