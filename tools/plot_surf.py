#!/usr/bin/env python

# export DISPLAY='localhost:10.0'
# failed to laod driver swrast 

'''
libGL error: No matching fbConfigs or visuals found
libGL error: failed to load driver: swrast
********************************************************************************
WARNING: Imported VTK version (9.0) does not match the one used
         to build the TVTK classes (8.2). This may cause problems.
         Please rebuild TVTK.
********************************************************************************
'''
import os

#os.environ['DISPLAY'] = 'localhost:10.0'
#print(os.environ['DISPLAY'])


from surfer import Brain, project_volume_data
import argparse 

#import mne

#print(__doc__)
#export QT_API=pyqt
#export ETS_TOOLKIT=qt4

def plot_surf(subid, vol=False, surf='inflated', 
        views=None, seed=None, outfile=None): 
    
    if views == None: 
        views=['frontal','lat','caudal','med']

    #views=['caudal']
    
    brain = Brain(subid, hemi="split", surf=surf, views=views, 
    background='black', offscreen=True, size=(8000,2400), cortex='bone')
    

    vol_lh = project_volume_data(vol, 'lh', 
        subject_id=subid, smooth_fwhm=1, projsum='max', projarg=[0,1,.1]) 
    vol_rh = project_volume_data(vol, 'rh', 
        subject_id=subid, smooth_fwhm=1, projsum='max',  projarg=[0,1,.1]) 

    brain.add_data(vol_lh, center=0, hemi='lh', transparent=True)#=1)
    brain.add_data(vol_rh, center=0, hemi='rh', transparent=True)#alpha=1)

    if seed != None: 
        print("\n\nPLOTTING SEED ROI\n\n")
        seed_lh = project_volume_data(seed, 'lh', 
            subject_id=subid, smooth_fwhm=1, projsum='max', projarg=[0,1,.1]) 
        seed_rh = project_volume_data(seed, 'rh', 
            subject_id=subid, smooth_fwhm=1, projsum='max',  projarg=[0,1,.1]) 

        brain.add_data(seed_lh, center=0, hemi='lh', transparent=True, 
            colorbar=False, colormap=['HotPink'])#=1)
        brain.add_data(seed_rh, center=0, hemi='rh', transparent=True, 
            colorbar=False, colormap=['HotPink'])#alpha=1)


    if outfile == None:
        outfile=vol.rstrip('.nii')+'.png'
    print('SAVING TO: {}'.format(outfile))
    brain.save_image(outfile)



    #input("Press Enter to continue...")


    # subjects_dir = mne.datasets.sample.data_path() + '/subjects'
    # mne.datasets.fetch_hcp_mmp_parcellation(subjects_dir=subjects_dir,
    #                                         verbose=True)

    # mne.datasets.fetch_aparc_sub_parcellation(subjects_dir=subjects_dir,
    #                                           verbose=True)

    # labels = mne.read_labels_from_annot(
    #     'fsaverage', 'HCPMMP1', 'lh', subjects_dir=subjects_dir)

    # brain = Brain('fsaverage', 'lh', 'inflated', subjects_dir=subjects_dir,
    #               cortex='low_contrast', background='white', size=(800, 600))
    # brain.add_annotation('HCPMMP1')
    # aud_label = [label for label in labels if label.name == 'L_A1_ROI-lh'][0]
    # brain.add_label(aud_label, borders=False)











if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument('--subid')
    parser.add_argument('--vol')
    parser.add_argument('--surf', default='inflated')
    parser.add_argument('--outfile', default=None)
    parser.add_argument('--views', default=None)

    parser.add_argument('--seed', default=None)

    args = parser.parse_args()

    #os.environ['SUBJECTS_DIR'] = 

    '''
    subid='sub-01_ses-06_task-movie_run-05_VASO'
    '''

    # vol=('/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/' 
    # 'bandettini/ds003216-download/' 
    # 'sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/'
    # 'sub-01_ses-01_run-01_T1w/'
    # 'LAYNII_sub-01_ses-06_task-movie_run-05_VASO/analysis.c10k.l3.SEED2SEED/'
    # '8209.Right-LGN.SEED2SEED.ff.nii')
    

    subid = args.subid 
    vol = args.vol
    surf = args.surf 
    views = args.views 

    seed = args.seed
    outfile = args.outfile

    print("subid: {} \n\nvol: {}\n\n".format(subid, vol))

    #subid='fsaverage'
    #subid='sub-01_ses-06_task-movie_run-05_VASO'

    plot_surf(subid, vol=vol, surf=surf, seed=seed, outfile=outfile, views=views)


    '''
    plot_surf.py \
    --subid $subjid \
    --views lat \
    --vol /data/NIMH_scratch/kleinrl/analyses/allGlasser_pca10/1136.L_TE2p/mean/inv_thresh_zstat1.fwhm8.L2D.columns_ev_30000_borders.downscaled2x_NN.ratio.nii.gz

    
    '''