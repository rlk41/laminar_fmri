#!/bin/bash 

import nibabel as nib 
import argparse 


def transfer_from_to(from_file, to_file, prefix): 



    im1 = nib.load(from_file)
    im2 = nib.load(to_file)

    new_img = im2.__class__(im2.dataobj[:], im1.affine, im1.header)
    new_img.to_filename(prefix)




    return 

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='regressLayers')
    parser.add_argument('--from_file', type=str)
    parser.add_argument('--to_file', type=str)
    parser.add_argument('--prefix', type=str)


    args = parser.parse_args()

    from_file = args.from_file
    to_file = args.to_file
    prefix = args.prefix

    '''
    
    from_file="/data/kleinrl/ds003216/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w.nii"
    to_file="/data/kleinrl/ds003216/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII/rim.nii"
    prefix="/data/kleinrl/ds003216/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII/rim.fixheader.nii"

    '''
    
    print("from_file: {}".format(from_file))
    print("to_file:   {}".format(to_file))
    print("prefix:    {}".format(prefix))


    transfer_from_to(from_file, to_file, prefix)