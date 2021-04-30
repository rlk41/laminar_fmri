import pandas as pd
from glob import glob
import numpy as np
import argparse
import os
from sklearn.metrics.pairwise import cosine_similarity, cosine_distances, paired_cosine_distances


def build_dataframe(path, rois=None, type='mean'):
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

    if rois == None:
        #get all in dir
        roi_files = glob('{}/*.npy'.format(path))
        print('found {} files'.format(len(roi_files)))
    else:
        roi_files = []
        for roi in rois:
            rs = glob('{}/*{}*.npy'.format(path, roi))
            for r in rs:
                roi_files.append(r)
        print('found {} files'.format(len(roi_files)))


    TRs = 110
    if type == 'mean':
        a1 = np.zeros(shape=(len(roi_files),TRs))

    elif type == 'cosine':
        #ts_len = ((TRs*TRs)-TRs)/2 # size of upper;lower triangle
        #ind = np.triu_indices(TRs, k=1)[o]
        iu_x,iu_y = np.mask_indices(TRs, np.triu)
        a1 = np.zeros(shape=(len(roi_files),len(iu_x)))


    l1 = []
    i = 0
    for file_path in roi_files:
        file    = np.load(file_path)
        if type == 'mean':
            ts = np.mean(file,0)
        elif type == 'cosine':
            #o = np.corrcoef(file, rowvar=False)
            o = 1 - cosine_similarity(file.T)
            ts = o[iu_x, iu_y] #.reshape(1,len(iu_x))

        desc = file_path.split('/')[-1]
        id,roi,layer,_ = desc.split('.')
        #layer = "L{0:02}".format(layer.strip('L'))

        if roi == 'thalamic':

            s = layer.split('-')
            layer = '-'.join(s[1:])
            roi = "{}_thalamus".format(s[0][0])
            #print(s,layer, roi)

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

    parser = argparse.ArgumentParser(description='generate layer profile')
    parser.add_argument('--path', type=str)
    parser.add_argument('--rois', type=list, default=None)
    parser.add_argument('--type', type=str, default='mean')

    args = parser.parse_args()
    #path='/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract'
    # rois = ['L_V1', ]

    path = args.path
    rois = args.rois
    type = args.type

    print("building dataframe Plot: ROI:{} path:{}".format(rois, path))
    #generate_func_network(path, rois)
    '''
    type: 
        mean - univatiate mean across roi
        cosine - multivariate pearson across roi
    
    path='/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract'
    rois = ['L_V1', 'L_V2', 'L_V3', 'L_V4']
    '''

    labs_df, data_array = build_dataframe(path, rois, type)
    # ./build_dataframe.py --path '/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract' --roi_name 'L_V1'


    save_path=path+'.{}.dataframe'.format(type)

    print("SAVING TO: {}".format(save_path))
    os.makedirs(save_path, exist_ok=True)
    np.save(os.path.join(save_path,'numpy_data_array.{}'.format(type)),data_array)
    labs_df.to_pickle(os.path.join(save_path,'labs_df.{}.pkl'.format(type)))