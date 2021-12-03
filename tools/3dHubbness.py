#!/usr/bin/env python

import os
from glob import glob
import pandas as pd
import argparse
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity, cosine_distances, paired_cosine_distances
from scipy.special import betainc
import matplotlib.pyplot as plt
import scipy
import pylab
import scipy.cluster.hierarchy as sch
import nibabel as nib 
from multiprocessing import Pool 
from shutil import copyfile


def get_dissimilarity_matrix(unq_column_id, unq_layer_ids, path_epi, path_layers, path_columns, inds_list=None, data_epi=None):

    if inds_list == None: 
        img_epi         = nib.load(path_epi) 
        img_layers      = nib.load(path_layers)
        img_columns     = nib.load(path_columns)
        
        data_layers     = img_layers.get_fdata()
        data_columns    = img_columns.get_fdata()

        data_epi        = img_epi.get_fdata()


        #print('column: {}'.format(unq_column_id))
        #unq_layer_ids      = np.unique(data_layers)

        inds_data_list = [] 
        for unq_layer_id in unq_layer_ids: 
            inds            = np.where((data_layers == unq_layer_id) & (data_columns == unq_column_id))
            inds_data       = data_epi[inds]
            inds_data_mean  = np.mean(inds_data,0)
            inds_data_zscore = (inds_data_mean - np.mean(inds_data_mean))/np.std(inds_data_mean)

            inds_data_list.append(inds_data_zscore)

        a = np.array(inds_data_list).T

        o = np.corrcoef(a)
        o_tri = o[np.triu_indices(o.shape[0], 1)]

    else: 

        inds_data_list = [] 
        for inds in inds_list: 
            inds_data           = data_epi[inds]
            inds_data_mean      = np.mean(inds_data,0)
            inds_data_zscore    = (inds_data_mean - np.mean(inds_data_mean))/np.std(inds_data_mean)

            inds_data_list.append(inds_data_zscore)

        a = np.array(inds_data_list).T

        o = np.corrcoef(a)
        o_tri = o[np.triu_indices(o.shape[0], 1)]

    return o_tri, a 

def build_jobs(path_epi, path_columns, path_layers):

    img_epi         = nib.load(path_epi) 
    img_layers      = nib.load(path_layers)
    img_columns     = nib.load(path_columns)

    data_layers     = img_layers.get_fdata()
    data_columns    = img_columns.get_fdata()
    data_epi        = img_epi.get_fdata()


    unq_layer_ids      = np.unique(data_layers).astype(int)[1:]
    unq_column_ids     = np.unique(data_columns).astype(int)[1:]

    jobs = [] 
    for c in unq_column_ids:
        d = {
            'path_epi': path_epi, 
            'path_layers': path_layers, 
            'path_columns': path_columns, 
            'unq_column_id': c, 
            'unq_layer_ids': unq_layer_ids,
            }
        jobs.append(d)

    return jobs 

def build_grouped_jobs(path_epi, path_columns, path_layers, groups=10):

    img_layers      = nib.load(path_layers)
    img_columns     = nib.load(path_columns)

    data_layers     = img_layers.get_fdata()
    data_columns    = img_columns.get_fdata()

    unq_layer_ids      = np.unique(data_layers).astype(int)[1:]
    unq_column_ids     = np.unique(data_columns).astype(int)[1:]



    j           = [ int(i) for i in np.linspace(0, len(unq_column_ids), num=groups-1) ]
    j           = [ [j[i], j[i+1]-1] for i in range(len(j)-1) ] 
    j[-1][-1]   = len(unq_column_ids)


    #jobs_grouped = [ jobs[j_ind[0]:j_ind[1]] for j_ind in j ]


    jobs_grouped = [] 
    for j_i in range(len(j)):

        j_range = j[j_i]


        new_path_epi        = '/'.join(path_epi.split('/')[:-1])+'/'+path_epi.split('/')[-1].split('.')[0]+'_{}.nii'.format(j_i)
        new_path_columns    = '/'.join(path_columns.split('/')[:-1])+'/'+path_columns.split('/')[-1].split('.')[0]+'_{}.nii'.format(j_i)
        new_path_layers     = '/'.join(path_layers.split('/')[:-1])+'/'+path_layers.split('/')[-1].split('.')[0]+'_{}.nii'.format(j_i)

        copyfile(path_epi, new_path_epi)
        copyfile(path_columns, new_path_columns)
        copyfile(path_layers, new_path_layers)

        jobs = []
        for c in unq_column_ids[j_range[0]:j_range[1]]:

            d = {
                'path_epi':     new_path_epi, 
                'path_layers':  new_path_layers, 
                'path_columns': new_path_columns, 
                'unq_column_id': c, 
                'unq_layer_ids': unq_layer_ids,
                }
            jobs.append(d)
        jobs_grouped.append(jobs)

    return jobs_grouped

