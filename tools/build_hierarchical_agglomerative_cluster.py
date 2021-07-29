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

def get_nodes_for_clustering(path, rois=None, dist='pearson', plot=True):
    '''
    path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/dataframe.hcpl3_thalamic.preprocd'
    rois = ['L_Thalamus','L_V1']
    rois = ['L_Thalamus','L_V1'] ,'L_V2','L_V3','L_V3A','L_V3B','L_V3CD','L_V4','L_V4t','L_V6']

    :param path:
    :param roi_name:
    :return:
    '''

    labs = pd.read_pickle(glob(os.path.join(path,'*.pkl'))[0])
    a   = np.load(glob(os.path.join(path,'*.npy'))[0])

    if dist == 'pearson':
        c,p = corrcoef(a)
        print("min {} \n max {}".format(np.min(p), np.max(p)))
    elif dist == 'cosine':
        c = 1 - cosine_similarity(a)


    # get number of ROIs gependent on whether you specify a list or use all in matrix
    # if non specified us all
    # may want to order these in way that makes sense
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
        #for i2 in range(len_rois):

        r1 = rois[i1]
        #r2 = rois[i2]

        #ax.append(plt.subplot(gs[i1, i2]))

        v1 = labs[labs['roi'] == r1].sort_values('plot')['i'].values
        v2 = labs[labs['roi'] == r1].sort_values('plot')['i'].values

        v1_labs = labs[labs['roi'] == r1].sort_values('plot')['layer'].to_list()
        v2_labs = labs[labs['roi'] == r1].sort_values('plot')['layer'].to_list()

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
        r2_list.append(r1)
        len_v1_list.append(len_v1)
        len_v2_list.append(len_v2)
        v1_labs_list.append(v1_labs)
        v2_labs_list.append(v2_labs)

def get_templates_for_clustering(path, rois=None, dist='pearson', plot=True):
    '''
    path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/dataframe.hcpl3_thalamic.preprocd'
    rois = ['L_Thalamus','L_V1']
    rois = ['L_V1' ,'L_V2','L_V3','L_V3A','L_V3B','L_V3CD','L_V4','L_V4t','L_MT','L_V6']
    rois = ['L_V1' ,'L_MT']
    rois = ['L_4', 'L_3b', 'L_3a', 'L_1', 'L_2']

    :param path:
    :param roi_name:
    :return:
    '''
    save_path = path.replace('dataframe','templates')

    if not os.path.exists(save_path):
        os.makedirs(save_path)


    labs = pd.read_pickle(glob(os.path.join(path,'*.pkl'))[0])
    a   = np.load(glob(os.path.join(path,'*.npy'))[0])

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

    rois_no_thal = [roi for roi in rois if 'Thalamus' not in roi]
    rois = rois_no_thal


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

    #triu = np.triu(np.ones(shape=(3,3), dtype=int),1)

    for i1 in range(len_rois):
        for i2 in range(i1, len_rois):
        #for i2 in range(len_rois):

            r1 = rois[i1]
            r2 = rois[i2]

            #if r1 == r2:
            #    continue

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
            o = o.flatten()
            o = scipy.stats.zscore(o)
            # get upper triangle
            #o[triu]

            o_pval = p[x,y]
            o_pval = o_pval.flatten()

            o_list.append(o)
            o_pval_list.append(o_pval)

            r1_list.append(r1)
            r2_list.append(r2)
            len_v1_list.append(len_v1)
            len_v2_list.append(len_v2)
            v1_labs_list.append(v1_labs)
            v2_labs_list.append(v2_labs)

    df = pd.DataFrame({'r1':r1_list, 'r2':r2_list})

    o_array = np.stack(o_list)
    o_pval_array = np.stack(o_pval_list)

    return o_array, o_pval_array, df


