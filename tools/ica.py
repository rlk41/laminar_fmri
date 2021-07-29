import os
import numpy as np
import nibabel as nib
from glob import glob
import time
import pandas as pd
import argparse
from nilearn.input_data import NiftiMasker
from nilearn import plotting
from nilearn import image
from nilearn.plotting import plot_stat_map, show
from sklearn.decomposition import FastICA
import numpy as np


def ica(epi, mask):
    # file_dir='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/getting-layers-in-epi-space'
    # rim_path     = os.path.join(file_dir, 'GM_robbon4_manual_corr.nii')
    #
    # # epi_dir='/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/scaled_runs'
    # # epi_runs = glob(os.path.join(epi_dir,'scaled*'))
    # # epi_run     = epi_runs[1]
    #
    # epi_dir='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/derivatives/sub-01/VASO_func'
    # epi_runs = glob(os.path.join(epi_dir,'*movie_run*'))
    # epi_run     = epi_runs[1]
    #

    # masker = NiftiMasker(smoothing_fwhm=8, memory='nilearn_cache', memory_level=1,
    #                      mask_strategy='epi', standardize=True)

    epi_dir='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/derivatives/sub-01/VASO_func'
    epi_runs = glob(os.path.join(epi_dir,'*movie_run*'))
    epi_run     = epi_runs[1]

    # 3dresample -master '/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/derivatives/sub-01/VASO_func/sub-01_ses-05_task-movie_run-05_VASO.nii'\
    # -rmode NN -overwrite \
    # -prefix sub-01_ses-02_run-01_rim2VASO.nii \
    # -input '/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/derivatives/sub-01/layerification/sub-01_ses-02_run-01_rim.nii'

    # 3dresample -master '/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/derivatives/sub-01/VASO_func/sub-01_ses-05_task-movie_run-05_VASO.nii'\
    # -rmode NN -overwrite \
    # -prefix GM_robbon4_manual_corr2VASO.nii \
    # -input '/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/getting-layers-in-epi-space/GM_robbon4_manual_corr.nii'

    #3dresample -master EPI.nii -overwrite -prefix MP2RAGE2EPI.nii -input MP2RAGE.nii

    back_path = '/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/getting-layers-in-epi-space/MP2RAGE2EPI.nii'
    mask_path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/derivatives/sub-01/layerification/GM_robbon4_manual_corr2VASO.nii'
    #mask_path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/getting-layers-in-epi-space/GM_robbon4_manual_corr.nii'

    masker = NiftiMasker(mask_img=mask_path, smoothing_fwhm=8, standardize=True) #, memory='nilearn_cache', memory_level=1)
    data_masked = masker.fit_transform(epi_run)

    report = masker.generate_report()

    # mean_img = image.mean_img(epi_run)
    # display = plotting.plot_anat(mean_img)
    # display.add_overlay(mask_path, cmap=plotting.cm.purple_green)
    # show()

    #Apply ICA
    n_components = 10
    ica = FastICA(n_components=n_components, random_state=42)
    components_masked = ica.fit_transform(data_masked.T).T

    # Normalize estimated components, for thresholding to make sense
    components_masked -= components_masked.mean(axis=0)
    components_masked /= components_masked.std(axis=0)
    # Threshold
    components_masked[np.abs(components_masked) < .8] = 0

    # Now invert the masking operation, going back to a full 3D
    # representation
    component_img1 = masker.inverse_transform(components_masked)


    # Use the mean as a background
    mean_img = image.mean_img(epi_run)

    for i in range(component_img1.shape[3]):
        print('component: {}'.format(i))
        plot_stat_map(image.index_img(component_img1, i), mean_img)
        show()



    ##### 2
    from nilearn.image import math_img
    plot_stat_map(image.index_img(component_img1, 9), mean_img)
    show()
    component_mask = image.index_img(component_img1, 9)
    #component_mask[np.abs(component_mask) >  0] = 1
    #component_mask[np.abs(component_mask) <  0] = 1



    #cm1 = math_img("img > 1",img=component_mask)


    plot_stat_map(component_mask, mean_img)
    show()

    # plot_stat_map(cm2, mean_img)
    # show()
    # plot_stat_map(cm, mean_img)
    # show()

    masker = NiftiMasker(mask_img=cm1, smoothing_fwhm=8, standardize=True) #, memory='nilearn_cache', memory_level=1)
    data_masked = masker.fit_transform(epi_run)

    report = masker.generate_report()

    # mean_img = image.mean_img(epi_run)
    # display = plotting.plot_anat(mean_img)
    # display.add_overlay(mask_path, cmap=plotting.cm.purple_green)
    # show()

    #Apply ICA
    n_components = 10
    ica = FastICA(n_components=n_components, random_state=42)
    components_masked = ica.fit_transform(data_masked.T).T

    # Normalize estimated components, for thresholding to make sense
    components_masked -= components_masked.mean(axis=0)
    components_masked /= components_masked.std(axis=0)
    # Threshold
    components_masked[np.abs(components_masked) < .8] = 0

    # Now invert the masking operation, going back to a full 3D
    # representation
    component_img3 = masker.inverse_transform(components_masked)


    # Use the mean as a background
    mean_img = image.mean_img(epi_run)

    for i in range(component_img3.shape[3]):
        print('component: {}'.format(i))
        plot_stat_map(image.index_img(component_img3, i), mean_img)
        show()



    ##### 3
    from nilearn.image import math_img
    plot_stat_map(image.index_img(component_img3, 3), mean_img)
    show()
    component_mask = image.index_img(component_img3, 3)
    cm1 = math_img("img > 0",img=component_mask)
    cm2 = math_img("img < 0",img=component_mask)
    cm = math_img("img1 + img2",img1=cm1, img2=cm2)
    plot_stat_map(cm, mean_img)
    show()

    masker = NiftiMasker(mask_img=cm, smoothing_fwhm=8, standardize=True) #, memory='nilearn_cache', memory_level=1)
    data_masked = masker.fit_transform(epi_run)

    #Apply ICA
    n_components = 10
    ica = FastICA(n_components=n_components, random_state=42)
    components_masked = ica.fit_transform(data_masked.T).T

    # Normalize estimated components, for thresholding to make sense
    components_masked -= components_masked.mean(axis=0)
    components_masked /= components_masked.std(axis=0)

    # Threshold
    components_masked[np.abs(components_masked) < .8] = 0
    component_img = masker.inverse_transform(components_masked)

    # Use the mean as a background
    mean_img = image.mean_img(epi_run)

    for i in range(component_img.shape[3]):
        print('component: {}'.format(i))
        plot_stat_map(image.index_img(component_img, i), mean_img)
        show()










    start = time.time()

    #p = parc_data   == id_roi
    #l = layers_data == id_layer
    #ts = e[p*l]
    #ts = e[rim_data == 1]



    save_path='/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract_n3'
    col         = "{}.{}.L{}".format(id_roi,roi_name,id_layer)
    np.save('{}/{}'.format(save_path,col),ts)

    end = time.time()

    print("DONE: {} - {}".format(col, end - start))



if __name__ == "__main__":


    parser = argparse.ArgumentParser(description='extract_ts')
    parser.add_argument('--roi_name', type=str)
    parser.add_argument('--id_roi', type=int)
    parser.add_argument('--id_layer', type=int)

    args = parser.parse_args()

    # roi_name = 'L_V1'
    # id_roi = 1001
    # id_layer = 1

    #print(args.accumulate(args.integers))

    print("RUNNING: {} {} {}".format(args.roi_name, args.id_roi, args.id_layer))

    main(args.roi_name, args.id_roi, args.id_layer)

    # ./extract_ts.py --roi_name 'L_V1' --id_roi 1001 --id_layer 1