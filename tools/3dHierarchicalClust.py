#!/usr/bin/env python

import os
from numpy.lib.function_base import corrcoef
import argparse
import numpy as np
import matplotlib.pyplot as plt
import pylab
import scipy.cluster.hierarchy as sch
import nibabel as nib 
from nilearn.input_data import NiftiLabelsMasker
import pickle 
from scipy.cluster.hierarchy import cut_tree, fcluster


def extract_columns(data_input, data_columns):

    cols = []
    ids = []

    #unq_c = len(np.unique(data_columns).astype(int)[1:])
    #unq_d = len(np.unique(data_input[:,:,:,1]).astype(int)[1:])


    unq_column_ids     = np.unique(data_columns).astype(int)[1:]
    #for unq_column_id in unq_column_ids: 
    zeros = np.zeros(shape=(1,10))
    for unq_column_id in unq_column_ids: 

        inds             = np.where(data_columns == unq_column_id) 
        inds_data        = data_input[inds][0,:]
        #inds_data_mean   = np.mean(inds_data,0)
        
        if np.all(inds_data == zeros): 
            print('    ZEROS {}'.format(unq_column_id))
            continue

        cols.append(inds_data)
        ids.append(unq_column_id)

        print(unq_column_id)
        
    cols = np.array(cols)

    return cols, ids

def extract_columns_nibabel(path_columns, path_data):


    # data = datasets.fetch_development_fmri(n_subjects=1)
    # data.confounds 


    masker = NiftiLabelsMasker(labels_img=path_columns, standardize=True,
                            memory='nilearn_cache', verbose=5)

    
    time_series = masker.fit_transform(path_data) #, confounds=data.confounds)


    cols = []
    ids = []

    unq_column_ids     = np.unique(data_columns).astype(int)[1:]
    for unq_column_id in unq_column_ids: 

        inds             = np.where(data_columns == unq_column_id) 
        inds_data        = data_input[inds]
        inds_data_mean   = np.mean(inds_data,0)
        
        cols.append(inds_data_mean)
        ids.append(unq_column_id)

        print(unq_column_id)
        
        
    cols = np.array(cols)

    return cols, ids

def cluster(o_array, save_path, dpi=400, size=(24,24)):
    '''
    o_array=array
    df=ids
    path='./hierarchicalClust'
    dpi=400
    size=(24,24)
    '''

    if not os.path.exists(save_path):
        os.makedirs(save_path)

    print("o_array shape: {}".format(o_array.shape))

    D = corrcoef(o_array)

    print("D shape: {}".format(D.shape))

    len_rois = D.shape[0]

    # Compute and plot dendrogram.
    fig = pylab.figure(figsize=size, dpi=dpi)
    axdendro = fig.add_axes([0.09,0.1,0.2,0.8])
    Y = sch.linkage(D, method='centroid')
    Z = sch.dendrogram(Y, orientation='right')

    index           = Z['leaves']
    #labels          = [ '-'.join([df['r1'].iloc[l], df['r2'].iloc[l]]) for l in range(df.shape[0]) ]
    #labels_reorg    = [ labels [x] for x in index ]
    labels_reorg = ids 

    #axdendro.set_xticks([])
    #axdendro.set_yticks([])
    #axdendro.set_xticks(range(len_rois))
    #axdendro.set_yticks(range(len_rois))
    #axdendro.set_xticklabels(labels_reorg)
    axdendro.set_yticklabels(labels_reorg)

    # Plot distance matrix.
    axmatrix = fig.add_axes([0.3,0.1,0.6,0.8])

    D = D[index,:]
    D = D[:,index]

    im = axmatrix.matshow(D, aspect='auto', origin='lower')
    axmatrix.set_xticks([])
    axmatrix.set_yticks([])

    # Plot colorbar.
    axcolor = fig.add_axes([0.91,0.1,0.02,0.8])
    pylab.colorbar(im, cax=axcolor)

    # Display and save figure.
    fig.show()

    plt.savefig(os.path.join(save_path,'dendrogram.ALL.jpeg'))

    plt.close()

    return Y,Z

def create_nifti(Y, ids, img_columns, prefix='', branches=2):

    data_columns = img_columns.get_fdata()
    
    out = np.zeros(shape=data_columns.shape)


    #cuttree = cut_tree(Y, n_clusters=branches)
    cuttree = fcluster(Y, branches, criterion='maxclust')

    clust_fill = 1 
    for c in np.unique(cuttree): 
        ind = np.where(cuttree == c)[0]
        fill = np.array(ids)[ind]

        for f in fill: 
            fill_inds = np.where(data_columns == f )
            out[fill_inds] = clust_fill
        
        clust_fill += 1 


    savepath=prefix+'.hierarchClust_clust-{}.nii.gz'.format(branches)

    out_img = nib.Nifti1Image(out, img_columns.affine, img_columns.header)
    nib.save(out_img, savepath )

    print("DONE: {}".format(savepath))

    return 



if __name__ == "__main__":


    parser = argparse.ArgumentParser(description='generate layer profile')
    parser.add_argument('--input', type=str)
    parser.add_argument('--columns', type=str)
    parser.add_argument('--output', type=str)
    args = parser.parse_args()

    path_input      = args.input
    path_columns    = args.columns
    path_output     = args.output 

    '''
    #path_input="/data/kleinrl/Wholebrain2.0/fsl_feats/DAY1_run5_VASO_LN/both.LGN.2D.pca_010.feat/smoothed_inv_thresh_zstat1.L2D.downscaled2x.nii.gz"
    #path_input="/data/kleinrl/Wholebrain2.0/fsl_feats/DAY1_run5_VASO_LN/both.LGN.2D.pca_010.feat/smoothed_inv_thresh_zstat1.L2D.downscaled2x_NN.nii.gz"
    
    path_columns="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/LAYNII_2/columns/columns_ev_1000_borders.downscaled2x_NN.nii.gz"
    path_input="/data/kleinrl/Wholebrain2.0/fsl_feats/DAY1_run5_VASO_LN/both.LGN.2D.pca_001.feat/smoothed_inv_thresh_zstat1.L2D-columns_ev_1000_borders.downscaled2x_NN.nii.gz"
    path_output='./hierarchicalClust'
    '''

    print("path_input:   "    + path_input)
    print("path_columns: "  + path_columns)
    print("path_output:  "   + path_output)

    img_input           = nib.load(path_input)
    data_input          = img_input.get_fdata()

    img_columns         = nib.load(path_columns)
    data_columns        = img_columns.get_fdata()

    print("extracting columns")
    array, ids = extract_columns(data_input, data_columns)
    
    print("shape array {}".format(array.shape))
    print("len ids {}".format(len(ids)))

    print("building clusters")
    Y,Z = cluster(array, path_output, dpi=400, size=(24,24))

    print("dumping")
    pickle.dump(Z, open( path_output+'/Z.pkl', "wb" ) )
    pickle.dump(Y, open( path_output+'/Y.pkl', "wb" ) )

    print("cutting trees")
    branches = [2,4,6,10,20,50,100,500]
    prefix=path_output+'/'+path_input.split('/')[-1].rstrip('.nii.gz').rstrip('.nii')
    for branch in branches:
        create_nifti(Y, ids, img_columns, prefix=prefix, branches=branch)




    print("DONE")