def get_edges_for_clustering(path, rois=None, dist='pearson', plot=True):
    '''
    path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/dataframe.hcpl3_thalamic.preprocd'
    rois = ['L_Thalamus','L_V1']
    rois = ['L_V1' ,'L_V2','L_V3','L_V3A','L_V3B','L_V3CD','L_V4','L_V4t','L_MT','L_V6']
    rois = ['L_V1' ,'L_MT']
    rois = ['L_4', 'L_3b', 'L_3a', 'L_1', 'L_2']

    :param path:
    :param roi_name:
    :return:
    '''
    save_path = path.replace('dataframe','templates')

    if not os.path.exists(save_path):
        os.makedirs(save_path)


    labs = pd.read_pickle(glob(os.path.join(path,'*.pkl'))[0])
    a   = np.load(glob(os.path.join(path,'*.npy'))[0])

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

    rois_no_thal = [roi for roi in rois if 'Thalamus' not in roi]
    rois = rois_no_thal


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

    #triu = np.triu(np.ones(shape=(3,3), dtype=int),1)

    for i1 in range(len_rois):
        for i2 in range(i1, len_rois):
            #for i2 in range(len_rois):

            r1 = rois[i1]
            r2 = rois[i2]

            if r1 == r2:
                continue

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
            o = o.flatten()
            o = scipy.stats.zscore(o)
            # get upper triangle
            #o[triu]

            o_pval = p[x,y]
            o_pval = o_pval.flatten()

            o_list.append(o)
            o_pval_list.append(o_pval)

            r1_list.append(r1)
            r2_list.append(r2)
            len_v1_list.append(len_v1)
            len_v2_list.append(len_v2)
            v1_labs_list.append(v1_labs)
            v2_labs_list.append(v2_labs)

    df = pd.DataFrame({'r1':r1_list, 'r2':r2_list})

    o_array = np.stack(o_list)
    o_pval_array = np.stack(o_pval_list)

    return o_array, o_pval_array, df


def get_nodes_for_clustering(path, rois=None, dist='pearson', plot=True):
    '''
    path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/dataframe.hcpl3_thalamic.preprocd'
    rois = ['L_Thalamus','L_V1']
    rois = ['L_V1' ,'L_V2','L_V3','L_V3A','L_V3B','L_V3CD','L_V4','L_V4t','L_MT','L_V6']
    rois = ['L_V1' ,'L_MT']
    rois = ['L_4', 'L_3b', 'L_3a', 'L_1', 'L_2']

    :param path:
    :param roi_name:
    :return:
    '''
    save_path = path.replace('dataframe','templates')

    if not os.path.exists(save_path):
        os.makedirs(save_path)


    labs = pd.read_pickle(glob(os.path.join(path,'*.pkl'))[0])
    a   = np.load(glob(os.path.join(path,'*.npy'))[0])

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

    rois_no_thal = [roi for roi in rois if 'Thalamus' not in roi]
    rois = rois_no_thal


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

    #triu = np.triu(np.ones(shape=(3,3), dtype=int),1)

    for i1 in range(len_rois):
        for i2 in range(i1, len_rois):
            #for i2 in range(len_rois):

            r1 = rois[i1]
            r2 = rois[i2]

            if r1 != r2:
                continue

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
            o = o.flatten()
            o = scipy.stats.zscore(o)
            # get upper triangle
            #o[triu]

            o_pval = p[x,y]
            o_pval = o_pval.flatten()

            o_list.append(o)
            o_pval_list.append(o_pval)

            r1_list.append(r1)
            r2_list.append(r2)
            len_v1_list.append(len_v1)
            len_v2_list.append(len_v2)
            v1_labs_list.append(v1_labs)
            v2_labs_list.append(v2_labs)

    df = pd.DataFrame({'r1':r1_list, 'r2':r2_list})

    o_array = np.stack(o_list)
    o_pval_array = np.stack(o_pval_list)

    return o_array, o_pval_array, df


