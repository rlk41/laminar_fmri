#!/usr/bin/env python

import pandas as pd
from glob import glob
import numpy as np
import argparse
import os
from sklearn.metrics.pairwise import cosine_similarity, cosine_distances, paired_cosine_distances
from scipy import stats

def build_dataframe(paths, rois=None, type='mean'):
    '''
    path='/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract'
    roi_name='L_V1'
    type='cosine'
    :param path:
    :param roi_name:
    :return:
    '''
    # rois = ['L_V1', 'L_V4','thalamic.Left']
    # rois = ['L_TGd','L_TGv', 'L_TE2a'] #,'L_TE2p','L_TE1a','L_TE1m','L_STSvp','L_STSdp','L_STSva','L_STSda','L_STGa','L_TF']

    roi_files = []
    for path in paths:
        roi_files += glob('{}/*.1D'.format(path))
        print('found {} .1D files'.format(len(roi_files)))
        if len(roi_files) == 0:
            roi_files += glob('{}/*.txt'.format(path))
            print('found {} .txt files'.format(len(roi_files)))



    if rois != None:
        roi_files_full = roi_files
        roi_files = []

        for roi in rois:
            if roi in roi_files_full:
                roi_files.append(roi)
        print('found {} files'.format(len(roi_files)))


    TRs = 110
    if type == 'mean':
        a1 = np.zeros(shape=(len(roi_files),TRs))

    elif type == 'cosine':
        #ts_len = ((TRs*TRs)-TRs)/2 # size of upper;lower triangle
        #ind = np.triu_indices(TRs, k=1)[o]
        iu_x,iu_y = np.mask_indices(TRs, np.triu)
        a1 = np.zeros(shape=(len(roi_files),len(iu_x)))

    elif type == 'none':
        a1 = np.zeros(shape=(len(roi_files),TRs))




    l1 = []
    i = 0
    for file_path in roi_files:
        #if '.npy' in file_path:
        # file_path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/timeseries.hcp.l3/sub-01_ses-06_task-movie_run-05_VASO.2180.R_p24.3.txt'
        print("loading: {}".format(file_path))
        if '.npy' in file_path:
            file    = np.load(file_path)
        elif '.txt' or '.1D' in file_path:
            file    = np.loadtxt(file_path)

        print(file.shape)

        # elif '.txt' in file_path:
        #     print("loading txt: {}".format(file_path))
        #     file = np.loadtxt(file_path)
        #     print(file.shape)
# file_path = roi_files[-1]

        if type == 'mean':
            if file.shape != (110,):
                ts = np.mean(file,0)
            else:
                #todo: include this for ROIs hwere only one vozel/timeseres *this really hsouldnt happen need to
                # check columns dont always overlap with layers.
                ts = file
            print('Normalizing')
            ts = stats.zscore(file)

            print(ts.shape)
        elif type == 'cosine':
            #o = np.corrcoef(file, rowvar=False)
            o = 1 - cosine_similarity(file.T)
            ts = o[iu_x, iu_y] #.reshape(1,len(iu_x))

        elif type == 'none':
            ts = file




        desc = file_path.split('/')[-1]
        de = desc.split('.')
        sess,id,roi,layer = de[0], de[-4], de[-3], de[-2]

        if roi.startswith('8'):
            sess,id, layer = de[0], de[-3], de[-2]
            if 'Left' in layer:
                roi = 'L_Thalamus'
            elif 'Right' in layer:
                roi = 'R_Thalamus'

            layer = layer.replace('Left-','')
            layer = layer.replace('Right-','')

        #todo: need to fix this naming profile broke convertign to bash

        #sess,id,roi,layer,_ = desc.split('.')
        #layer = "L{0:02}".format(layer.strip('L'))

        # if roi == 'thalamic':
        #
        #     s = layer.split('-')
        #     layer = '-'.join(s[1:])
        #     roi = "{}_thalamus".format(s[0][0])
        #     #print(s,layer, roi)

        try:
            p = int(layer.strip('L'))
        except:
            p = int(id)

        a1[i,:] = ts
        l1.append({'i':i, 'id':id,'roi':roi,'layer':layer, 'plot':p})

        print("{} {} {} {}".format(i, id, roi, layer))

        i += 1

    labs = pd.DataFrame(l1)

    return labs, a1


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='build dataframe profile')
    parser.add_argument('--paths', type=str, nargs='+')
    parser.add_argument('--rois', type=list, default=None)
    parser.add_argument('--type', type=str, default='none')
    parser.add_argument('--savedir', type=str)

    args = parser.parse_args()
    #path='/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract'
    # rois = ['L_V1', ]



    paths = args.paths
    rois = args.rois
    type = args.type
    save_path  = args.savedir

    print("building dataframe Plot: ROI:{} path:{}".format(rois, paths))
    #generate_func_network(path, rois)
    '''
    type: 
        mean - univatiate mean across roi
        cosine - multivariate pearson across roi
    
    paths=['/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/timeseries.hcp.l3', \
    '/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/timeseries.thalamic']
    
    path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/'+\
    'anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/'+
    'extracted_ts'
    rois = ['L_V1', 'L_V2', 'L_V3', 'L_V4']
    rois=None
    type='none'
    save_path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/dataframe.hcpl3.mean'
    '''

    labs_df, data_array = build_dataframe(paths, rois, type)
    # ./build_dataframe.py --path '/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract' --roi_name 'L_V1'


    #save_path=path+'.{}.dataframe'.format(type)
    print("SAVING TO: {}".format(save_path.split('/')[-2:]))
    os.makedirs(save_path, exist_ok=True)
    np.save(os.path.join(save_path,'numpy_data_array.{}'.format(type)),data_array)
    labs_df.to_pickle(os.path.join(save_path,'labs_df.{}.pkl'.format(type)))

    np.savetxt(os.path.join(save_path,'data.{}.txt'.format(type)),data_array)
    labs_df.to_csv(os.path.join(save_path,'labs.{}.txt'.format(type)), sep=' ')