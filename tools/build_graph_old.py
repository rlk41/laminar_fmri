import matplotlib.pyplot as plt
import scipy.stats
import pandas as pd
import numpy as np
import argparse

# import nibabel
#
# from nilearn.datasets import fetch_haxby
# from nilearn.input_data import NiftiMasker, NiftiLabelsMasker
# import nilearn
#
# from kmapper import KeplerMapper, Cover
# from sklearn.manifold import TSNE
# from sklearn.cluster import DBSCAN
#from dyneusr import DyNeuGraph

def main2(epi_path, parc_path=None, roi_files_dir=None):

    parc = nilearn.image.resample_to_img(parc_path, epi_path, interpolation='nearest')
    nibabel.save(parc, parc_path)

    masker = NiftiLabelsMasker(
        labels_img=parc,
        standardize=True, detrend=True, # smoothing_fwhm=4.0,
        low_pass=0.09, high_pass=0.008, t_r=6.4,
        memory="nilearn_cache")
    a1 = nibabel.load(epi).affine
    a2 = nibabel.load(parc).affine
    print(a1-a2)
    X = masker.fit_transform(epi)

    # Encode labels as integers
    df = pd.read_csv(dataset.session_target[0], sep=" ")
    target, labels = pd.factorize(df.labels.values)
    y = pd.DataFrame({l:(target==i).astype(int) for i,l in enumerate(labels)})

    # Generate shape graph using KeplerMapper
    mapper = KeplerMapper(verbose=1)
    lens = mapper.fit_transform(X, projection=TSNE(2))
    graph = mapper.map(lens, X, cover=Cover(20, 0.5), clusterer=DBSCAN(eps=20.))

    # Visualize the shape graph using DyNeuSR's DyNeuGraph
    dG = DyNeuGraph(G=graph, y=y)
    dG.visualize('dyneusr_output.html')

def main(matrix_path, labs_path):




if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='extract_ts')
    parser.add_argument('--matrix',type=str)
    parser.add_argument('--labs', type=str)
    parser.add_argument('--rois', type=str, nargs='+')
    args = parser.parse_args()

    matrix_path = args.matrix
    labs_path   = args.labs
    rois        = args.rois

    '''
    matrix_path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/'+ \
                'sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/'+ \
                'sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/matrix.hcpl3_thalamic/matrix.txt'
                
    labs_path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/' + \
                'sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO' + \
                '/matrix.hcpl3_thalamic/labs.txt'
    '''
    labs = pd.read_csv(labs_path, sep=' ')

    build_corr_mat = True
    if build_corr_mat:
        mat = np.loadtxt(matrix_path)
        print("loaded mat shape: {} ".format(mat.shape))

        r_mat = np.corrcoef(mat,rowvar=False)

        #############
        #p_values = scipy.stats.norm.sf(abs(z_scores)) #one-sided
        p_mat = scipy.stats.norm.sf(abs(r_mat))*2
        print("max {} min {}".format(np.max(r_mat), np.min(r_mat)))
        print("max {} min {}".format(np.max(p_mat), np.min(p_mat)))







        p_mat[p_mat >= 0.05] = 0.05

        plt.imshow(p_mat)
        plt.show()
        # for x in corr_mat.shape[1]:
        #     for y in corr_mat.shape[0]:
        #         p_mat[x,y] = scipy.stats.norm.sf(abs(corr_mat[y,x]))*2 #twosided



        #r, p = scipy.stats.pearsonr(mat)

        print("corr_mat shape: {} ".format(corr_mat.shape))
    else:
        print('load corr_mat ')

    if len(rois) != 0:
        print('write get rois code')
        labs




    build_graph(matrix)