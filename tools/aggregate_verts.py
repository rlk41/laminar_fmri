#!/usr/bin/env python


import argparse 
import time 
from glob import glob 
import pickle 
import numpy as np 
import scipy.stats as sp 
import os 
from matplotlib import pyplot as plt 
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


def mean_se_coefs_by_vert(verts, coefs):

    verts_unq = np.unique(verts) 

    c_vert = []
    c_aves = [] 
    c_sems = []
    
    for unq_vert in verts_unq: 

        ind_vert    = np.where(np.array(verts) == unq_vert )

        c           = coefs[ind_vert]
        c_ave       = np.mean(c, 0)
        c_sem       = sp.sem(c, 0)

        c_vert.append(unq_vert)
        c_aves.append(c_ave)
        c_sems.append(c_sem)

    return c_vert, c_aves, c_sems

def mean_se_coefs_all_verts(verts, coefs):

    verts_unq = np.unique(verts) 

    c_vert = []
    c_aves = [] 
    c_sems = []
    

    c           = coefs
    c_ave       = np.mean(c, 0)
    c_sem       = sp.sem(c, 0)

    c_aves.append(c_ave)
    c_sems.append(c_sem)

    return c_aves, c_sems


def gather_pkls(pkls): 

    i_pkls          = []
    verts           = []
    coef_LGNMTs     = []
    coef_MTLGNs     = []
    coef_RV1s       = []
    pkl_name        = [] 

    i_pkl = 0 

    for pkl in pkls: 
        with open(pkl, 'rb') as p: 
            completed_jobs = pickle.load(p)

            for cj in completed_jobs:
                # cj = completed_jobs[0]
                vert        = cj['cs'][0]
                # coef_LGNMT  = cj['coefs']['L_LGN - L_MT']
                # coef_MTLGN  = cj['coefs']['L_MT - L_LGN']
                # coef_RV1    = cj['coefs']['R_V1']
                
                coef_LGNMT  = cj['coefs_zscore']['L_LGN - L_MT']
                coef_MTLGN  = cj['coefs_zscore']['L_MT - L_LGN']
                coef_RV1    = cj['coefs_zscore']['R_V1']



                i_pkls.append(i_pkl)
                pkl_name.append(pkl)

                verts.append(vert)
                coef_LGNMTs.append(coef_LGNMT)
                coef_MTLGNs.append(coef_MTLGN)
                coef_RV1s.append(coef_RV1)

                i_pkl += 1

    verts       = np.array(verts) 
    verts_unq   = np.unique(verts)

    coef_LGNMTs = np.array(coef_LGNMTs)
    coef_MTLGNs = np.array(coef_MTLGNs)
    coef_RV1s   = np.array(coef_RV1s)

    i_pkls = np.array(i_pkls)
    pkl_name

    return verts, coef_LGNMTs, coef_MTLGNs, coef_RV1s, i_pkls, pkl_name


def plot_average_over_roi(verts, coef, filename):


        #c_aves, c_sems = mean_se_coefs_all_verts(verts, coef)

        fig, axs = plt.subplots(ncols=1, nrows=1, 
        sharex=True, figsize=(3,3))
        

        m   = np.mean(coef, 0)
        se  = sp.sem(coef, 0)

        x   = range(len(m))

        axs.errorbar(x, m, yerr=se, fmt='-o') #[upper, lower]
        #axs[axs_i].set_title(xts[axs_i])

        axs.set_xticks([0, len(m)])
        axs.set_xticklabels(['CSF','WM'])

        basedir = '/'.join(filename.split('/')[0:-1])

        os.makedirs(basedir, exist_ok=True) 
        #plt.savefig('{}/vert_ave_all_LGNMTs.png'.format(plot_dir))
        plt.savefig(filename)
        plt.close()





