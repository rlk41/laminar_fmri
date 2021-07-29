import nibabel
import numpy as np
import pandas as pd

def mat2vol(mat, LUT_path, parc_path, roi):

    '''
    mat =
    LUT_path=''
    parc_path=''
    roi='1'

    :param mat:
    :param LUT_path:
    :param parc_path:
    :param roi:
    :return:
    '''

    #read LUT get ROI
    LUT = np.loadtxt(LUT_path)



    series = mat.iloc[id,:]

    series2vol(series, LUT, parc)


    return



def series2vol(data2plot, ids2fill, parc_path):


    '''

    mat =
    LUT_path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all'\
    '/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/columns_equivol_1000/LUT_columns_1000_equivol.txt'
    parc_path='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all'\
    '/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/columns_equivol_1000/warped_rim_columns1000.nii'
    roi='1'

    :param mat:
    :param LUT_path:
    :param parc_path:
    :param roi:
    :return:
    '''

    # #LUT = np.loadtxt(LUT_path)
    # LUT = pd.read_csv(LUT_path, sep=' ')
    #
    #
    # np.where(LUT.iloc[:,1] == roi)

    parc = nibabel.load(parc_path)
    parc_data = parc.get_data()

    for value in values:
        ids_fill = np.where(parc_data == id)

        out_data[ids_fill] = value

    return



def plot_surf():
    import os
    from surfer import Brain, project_volume_data

    print(__doc__)

    """
    Bring up the visualization window.
    """
    brain = Brain("fsaverage", "lh", "inflated")

    """
    Get a path to the volume file.
    """
    volume_file = "example_data/zstat.nii.gz"

    """
    There are two options for specifying the registration between the volume and
    the surface you want to plot on. The first is to give a path to a
    Freesurfer-style linear transformation matrix that will align the statistical
    volume with the Freesurfer anatomy.
    
    Most of the time you will be plotting data that are in MNI152 space on the
    fsaverage brain. For this case, Freesurfer actually ships a registration matrix
    file to align your data with the surface.
    """
    reg_file = os.path.join(os.environ["FREESURFER_HOME"],
                            "average/mni152.register.dat")
    zstat = project_volume_data(volume_file, "lh", reg_file)

    """
    Note that the contours of the fsaverage surface don't perfectly match the
    MNI brain, so this will only approximate the location of your activation
    (although it generally does a pretty good job). A more accurate way to
    visualize data would be to run the MNI152 brain through the recon-all pipeline.
    
    Alternatively, if your data are already in register with the Freesurfer
    anatomy, you can provide project_volume_data with the subject ID, avoiding the
    need to specify a registration file.
    
    By default, 3mm of smoothing is applied on the surface to clean up the overlay
    a bit, although the extent of smoothing can be controlled.
    """
    zstat = project_volume_data(volume_file, "lh",
                                subject_id="fsaverage", smooth_fwhm=0.5)

    """
    Once you have the statistical data loaded into Python, you can simply pass it
    to the `add_overlay` method of the Brain object.
    """
    brain.add_overlay(zstat, min=2, max=12)

    """
    It can also be a good idea to plot the inverse of the mask that was used in the
    analysis, so you can be clear about areas that were not included.
    
    It's good to change some parameters of the sampling to account for the fact
    that you are projecting binary (0, 1) data.
    """
    mask_file = "example_data/mask.nii.gz"
    mask = project_volume_data(mask_file, "lh", subject_id="fsaverage",
                               smooth_fwhm=0, projsum="max").astype(bool)
    mask = ~mask
    brain.add_data(mask, min=0, max=10, thresh=.5,
                   colormap="bone", alpha=.6, colorbar=False)

    brain.show_view("medial")
