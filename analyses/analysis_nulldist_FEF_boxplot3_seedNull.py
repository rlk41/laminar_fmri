#!/usr/bin/env python

# from ftplib import parse227
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
import matplotlib.pyplot as plt 
import time
import pandas as pd 

import glob 
import scipy 

from matplotlib.pylab import plot, boxplot, show, savefig, xlim, figure, \
                ylim, legend, setp, axes




def get_plots(k, fwhm=7): 

    '''
    fwhm=7
    k = 'L_7PL'
    '''


    plot_dir="/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_FEF/plots"
    base_dir="/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_FEF"
    base_dir2="/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_single"
    LUT="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/HCPMMP1_LUT_ordered_RS.txt"

    lut = pd.read_csv(LUT, delimiter=' ')

    print('load lut')


    k_id = int(lut[lut['Lookup'] == k]['#'].values[0])

    print("{} {}".format(k, k_id))

    columns             = "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/columns/columns_ev_30000_borders.nii"
    parc                = "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/multiAtlasTT/hcp-mmp-b/hcp-mmp-b_rmap.scaled2x.nii.gz"
    layers              = "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/grow_leaky_loituma/equi_volume_layers_n10.nii"
    
    nulls_3d            = glob.glob(base_dir2+"/fsl_feat_*ALL/mean/inv_pe1.fwhm{}.nii.gz".format(fwhm))
    feat_3d             = base_dir+"/fsl_feat_1010.L_FEF_pca10/mean/inv_pe1.fwhm{}.nii.gz".format(fwhm) 

    seed                = feat_3d.split('/')[-3].split('.')[-1].rstrip('_pca10')
    target              = k 

    img_parc            = nib.load(parc)
    img_col             = nib.load(columns)
    img_lay             = nib.load(layers)

    data_parc           = img_parc.get_fdata()
    data_columns        = img_col.get_fdata()
    data_layers         = img_lay.get_fdata()

    ind_roi     = np.where(data_parc == k_id )

    unq_roi_col = np.unique(data_columns[ind_roi]) 
    unq_roi_col = [ uc for uc in unq_roi_col if uc != 0 ]

    unq_layers  = np.flip(np.unique(data_layers))[:-1]

    print("unique columns: {}".format(len(unq_roi_col)))


    for uc in unq_roi_col: 

        # uc = unq_roi_col[0]
        #ind_col = np.where(data_columns == uc)
        ind_col = data_columns == uc

        uc      = int(uc) 


        fig = plt.figure()
        ax = fig.add_axes([0.1, 0.1, 0.8, 0.8]) # main axes

        null_layer_data = [ [] for lc in range(0, int(np.max(unq_layers))+1 ) ]
        for null in nulls_3d: 
            img_null  = nib.load(null)
            data_null = img_null.get_fdata()


            for lc in unq_layers: 
                ind_lay = data_layers == lc 
                ind_both = np.where( ind_lay & ind_col )

                null_layer_data[int(lc)].append( data_null[ ind_both ] )


        mean_null_layer_data = [ [] for lc in range(0, int(np.max(unq_layers))+1 ) ]
        for g in range(1, len(null_layer_data)): 
            mean_null_layer_data[g] = np.mean(null_layer_data[g], axis=0).flatten().tolist()
            null_layer_data[g]      = np.concatenate(null_layer_data[g]).flatten().tolist()



        img_feat  = nib.load(feat_3d)
        data_feat = img_feat.get_fdata()

        emp_layer_data = [ [] for lc in range(0, int(np.max(unq_layers))+1 ) ]


        for lc in unq_layers: 
            ind_lay = data_layers == lc 
            ind_both = np.where( ind_lay & ind_col )

            emp_layer_data[int(lc)].append( data_feat[ ind_both ] )


        for g in range(1, len(emp_layer_data)): 
            emp_layer_data[g] = np.concatenate(emp_layer_data[g]).flatten().tolist()


        for g in range(1, len(null_layer_data)): 
            if null_layer_data[g] == []: 
                null_layer_data[g] = [0]
        for g in range(1, len(emp_layer_data)): 
            if emp_layer_data[g] == []: 
                emp_layer_data[g] = [0] 

        colors = ['blue','green','red']




        fig = figure()
        ax = axes()

        bon_corr = 10 
        p_thresh = 0.05 

        y_max = 0 
        y_min = 0 

        for j in range(1, len(null_layer_data)):
            start = ((j-1)*3) + (j-1) + 1
            g, p1, p2, p3 = j, start, start+1, start+2 

            for npm in [null_layer_data[g], mean_null_layer_data[g], emp_layer_data[g]]: 
                try: 
                    npm_max = np.max(npm)
                    if npm_max > y_max: 
                        y_max = npm_max 

                    npm_min = np.min(npm)
                    if npm_min < y_min: 
                        y_min = npm_min 
                    print(npm_min, npm_max )
                except: pass

        y_max_annot, y_min_annot =  y_max*1.25, y_min*1.1
        y_min_plot, y_max_plot = y_min-(np.abs(y_min)*.4), y_max*1.4
        
        for j in range(1, len(null_layer_data)):
            start           = ((j-1)*3) + (j-1) + 1
            g, p1, p2, p3   = j, start, start+1, start+2 
            end             = p3

            bp = ax.boxplot([null_layer_data[g], mean_null_layer_data[g], emp_layer_data[g]], positions = [p1,p2,p3], widths = 0.6)
            for patch, color in zip(bp['boxes'], colors):
                patch.set(color=color)

            try:
                w = scipy.stats.kruskal(emp_layer_data[g], null_layer_data[g])
                if w.pvalue < p_thresh: 
                    plt.annotate('* {0:.1E}'.format(w.pvalue), xy=(p3, y_max_annot ), color='blue', fontsize=7)
                elif w.pvalue < p_thresh/bon_corr: 
                    plt.annotate('** {0:.1E}'.format(w.pvalue), xy=(p3, y_max_annot ), color='blue', fontsize=7)
                del w 
            except: pass 
            
            try:
                w = scipy.stats.wilcoxon(emp_layer_data[g], y=mean_null_layer_data[g], alternative='two-sided')
                if w.pvalue < p_thresh: 
                    plt.annotate('* {0:.1E}'.format(w.pvalue), xy=(p3, y_max_annot*.9), color='green', fontsize=7)
                elif w.pvalue < p_thresh/bon_corr: 
                    plt.annotate('** {0:.1E}'.format(w.pvalue), xy=(p3, y_max_annot*.9), color='green', fontsize=7)

                del w 
            except: pass 


            plt.annotate('{}'.format(len(mean_null_layer_data[g])), xy=(p2, y_min_annot), color='green', fontsize=7)
            plt.annotate('{}'.format(len(null_layer_data[g])), xy=(p1, y_min_annot*.95), color='blue', fontsize=7)
            plt.annotate('{}'.format(len(emp_layer_data[g])), xy=(p1, y_min_annot*.9), color='red', fontsize=7)

        ylim(y_min_plot, y_max_plot)

        ax.set_xticks([1, end])
        ax.set_xticklabels(['CSF', 'WM'])

        hB, = plot([1,1],'b-')
        hG, = plot([1,1],'g-')
        hR, = plot([1,1],'r-')
        legend((hB, hG, hR),('seedNULL', 'seedNULL_mean','VASO'), loc='lower right')
        hB.set_visible(False)
        hG.set_visible(False)
        hR.set_visible(False)


        tit = "seed:{} target:{}-{} (fwhm{})".format(seed, target, uc, fwhm) 
        plt.title(tit )
        plt.ylabel('beta weights')

        save_tit=tit.replace(':','-').replace(' ','_').replace('(','').replace(')','')

        plt.savefig(plot_dir+"/{}.seedNull.box6.png".format(save_tit))

        plt.close()

        print("plot saved -- {} {}".format(k, uc))