def main(pkl_dir):

    '''
    pkl_dir="/data/kleinrl/pkls_sPCA-1_cPCA-0"
    /data/kleinrl/pkls_sPCA-1_cPCA-0/
    '''

    pkls = glob(pkl_dir + "/completed_jobs*")

    print("{} pkls found!".format(len(pkls)))


    verts, coef_LGNMTs, coef_MTLGNs, coef_RV1s, i_pkls, pkl_name = gather_pkls(pkls)


    # averaged per ROIs across subjects 
    filename = pkl_dir+"/plots/ave_roi_across_subs/LGNMT.png"
    plot_average_over_roi(verts, coef_LGNMTs, filename)

    filename = pkl_dir+"/plots/ave_roi_across_subs/MTLGN.png"
    plot_average_over_roi(verts, coef_MTLGNs, filename)

    filename = pkl_dir+"/plots/ave_roi_across_subs/RV1.png"
    plot_average_over_roi(verts, coef_RV1s, filename)


    # average per vert across subjects 
    c_verts_LGNMT, c_aves_LGNMT, c_sems_LGNMT   = mean_se_coefs_by_vert(verts, coef_LGNMTs)

    c_verts_MTLGN, c_aves_MTLGN, c_sems_MTLGN   = mean_se_coefs_by_vert(verts, coef_MTLGNs)

    c_verts_RV1, c_aves_RV1, c_sems_RV1         = mean_se_coefs_by_vert(verts, coef_RV1s)

    len_verts = len(c_verts_LGNMT)


    # template 
    for v_i in range(len_verts):


        fig, axs = plt.subplots(ncols=3, nrows=1, sharex=True, figsize=(7,3))


        vert    = c_verts_LGNMT[v_i]
        m       = c_aves_LGNMT[v_i]
        se      = c_sems_LGNMT[v_i]
        x       = range(len(m))

        #axs[0].errorbar(x, m, yerr=se, fmt='-o') #[upper, lower]
        axs[0].plot(x,m)
        axs[0].fill_between(x, m-se, m+se, alpha=0.5)
        axs[0].set_xticks([0, len(m)])
        axs[0].set_xticklabels(['CSF','WM'])
        axs[0].set_title('LGN (feedforward)')

        vert    = c_verts_MTLGN[v_i]
        m       = c_aves_MTLGN[v_i]
        se      = c_sems_MTLGN[v_i]
        x       = range(len(m))

        #axs[1].errorbar(x, m, yerr=se, fmt='-o') #[upper, lower]
        axs[1].plot(x,m)
        axs[1].fill_between(x, m-se, m+se, alpha=0.5)
        axs[1].set_xticks([0, len(m)])
        axs[1].set_xticklabels(['CSF','WM'])
        axs[1].set_title('MT (feedback)')

        vert    = c_verts_RV1[v_i]
        m       = c_aves_RV1[v_i]
        se      = c_sems_RV1[v_i]
        x       = range(len(m))

        #axs[2].errorbar(x, m, yerr=se, fmt='-o') #[upper, lower]
        axs[2].plot(x,m)
        axs[2].fill_between(x, m-se, m+se, alpha=0.5)
        axs[2].set_xticks([0, len(m)])
        axs[2].set_xticklabels(['CSF','WM'])
        axs[2].set_title('RV1 (control)')

        plot_dir = pkl_dir+"/plots/averaged_vert_across_subjects"
        os.makedirs(plot_dir, exist_ok=True) 

        plt.tight_layout()
        plt.savefig('{}/vert_{:04d}.png'.format(plot_dir,v_i))
        plt.close()



    # cluster verts 




    D,p = corrcoef(coef_LGNMTs)

    # print("D shape: {}".format(D.shape))

    # len_rois = D.shape[0]

    # # Compute and plot dendrogram.
    # fig         = pylab.figure(figsize=size, dpi=dpi)
    # axdendro    = fig.add_axes([0.09,0.1,0.2,0.8])
    # Y           = sch.linkage(D, method='centroid')
    # Z           = sch.dendrogram(Y, orientation='right')

    # index           = Z['leaves']
    # labels          = [ '-'.join([df['r1'].iloc[l], df['r2'].iloc[l]]) for l in range(df.shape[0]) ]
    # labels_reorg    = [ labels [x] for x in index ]

    # axdendro.set_yticklabels(labels_reorg)

    # # Plot distance matrix.
    # axmatrix = fig.add_axes([0.3,0.1,0.6,0.8])

    # D = D[index,:]
    # D = D[:,index]

    # im = axmatrix.matshow(D, aspect='auto', origin='lower')
    # axmatrix.set_xticks([])
    # axmatrix.set_yticks([])

    # # Plot colorbar.
    # axcolor = fig.add_axes([0.91,0.1,0.02,0.8])
    # pylab.colorbar(im, cax=axcolor)

    # # Display and save figure.
    # fig.show()


    #fig.savefig('dendrogram{}.png')

    # if rois == None:
    #     plt.savefig(os.path.join(save_path,'dendrogram.ALL.jpeg'))
    # else:
    #     plt.savefig(os.path.join(save_path,'dendrogram.'+'-'.join(rois)+'.jpeg'))
    # plt.close()

    # return Y,Z

    # ica 











    # # plot all verts withing subject 
    # plot_each_vert = False
    # if plot_each_vert: 
    #     fig, axs = plt.subplots(ncols=10, nrows=10, 
    #     sharex=True, figsize=(10,10))
        
    #     axs_i = 0 
    #     for c in range(0,100): #c_verts.shape[0]):
    #         # c = 1

    #         fig, axs = plt.subplots(ncols=1, nrows=1, 
    #         sharex=True, figsize=(1,1))
            

    #         m   = c_aves[c]#, :]
    #         se  = c_sems[c]#, :]
    #         x   = range(len(m))

    #         axs.errorbar(x, m, yerr=se, fmt='-o') #[upper, lower]
    #         #axs[axs_i].set_title(xts[axs_i])

    #         axs.set_xticks([0, len(m)])
    #         axs.set_xticklabels(['CSF','WM'])

    #         axs_i += 1 

    #         plot_dir = pkl_dir+"/plots/averaged_verts_across_subject"
            
    #         os.makedirs(plot_dir, exist_ok=True) 
    #         plt.savefig('{}/vert_{:04d}.png'.format(plot_dir,c))
    #         plt.close()

    # # plot average





    # plot_ave_verts = False
    # if plot_ave_verts: 
    #     fig, axs = plt.subplots(ncols=3, nrows=1, 
    #     sharex=True, figsize=(2,5))
        
    #     axs_i = 0 
    #     for c in range(0,100): #c_verts.shape[0]):
    #         # c = 1

    #         fig, axs = plt.subplots(ncols=1, nrows=1, 
    #         sharex=True, figsize=(1,1))
            

    #         m   = c_aves[c]#, :]
    #         se  = c_sems[c]#, :]
    #         x   = range(len(m))

    #         axs.errorbar(x, m, yerr=se, fmt='-o') #[upper, lower]
    #         #axs[axs_i].set_title(xts[axs_i])

    #         axs.set_xticks([0, len(m)])
    #         axs.set_xticklabels(['CSF','WM'])

    #         axs_i += 1 

    #         plot_dir = pkl_dir+"/plots/averaged_verts"
            
    #         os.makedirs(plot_dir, exist_ok=True) 
    #         plt.savefig('{}/vert_{:04d}.png'.format(plot_dir,c))
    #         plt.close()




    # fig, axs = plt.subplots(ncols=10, nrows=10, 
    # sharex=True, figsize=(10,10))
    
    # axs_i = 0 
    # for c in range(c_verts.shape[0]):
    #     #c = 1
    #     m   = c_aves[c]#, :]
    #     se  = c_sems[c]#, :]
    #     x   = range(len(m))

    #     axs[axs_i].errorbar(x, m, yerr=se, fmt='-o') #[upper, lower]
    #     #axs[axs_i].set_title(xts[axs_i])

    #     axs[axs_i].set_xticks([0, len(m)])
    #     axs[axs_i].set_xticklabels(['CSF','WM'])

    #     axs_i += 1 

    #     plot_dir = "/data/kleinrl/plots/averaged_verts"
        
    #     os.makedirs(plot_dir, exist_ok=True) 
    #     plt.savefig('{}/vert_{}.png'.format(plot_dir,c))
    #     plt.close()


    return 