def cluster2(o_array, df, path, dpi=400, size=(24,24)):

    save_path = path.replace('dataframe','plots')

    if not os.path.exists(save_path):
        os.makedirs(save_path)

    print("o_array shape: {}".format(o_array.shape))

    D,p = corrcoef(o_array)

    print("D shape: {}".format(D.shape))

    len_rois = D.shape[0]

    # Compute and plot dendrogram.
    fig = pylab.figure(figsize=size, dpi=dpi)
    axdendro = fig.add_axes([0.09,0.1,0.2,0.8])
    Y = sch.linkage(D, method='centroid')
    Z = sch.dendrogram(Y, orientation='right')

    index           = Z['leaves']
    labels          = [ '-'.join([df['r1'].iloc[l], df['r2'].iloc[l]]) for l in range(df.shape[0]) ]
    labels_reorg    = [ labels [x] for x in index ]

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


    #fig.savefig('dendrogram{}.png')

    if rois == None:
        plt.savefig(os.path.join(save_path,'dendrogram.ALL.jpeg'))
    else:
        plt.savefig(os.path.join(save_path,'dendrogram.'+'-'.join(rois)+'.jpeg'))
    plt.close()

    return Y,Z

def cluster(o_array, df):

    #X = D.iloc[:, [3,4]].values
    X = o_array

    # dendrogram = sch.dendrogram(sch.linkage(X, method  = "ward"))
    # plt.title('Dendrogram')
    # plt.xlabel('Customers')
    # plt.xticks(labels=)
    # plt.ylabel('Euclidean distances')
    # plt.show()
    linked = sch.linkage(X, 'ward')

    #labels = ["A", "B", "C", "D"]
    labels = [ '-'.join([df['r1'].iloc[l], df['r2'].iloc[l]]) for l in range(df.shape[0]) ]
    df['joined'] = labels
    p = len(labels)

    plt.figure(figsize=(14,12))
    plt.title('Hierarchical Clustering Dendrogram (truncated)', fontsize=20)
    plt.xlabel('ROI Templates', fontsize=16)
    plt.ylabel('distance', fontsize=16)

    # call dendrogram to get the returned dictionary
    # (plotting parameters can be ignored at this point)
    R = sch.dendrogram(
        linked,
        truncate_mode='lastp',  # show only the last p merged clusters
        p=p,  # show only the last p merged clusters
        no_plot=True,
    )

    print("values passed to leaf_label_func\nleaves : ", R["leaves"])

    # create a label dictionary
    temp = {R["leaves"][ii]: labels[ii] for ii in range(len(R["leaves"]))}
    def llf(xx):
        return "{}".format(temp[xx])

    ## This version gives you your label AND the count
    # temp = {R["leaves"][ii]:(labels[ii], R["ivl"][ii]) for ii in range(len(R["leaves"]))}
    # def llf(xx):
    #     return "{} - {}".format(*temp[xx])


    sch.dendrogram(
        linked,
        truncate_mode='lastp',  # show only the last p merged clusters
        p=p,  # show only the last p merged clusters
        leaf_label_func=llf,
        leaf_rotation=60.,
        leaf_font_size=8.,
        show_contracted=True,  # to get a distribution impression in truncated branches
    )
    plt.show()


    return

def plot_node_edge_clusters():
    import matplotlib.pyplot as plt
    import networkx as nx

    G = nx.cubical_graph()
    pos = nx.spring_layout(G)  # positions for all nodes

    # nodes
    options = {"node_size": 500, "alpha": 0.8}
    nx.draw_networkx_nodes(G, pos, nodelist=[0, 1, 2, 3], node_color="r", **options)
    nx.draw_networkx_nodes(G, pos, nodelist=[4, 5, 6, 7], node_color="b", **options)

    # edges
    nx.draw_networkx_edges(G, pos, width=1.0, alpha=0.5)
    nx.draw_networkx_edges(
        G,
        pos,
        edgelist=[(0, 1), (1, 2), (2, 3), (3, 0)],
        width=8,
        alpha=0.5,
        edge_color="r",
    )
    nx.draw_networkx_edges(
        G,
        pos,
        edgelist=[(4, 5), (5, 6), (6, 7), (7, 4)],
        width=8,
        alpha=0.5,
        edge_color="b",
    )


    # some math labels
    labels = {}
    labels[0] = r"$a$"
    labels[1] = r"$b$"
    labels[2] = r"$c$"
    labels[3] = r"$d$"
    labels[4] = r"$\alpha$"
    labels[5] = r"$\beta$"
    labels[6] = r"$\gamma$"
    labels[7] = r"$\delta$"
    nx.draw_networkx_labels(G, pos, labels, font_size=16)

    plt.axis("off")
    plt.show()
    return