def run_jobs(d):

    path_epi        = d['path_epi']
    path_layers     = d['path_layers']
    path_columns    = d['path_columns']
    unq_layer_ids   = d['unq_layer_ids']
    unq_column_id   = d['unq_column_id']

    o_tri, a        = get_dissimilarity_matrix(unq_column_id, unq_layer_ids, path_epi, path_layers, path_columns)

    d['o_tri']      = o_tri 
    d['a']          = a 

    print('DONE: {}'.format(unq_column_id ))

    return d 

def run_grouped_jobs(l):

    path_epi        = l[0]['path_epi']
    img_epi         = nib.load(path_epi) 
    data_epi        = img_epi.get_fdata()

    path_columns    = l[0]['path_columns']
    img_columns     = nib.load(l[0]['path_columns']) 
    data_columns    = img_columns.get_fdata()

    path_layers     = l[0]['path_layers']
    img_layers      = nib.load(l[0]['path_layers']) 
    data_layers     = img_layers.get_fdata()
  
    print(path_epi)

    ds = []
    for d in l:

        unq_layer_ids   = d['unq_layer_ids']
        unq_column_id   = d['unq_column_id']

        inds_list = [] 
        for unq_layer_id in unq_layer_ids: 
            inds = np.where((data_columns == unq_column_id) & (data_layers == unq_layer_id))
            inds_list.append(inds)

        o_tri, a = get_dissimilarity_matrix(unq_column_id, unq_layer_ids, path_epi, path_layers, path_columns, inds_list=inds_list, data_epi=data_epi)

        d['o_tri']      = o_tri 
        d['a']          = a 

        ds.append(d)
        print("{} {}".format(path_epi, unq_column_id))

    return ds

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


if __name__ == "__main__":


    parser = argparse.ArgumentParser(description='generate layer profile')
    parser.add_argument('--epi', type=str)
    parser.add_argument('--columns', type=str)
    parser.add_argument('--layers', type=str)
    parser.add_argument('--column_id', type=int)
    #parser.add_argument('--outdir', type=str)
    args = parser.parse_args()


    path_epi        = args.epi
    path_columns    = args.columns
    path_layers     = args.layers
    column_id       = args.column_id


    '''
    path_columns="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/LAYNII_2/columns/warped_columns_ev_10000_borders.nii"
    path_layers="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/LAYNII_2/layers/warped_rim_equidist_n3_layers_equidist.nii"
    path_epi="/data/kleinrl/Wholebrain2.0/DAY3/run5/VASO_LN.nii"
    '''


    img_epi         = nib.load(path_epi) 
    img_layers      = nib.load(path_layers)
    img_columns     = nib.load(path_columns)

    data_layers     = img_layers.get_fdata()
    data_columns    = img_columns.get_fdata()
    data_epi        = img_epi.get_fdata()


    unq_layer_ids      = np.unique(data_layers).astype(int)[1:]
    unq_column_ids     = np.unique(data_columns).astype(int)[1:]


    inds_data_list = [] 

    for unq_layer_id in unq_layer_ids: 
        inds             = np.where((data_columns == column_id) & (data_layers == unq_layer_id))
        inds_data        = data_epi[inds]
        inds_data_mean   = np.mean(inds_data,0)
        inds_data_zscore = (inds_data_mean - np.mean(inds_data_mean))/np.std(inds_data_mean)

        inds_data_list.append(inds_data_zscore)

    a       = np.array(inds_data_list).T
    o       = np.corrcoef(a)
    o_tri   = o[np.triu_indices(o.shape[0], 1)]

    outdir = path_epi.split('/')[:-1]