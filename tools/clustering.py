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

def example():
    # Author: Alexandre Gramfort <alexandre.gramfort@inria.fr>
    # License: BSD 3 clause

    print(__doc__)

    import shutil
    import tempfile

    import numpy as np
    import matplotlib.pyplot as plt
    from scipy import linalg, ndimage
    from joblib import Memory

    from sklearn.feature_extraction.image import grid_to_graph
    from sklearn import feature_selection
    from sklearn.cluster import FeatureAgglomeration
    from sklearn.linear_model import BayesianRidge
    from sklearn.pipeline import Pipeline
    from sklearn.model_selection import GridSearchCV
    from sklearn.model_selection import KFold

    #############################################################################
    # Generate data
    n_samples = 200
    size = 40  # image size
    roi_size = 15
    snr = 5.
    np.random.seed(0)
    mask = np.ones([size, size], dtype=bool)

    coef = np.zeros((size, size))
    coef[0:roi_size, 0:roi_size] = -1.
    coef[-roi_size:, -roi_size:] = 1.

    X = np.random.randn(n_samples, size ** 2)
    for x in X:  # smooth data
        x[:] = ndimage.gaussian_filter(x.reshape(size, size), sigma=1.0).ravel()
    X -= X.mean(axis=0)
    X /= X.std(axis=0)

    y = np.dot(X, coef.ravel())
    noise = np.random.randn(y.shape[0])
    noise_coef = (linalg.norm(y, 2) / np.exp(snr / 20.)) / linalg.norm(noise, 2)
    y += noise_coef * noise  # add noise

    # #############################################################################
    # Compute the coefs of a Bayesian Ridge with GridSearch
    cv = KFold(2)  # cross-validation generator for model selection
    ridge = BayesianRidge()
    cachedir = tempfile.mkdtemp()
    mem = Memory(location=cachedir, verbose=1)

    # Ward agglomeration followed by BayesianRidge
    connectivity = grid_to_graph(n_x=size, n_y=size)
    ward = FeatureAgglomeration(n_clusters=10, connectivity=connectivity,
                                memory=mem)
    clf = Pipeline([('ward', ward), ('ridge', ridge)])
    # Select the optimal number of parcels with grid search
    clf = GridSearchCV(clf, {'ward__n_clusters': [10, 20, 30]}, n_jobs=1, cv=cv)
    clf.fit(X, y)  # set the best parameters
    coef_ = clf.best_estimator_.steps[-1][1].coef_
    coef_ = clf.best_estimator_.steps[0][1].inverse_transform(coef_)
    coef_agglomeration_ = coef_.reshape(size, size)

    # Anova univariate feature selection followed by BayesianRidge
    f_regression = mem.cache(feature_selection.f_regression)  # caching function
    anova = feature_selection.SelectPercentile(f_regression)
    clf = Pipeline([('anova', anova), ('ridge', ridge)])
    # Select the optimal percentage of features with grid search
    clf = GridSearchCV(clf, {'anova__percentile': [5, 10, 20]}, cv=cv)
    clf.fit(X, y)  # set the best parameters
    coef_ = clf.best_estimator_.steps[-1][1].coef_
    coef_ = clf.best_estimator_.steps[0][1].inverse_transform(coef_.reshape(1, -1))
    coef_selection_ = coef_.reshape(size, size)

    # #############################################################################
    # Inverse the transformation to plot the results on an image
    plt.close('all')
    plt.figure(figsize=(7.3, 2.7))
    plt.subplot(1, 3, 1)
    plt.imshow(coef, interpolation="nearest", cmap=plt.cm.RdBu_r)
    plt.title("True weights")
    plt.subplot(1, 3, 2)
    plt.imshow(coef_selection_, interpolation="nearest", cmap=plt.cm.RdBu_r)
    plt.title("Feature Selection")
    plt.subplot(1, 3, 3)
    plt.imshow(coef_agglomeration_, interpolation="nearest", cmap=plt.cm.RdBu_r)
    plt.title("Feature Agglomeration")
    plt.subplots_adjust(0.04, 0.0, 0.98, 0.94, 0.16, 0.26)
    plt.show()

    # Attempt to remove the temporary cachedir, but don't worry if it fails
    shutil.rmtree(cachedir, ignore_errors=True)

def clust_hierarchrical(path, rois=None, dist='cosine', plot=True):
    '''
    path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/dataframe.c1kl3.mean'
    rois = ['168']
    rois = ['L_thalamus','L_V1','L_V2','L_V3','L_V3A','L_V3B','L_V3CD','L_V4','L_V4t','L_V6']
    :param path:
    :param roi_name:
    :return:
    '''
    save_path = path.replace('dataframe','clust_hierarchrical')

    if not os.path.exists(save_path):
        os.makedirs(save_path)


    labs = pd.read_pickle(glob(os.path.join(path,'*.pkl'))[0])
    a   = np.load(glob(os.path.join(path,'*.npy'))[0])


    c = 1 - cosine_similarity(a)


    len_rois = len(rois)

    # fig = plt.figure(constrained_layout=True, figsize=[len_rois*5,len_rois*5])
    # gs = gridspec.GridSpec(len_rois, len_rois, figure=fig)
    #
    # ax = []
    o_list = []
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

            o_list.append(o)
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
                r1      = r1_list[i_list]
                r2      = r2_list[i_list]
                len_v1  = len_v1_list[i_list]
                len_v2  = len_v2_list[i_list]
                v1_labs = v1_labs_list[i_list]
                v2_labs = v2_labs_list[i_list]

                i_list += 1

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

        plt.savefig(os.path.join(save_path,'-'.join(rois)))
        plt.close()


    for i_list in range(len(o_list)):
        o       = o_list[i_list]
        r1      = r1_list[i_list]
        r2      = r2_list[i_list]
        len_v1  = len_v1_list[i_list]
        len_v2  = len_v2_list[i_list]
        v1_labs = v1_labs_list[i_list]
        v2_labs = v2_labs_list[i_list]

        np.savetxt(os.path.join(save_path,'-'.join([r1, r2])+'.txt'),o)


if __name__ == "__main__":


    parser = argparse.ArgumentParser(description='generate layer profile')
    parser.add_argument('--path', type=str)
    parser.add_argument('--rois', nargs='+')
    parser.add_argument('--plot', type=bool)
    parser.add_argument('--type', type=str, default='hierarchical')

    args = parser.parse_args()
    #path='/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract'
    # rois = ['L_V1', ]

    path = args.path
    rois = args.rois
    type = args.type

    print("\n clustering  \n"
          "   type:{}  \n"
          "   path:{} \n".format(rois, type))
    #generate_func_network(path, rois)
    '''
    path='/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract'
    rois = ['L_V1', 'L_V2', 'L_V3', 'L_V4']
    '''

    if type == 'hierarchrical':
        clust_hierarchrical()

    '''
    python ./generate_fc_from_df.py \
    --path '/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract_dataframe' \
    --rois L_thalamic L_TGd L_TGv L_TE2a L_TE2p L_TE1a L_TE1m L_STSvp L_STSdp L_STSva L_STSda L_STGa L_TF

    python ./generate_fc_from_df.py \
    --path '/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract_dataframe' \
    --rois L_thalamus L_V1 L_V2 L_V3 L_V3A L_V3B L_V3CD L_V4 L_V4t L_V6 

    '''