def build_graph_plot(Y_edges,Z_edges,Y_nodes,Z_nodes):
    """
    This is unfinished but take the dendrograms for edges and node, cuts across the trees, and plots the
    membership in 3dplot.

    :param Y_edges:
    :param Z_edges:
    :param Y_nodes:
    :param Z_nodes:
    :return:
    """

    all_xyz_path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/rois.hcp.l3/all_xyz.txt'
    all_xyz = pd.read_csv(all_xyz_path, sep=' ', names=['roi','x','y','z'], index_col=False)
    all_xyz['roi_string'] = [ r.split('.')[1] for r in all_xyz['roi'] ]
    # if error look for asterisk at top of all_xyz.txt file



    edge_clusters = []
    clust = []
    roi1 = []
    roi2 = []
    roi1_coords = []
    roi2_coords = []
    num_edge_clusters = []
    num_node_clusters = []

    roi1_x = []
    roi1_y = []
    roi1_z = []
    roi2_x = []
    roi2_y = []
    roi2_z = []
    type = []

    for n_clust_edges in range(2,10):
        for n_clust_nodes in range(2,5):
            tree_edges = sch.cut_tree(Y_edges,n_clusters=n_clust_edges) # height=2)
            tree_nodes = sch.cut_tree(Y_nodes,n_clusters=n_clust_nodes) # height=2)

            for t in range(n_clust_edges):
                t_list = []
                for i in range(len(tree_edges)):
                    if tree_edges[i][:] == t:
                        c = t
                        r1 = df_edges.iloc[i].values[0]
                        r2 = df_edges.iloc[i].values[1]

                        r1_ind = all_xyz['roi_string'] == r1
                        r1_c = [ all_xyz['x'][r1_ind].values, all_xyz['y'][r1_ind].values, all_xyz['z'][r1_ind].values]

                        r2_ind = all_xyz['roi_string'] == r2
                        r2_c = [ all_xyz['x'][r2_ind].values, all_xyz['y'][r2_ind].values, all_xyz['z'][r2_ind].values]

                        #print(t, tree_edges[i][:], df_edges.iloc[i].values)

                        if r1 == r2:
                            type.append('node')
                        elif r1 != r2:
                            type.append('edge')

                        clust.append(c)
                        roi1.append(r1)
                        roi2.append(r2)

                        roi1_x.append(r1_c[0])
                        roi1_y.append(r1_c[1])
                        roi1_z.append(r1_c[2])
                        roi2_x.append(r2_c[0])
                        roi2_y.append(r2_c[1])
                        roi2_z.append(r2_c[2])


                        num_edge_clusters.append(n_clust_edges)
                        num_node_clusters.append(n_clust_nodes)

                        #print(c,r1,r2,roi1_x,roi1_y,roi1_z,roi2_x,roi2_y,roi2_z,n_clust_edges,n_clust_nodes)
    # d = {'clust': clust,'roi1': roi1,'roi2': roi2,
    #      'roi1_x': roi1_x, 'roi1_y': roi1_y, 'roi1_z': roi1_z,
    #      'roi2_x': roi2_x, 'roi2_y':roi2_y, 'roi2_z': roi2_z,
    #      'n_clust_edges': num_edge_clusters,
    #      'n_clust_nodes': num_node_clusters}

    clusts2plot = pd.DataFrame() #.from_dict(d)

    clusts2plot['clust'] = clust
    clusts2plot['roi1'] = roi1
    clusts2plot['roi2'] = roi2
    clusts2plot['roi1_x'] = roi1_x
    clusts2plot['roi1_y'] = roi1_y
    clusts2plot['roi1_z'] = roi1_z
    clusts2plot['roi2_x'] = roi2_x
    clusts2plot['roi2_y'] = roi2_y
    clusts2plot['roi2_z'] = roi2_z
    clusts2plot['n_clust_edges'] = num_edge_clusters
    clusts2plot['n_clust_nodes'] = num_node_clusters
    clusts2plot['type'] = type


    ind_nodes = (clusts2plot['n_clust_edges'] == 5) & (clusts2plot['n_clust_nodes'] == 2) & (clusts2plot['type'] == 'node')
    ind_edges = (clusts2plot['n_clust_edges'] == 5) & (clusts2plot['n_clust_nodes'] == 2) & (clusts2plot['type'] == 'edges')

    clusts2plot.loc[ind_nodes]

    # get averaged templates
    # get_all_xyz.sh $rois_hcpl3

    # get D3 viewer

    # import matplotlib.pyplot as plt
    # from mpl_toolkits.mplot3d import Axes3D
    #
    # all_xyz_path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/rois.hcp.l3/all_xyz.txt'
    # all_xyz = pd.read_csv(all_xyz_path, sep=' ', names=['roi','x','y','z'], index_col=False)
    #
    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')
    ax.scatter(all_xyz['x'], all_xyz['y'], all_xyz['z'])
    plt.show()