if __name__ == "__main__":


    parser = argparse.ArgumentParser(description='generate layer profile')
    parser.add_argument('--k', type=str)
    parser.add_argument('--fwhm', type=int)

    args = parser.parse_args()

    k = args.k 
    fwhm = args.fwhm


    get_plots(k, fwhm=fwhm)


'''
rois=(L_FEF L_LIPv L_VIP L_V4t R_V4 R_V2 R_V3 L_V1 L_MST L_MT
    L_TF L_TE1a L_TE1p L_TE2a L_TE2p L_FST)

for r in ${rois[@]}; do 
    echo "python analysis_nullDist_FEF.py --k $r " >> swarm.plots
done 

'''


            # # sign rank 
            # try:
            #     w = scipy.stats.kruskal(emp_layer_data[g], null_layer_data[g])
            #     if w.pvalue < p_thresh: 
            #     #     plt.annotate('* {0:.1E}'.format(w.pvalue), xy=(p3, np.max(emp_layer_data[g])*1.1 ), color='blue', fontsize=5)
            #     # elif w.pvalue < p_thresh/bon_corr: 
            #     #     plt.annotate('** {0:.1E}'.format(w.pvalue), xy=(p3, np.max(emp_layer_data[g])*1.1 ), color='blue', fontsize=5)
            #         plt.annotate('* {0:.1E}'.format(w.pvalue), xy=(p3, y_max_annot ), color='blue', fontsize=7)
            #     elif w.pvalue < p_thresh/bon_corr: 
            #         plt.annotate('** {0:.1E}'.format(w.pvalue), xy=(p3, y_max_annot ), color='blue', fontsize=7)



            # except: 
            #     pass 

            # # equal sample 
            # try:
            #     w = scipy.stats.wilcoxon(emp_layer_data[g], y=mean_null_layer_data[g], alternative='two-sided')
            #     if w.pvalue < p_thresh: 
            #     #     plt.annotate('* {0:.1E}'.format(w.pvalue), xy=(p3, np.max(emp_layer_data[g])*1.3), color='green', fontsize=5)
            #     # elif w.pvalue < p_thresh/bon_corr: 
            #     #     plt.annotate('** {0:.1E}'.format(w.pvalue), xy=(p3, np.max(emp_layer_data[g])*1.1 ), color='blue', fontsize=5)
            #         plt.annotate('* {0:.1E}'.format(w.pvalue), xy=(p3, y_max_annot*.9), color='green', fontsize=7)
            #     elif w.pvalue < p_thresh/bon_corr: 
            #         plt.annotate('** {0:.1E}'.format(w.pvalue), xy=(p3, y_max_annot*.9), color='green', fontsize=7)
