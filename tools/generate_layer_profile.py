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


def generate_layer_profile(path, roi_name):
    '''
    path='/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract_n3'
    roi_name='L_V1'
    roi_name='Left-VLa'
    :param path:
    :param roi_name:
    :return:
    '''
    if 'Left' in roi_name :
        roi_files = glob('{}/*.thalamic.Left-*.npy'.format(path, roi_name))
        thal = True
    elif 'Right' in roi_name:
        roi_files = glob('{}/*.thalamic.Right-*.npy'.format(path, roi_name))
        thal = True
    else:
        roi_files = glob('{}/*.{}.*.npy'.format(path, roi_name))
        thal = False
    print('found {} files'.format(len(roi_files)))

    fig = plt.figure(constrained_layout=True, figsize=[10,7])
    gs = gridspec.GridSpec(3, 5, figure=fig)

    ax = []
    ax.append(plt.subplot(gs[0, :]))
    ax.append(plt.subplot(gs[2, 1]))
    ax.append(plt.subplot(gs[2, 0]))
    ax.append(plt.subplot(gs[2, 2]))

    d = []
    layer_dict = dict()
    for file_path in roi_files:
        file    = np.load(file_path)
        mean_ts = np.mean(file,0)
        var_ts  = np.var(file,0)
        mean    = np.mean(file)
        var     = np.var(file)

        desc = file_path.split('/')[-1]
        sess,id,roi,layer,_ = desc.split('.')
        try:
            l = int(layer.strip('L'))
        except:
            l = int(id)


        d.append({'id':id,
                  'roi':roi,
                  'layer':layer,
                  'l':l,
                  'mean':mean,
                  'var':var})
        layer_dict[l] = mean_ts
        #ax[1].errorbar([x for x in range(len(mean_ts))], file, yerr=var_ts)
        ax[0].errorbar([x for x in range(len(mean_ts))], mean_ts, yerr=var_ts, label=layer)

    df = pd.DataFrame(d)
    df = df.sort_values('l')

    ax[0].set(xlabel='Time (~8.4 sec ea; 921sec/110vols)', ylabel='CBV (a.u.)', title=roi)
    handles, labels = ax[0].get_legend_handles_labels()
    labels, handles = zip(*sorted(zip(labels, handles), key=lambda t: t[0]))
    ax[0].legend(handles, labels, fontsize=4) #'xx-small')

    '''REST 0:00-0:20; 4:26-4:43; 8:26-8:45; 11:54-12:13; 13:18-13:36, 15:01-15:21
       REST 0-20; 266-283; 506-525; 714-733; 798-816, 901-921
       REST 0-2.38; 266-283; 506-525; 714-733; 798-816, 901-921
        t_sec=[0,20,266,283,506,525,714,733,798,816,901,921]
        t_frame=[int((t/921)*110) for t in t_sec ]
        rest=[ [ t_frame[x], t_frame[x+1] ] for x in range(0,len(t_sec),2) ] 
        110 vols
    '''
    if thal:
        ax[1].errorbar(df['l'], df['mean'], yerr=df['var'])
        ax[1].set(xlabel='Layers', ylabel='mean CBV +- var (a.u.)') #, title='')#roi)
        ax[1].set_xticks(np.arange(df.shape[0]))
        ax[1].set_xticklabels(df['layer'])

        ax[3].errorbar(df['l'], df['var'])
        ax[3].set(xlabel='Layers', ylabel='CBV (a.u.)', title='var')
        ax[3].set_xticks(np.arange(df.shape[0]))
        ax[3].set_xticklabels(df['layer'])

    else:
        ax[1].errorbar(df['l'], df['mean'], yerr=df['var'])
        ax[1].set(xlabel='Layers', ylabel='CBV (a.u.)', title='mean CBV +- var')#roi)
        ax[1].set_xticks(np.arange(df.shape[0]+2))
        ax[1].set_xticklabels(['WM'] +[ 'L{}'.format(x) for x in range(1,df.shape[0]+1) ]+ ['CSF'])

        ax[3].errorbar(df['l'], df['var'])
        ax[3].set(xlabel='Layers', ylabel='CBV (a.u.)', title='var')
        ax[3].set_xticks(np.arange(df.shape[0]+2))
        ax[3].set_xticklabels(['WM'] +[ 'L{}'.format(x) for x in range(1, df.shape[0]+1) ]+ ['CSF'])


    # rest time periods
    t_sec=[0,20,266,283,506,525,714,733,798,816,901,921]
    t_frame=[int((t/921)*110) for t in t_sec ]
    rest=[ [ t_frame[x], t_frame[x+1] ] for x in range(0,len(t_sec),2) ]
    for r in rest:
        ax[0].axvspan(r[0], r[1], alpha=0.5, color='red')

    o = np.zeros(shape=(len(roi_files),len(roi_files)))
    k = list(layer_dict.keys())
    k.sort()
    for x in range(len(k)):
        for y in range(len(k)):
            o[x-1,y-1] = np.corrcoef(layer_dict[k[x]], layer_dict[k[y]])[0,1]
            #o[x-1,y-1] = 1 - spatial.distance.cosine(layer_dict[x], layer_dict[y]) #[0,1]

    #o = np.triu(o,1).T + o
    #im = plt.imshow(o)
    im = ax[2].imshow(o)
    plt.colorbar(im, ax=ax[2])

    if thal:
        ax[2].set_xticks(np.arange(df.shape[0]))
        ax[2].set_yticks(np.arange(df.shape[0]))
        ax[2].set_xticklabels(df['layer'])
        ax[2].set_yticklabels(df['layer'], )
        ax[2].set(xlabel='Parcs', ylabel='Parcs', title='temporal corr.'.format(roi))
    else:
        ax[2].set_xticks(np.arange(df.shape[0]))
        ax[2].set_yticks(np.arange(df.shape[0]))
        ax[2].set_xticklabels([ 'L{}'.format(x) for x in range(1,df.shape[0]+1) ])
        ax[2].set_yticklabels([ 'L{}'.format(x) for x in range(1,df.shape[0]+1) ])
        ax[2].set(xlabel='Layers (WM,L#,CSF)', ylabel='Layers (WM,L#,CSF)', title='temporal correlation'.format(roi))

    plt.savefig("{}/{}.png".format(path,roi_name))
    plt.close()


    # fig, ax = plt.subplots()
    # ax.errorbar(df['l'], df['mean'], yerr=df['var'])
    # ax.set(xlabel='Layers', ylabel='mean', title=roi)
    # plt.locator_params(axis="x", nbins=10)
    # plt.savefig("{}/{}.png".format(path,roi_name))
    # plt.close(fig=fig)

if __name__ == "__main__":


    parser = argparse.ArgumentParser(description='generate layer profile')
    parser.add_argument('--path', type=str)
    parser.add_argument('--roi_name', type=str)
    parser.add_argument('--ALL', action='store_true')

    args = parser.parse_args()
    #path='/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract'
    #roi_name='L_V1'
    # roi_name = 'L_1'
    # id_roi = 1001
    # id_layer = 1
    path = args.path
    roi_name = args.roi_name

    if args.ALL:
        print("running ALL")

        files = glob.glob('{}/*.npy'.format(path))

        desc = [ f.split('/')[-1] for f in files ]
        desc = [ f.split('.')[1] for f in desc ]
        desc = [ f for f in set(desc) ]#.sort()

        print('found {} ROI profiles'.format(len(desc)))

        for f in desc:
            print('generating profile for ROI: {}'.format(f))
            generate_layer_profile(path, f)


        # python ./generate_func_conn.py --path '/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract' --ALL



    else:
        print("Creating Plot: ROI:{} path:{}".format(roi_name, path))
        generate_layer_profile(path, roi_name)

    # ./generate_func_conn.py --path '/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract' --roi_name 'L_V1'