if __name__ == "__main__":


    parser = argparse.ArgumentParser(description='generate layer profile')
    parser.add_argument('--path', type=str)
    parser.add_argument('--rois', nargs='+', default=None)
    parser.add_argument('--plot', type=bool, default=True)
    parser.add_argument('--quick', action='store_true')
    args = parser.parse_args()


    path = args.path
    rois = args.rois
    quick = args.quick
    plot = args.plot

    print("\n Creating Plot  \n"
          "   ROI:{}  \n"
          "   path:{} \n".format(rois, path))

    '''
    path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/dataframe.hcpl3_thalamic.preprocd' \
    rois = ['L_V1' ,'L_V2','L_V3','L_V3A','L_V3B','L_V3CD','L_V4','L_V4t','L_MT','L_V6']

    
    python $tools_dir/build_hierarchical_agglomerative_cluster.py --path $layer4EPI/dataframe.hcpl3_thalamic.preprocd \
    --rois L_Thalamus L_V1 L_V2 L_V3 L_V3A L_V3B L_V3CD L_V4 L_V4t L_V6 
    
    '''


    #o_array, o_pval_array, df = get_templates_for_clustering(path, rois=rois)
    #Y,Z = cluster2(o_array, df)
    # path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/dataframe.hcpl3_thalamic.preprocd'

    # todo: nameing plots
    ######################
    o_array_edges, o_pval_array_edges, df_edges = get_edges_for_clustering(path, rois=rois)
    Y_edges,Z_edges = cluster2(o_array_edges, df_edges, path)
    ######################
    o_array_nodes, o_pval_array_nodes, df_nodes = get_nodes_for_clustering(path, rois=rois)
    Y_nodes,Z_nodes = cluster2(o_array_nodes, df_nodes, path)

    """
    ## WHOLE BRAIN - rois=None
    o_array_edges, o_pval_array_edges, df_edges = get_edges_for_clustering(path, rois=None)
    Y_edges,Z_edges = cluster2(o_array_edges, df_edges, path, dpi=300, size=(20,20))
    ######################
    o_array_nodes, o_pval_array_nodes, df_nodes = get_nodes_for_clustering(path, rois=None)
    Y_nodes,Z_nodes = cluster2(o_array_nodes, df_nodes, path, dpi=300, size=(20,20))
    """

    ##### BUILD GRAPH #############################################
    # build 3dgraph with colored nodes and edges based on clustering membership
    # incomplete needs work
    build_graph_plot(Y_edges,Z_edges,Y_nodes,Z_nodes)