if __name__ == "__main__":

    '''
    aggregate_verts.py --pkl_dir /data/kleinrl/pkls/
    
    pkl_dir='/data/kleinrl/pkls/'
    '''

    parser = argparse.ArgumentParser(description='regressLayers')
    parser.add_argument('--pkl_dir', type=str)


    args = parser.parse_args()

    pkl_dir  = args.pkl_dir

    start = time.time() 
    print('START time: {}'.format(start) )
    print("   ")
    print('pkl_dir: {}'.format(pkl_dir))


    main(pkl_dir)



    end = time.time()
    print(end)
    print("END time: {}".format(end - start))





# #!/bin/bash 
# import argparse 
# import time 
# from glob import glob 
# import pickle 
# import numpy as np 
# import scipy.stats as sp 
# import os 
# from matplotlib import pyplot as plt 


# def mean_se_coefs_by_vert(verts, coefs):

#     verts_unq = np.unique(verts) 

#     c_vert = []
#     c_aves = [] 
#     c_sems = []
    
#     for unq_vert in verts_unq: 

#         ind_vert    = np.where(np.array(verts) == unq_vert )

#         c           = coefs[ind_vert]
#         c_ave       = np.mean(c, 0)
#         c_sem       = sp.sem(c, 0)

#         c_vert.append(unq_vert)
#         c_aves.append(c_ave)
#         c_sems.append(c_sem)

