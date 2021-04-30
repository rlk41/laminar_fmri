import nibabel as nib
import pandas as pd
import numpy as np
import os
import glob
import argparse

def extract(epi,parc, save_path, id, roi_name=''):

    epi_load   = nib.load(epi)
    e_obj           = np.asarray(epi_load.dataobj)

    parc_load   = nib.load(parc)
    p_obj           = np.asarray(parc_load.dataobj)

    p = p_obj == id


    ts = e_obj[p]

    if roi_name != '':
        col         = "{}.thalamic.{}".format(id,roi_name)
    else:
        col             = "{}.thalamic".format(id)

    np.save('{}/{}'.format(save_path,col),ts)

#thamus parcellation
def build():
    LUT_file='/usr/local/freesurfer/FreeSurferColorLUT.txt'
    #LUT_file = '/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects/warped_MP2RAGE/multiAtlasTT/hcp-mmp-b/LUT_hcp-mmp-b_v2.txt'
    lut = pd.read_table(LUT_file, delim_whitespace=True, skiprows=[0,1], header=None, names=['ID', 'ROI', 'R', 'G', 'B', 'T'])

    parc_path = '/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects/warped_MP2RAGE/mri/scaled_ThalamicNuclei.v12.T1.nii.gz'
    f = nib.load(parc_path)
    v = f.get_fdata()
    unq = np.unique(v)

    save_path='/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract'

    epi_dir='/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/scaled_runs'
    epi_runs = glob.glob(os.path.join(epi_dir,'scaled*'))
    epi_run     = epi_runs[1]


    # for u in range(1,len(unq)):
    #     id = str(int(unq[u]))
    #
    #     print(lut[lut['ID'] == id])
    #     roi_name = lut[lut['ID'] == id]['ROI'].values[0]
    #
    #     extract(epi_run, parc_path, save_path, int(id), roi_name)
    #
    #



    with open('./cmds/cmds_extract_ts_thalamic.txt','w') as w:
        for u in range(1,len(unq)):
            id = str(int(unq[u]))

            #print(lut[lut['ID'] == id])
            roi_name = lut[lut['ID'] == id]['ROI'].values[0]

            #extract(epi_run, parc_path, save_path, int(id), roi_name)
            w.writelines("python ./tools/extract_ts_main_thalamic.py --epi '{}' --parc '{}' --save '{}' --id {} --roi_name '{}' \n"
                         .format(epi_run, parc_path, save_path, int(id), roi_name))



if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='extract_ts')
    parser.add_argument('--epi', type=str)
    parser.add_argument('--parc', type=str)
    parser.add_argument('--save', type=str)
    parser.add_argument('--id', type=int)
    parser.add_argument('--roi_name', type=str)

    args = parser.parse_args()

    # roi_name = 'L_V1'
    # id_roi = 1001
    # id_layer = 1

    #print(args.accumulate(args.integers))

    print("RUNNING: {} {}".format(args.roi_name, args.save))

    extract(args.epi, args.parc, args.save, args.id, args.roi_name)


    # parallel --jobs 20 < ./cmds/cmds_extract_ts_thalamic.txt