#     return c_vert, c_aves, c_sems

# def main(pkl_dir):

#     i_pkls          = []
#     verts        = []
#     coef_LGNMTs  = []
#     coef_MTLGNs  = []
#     coef_RV1s    = []

#     pkls = glob(pkl_dir + "/completed_jobs*")

#     i_pkl = 0 

#     for pkl in pkls[0:10]: 
#         with open(pkl, 'rb') as p: 
#             completed_jobs = pickle.load(p)

#             for cj in completed_jobs:
#                 # cj = completed_jobs[0]
#                 vert        = cj['cs'][0]
#                 coef_LGNMT  = cj['coefs']['L_LGN - L_MT']
#                 coef_MTLGN  = cj['coefs']['L_MT - L_LGN']
#                 coef_RV1    = cj['coefs']['R_V1']

#                 i_pkls.append(i_pkl)

#                 verts.append(vert)
#                 coef_LGNMTs.append(coef_LGNMT)
#                 coef_MTLGNs.append(coef_MTLGN)
#                 coef_RV1s.append(coef_RV1)

#                 i_pkl += 1

#     verts       = np.array(verts) 
#     verts_unq   = np.unique(verts)

#     coef_LGNMTs = np.array(coef_LGNMTs)
#     coef_MTLGNs = np.array(coef_MTLGNs)
#     coef_RV1s   = np.array(coef_RV1s)



#     c_verts, c_aves, c_sems = mean_se_coefs_by_vert(verts, coef_LGNMTs)

#     #V1_ave




#     fig, axs = plt.subplots(ncols=10, nrows=10, 
#     sharex=True, figsize=(10,10))
    
#     axs_i = 0 
#     for c in range(0,100): #c_verts.shape[0]):
#         # c = 1

#         fig, axs = plt.subplots(ncols=1, nrows=1, 
#         sharex=True, figsize=(1,1))
        

#         m   = c_aves[c]#, :]
#         se  = c_sems[c]#, :]
#         x   = range(len(m))

#         axs.errorbar(x, m, yerr=se, fmt='-o') #[upper, lower]
#         #axs[axs_i].set_title(xts[axs_i])

#         axs.set_xticks([0, len(m)])
#         axs.set_xticklabels(['CSF','WM'])

#         axs_i += 1 

#         plot_dir = "/data/kleinrl/plots/averaged_verts"
        
#         os.makedirs(plot_dir, exist_ok=True) 
#         plt.savefig('{}/vert_{:04d}.png'.format(plot_dir,c))
#         plt.close()





#     # fig, axs = plt.subplots(ncols=10, nrows=10, 
#     # sharex=True, figsize=(10,10))
    
#     # axs_i = 0 
#     # for c in range(c_verts.shape[0]):
#     #     #c = 1
#     #     m   = c_aves[c]#, :]
#     #     se  = c_sems[c]#, :]
#     #     x   = range(len(m))

#     #     axs[axs_i].errorbar(x, m, yerr=se, fmt='-o') #[upper, lower]
#     #     #axs[axs_i].set_title(xts[axs_i])

#     #     axs[axs_i].set_xticks([0, len(m)])
#     #     axs[axs_i].set_xticklabels(['CSF','WM'])

#     #     axs_i += 1 

#     #     plot_dir = "/data/kleinrl/plots/averaged_verts"
        
#     #     os.makedirs(plot_dir, exist_ok=True) 
#     #     plt.savefig('{}/vert_{}.png'.format(plot_dir,c))
#     #     plt.close()


#     return 



# if __name__ == "__main__":

#     '''
#     aggregate_verts.py --pkl_dir /data/kleinrl/pkls/
    
#     '''

#     parser = argparse.ArgumentParser(description='regressLayers')
#     parser.add_argument('--pkl_dir', type=str)


#     args = parser.parse_args()

#     pkl_dir  = args.pkl_dir

#     start = time.time() 
#     print('START time: {}'.format(start) )
#     print("   ")
#     print('pkl_dir: {}'.format(pkl_dir))


#     main(pkl_dir)



#     end = time.time()
#     print(end)
#     print("END time: {}".format(end - start))



