import os
import numpy as np
import nibabel as nib
from glob import glob
import time
import pandas as pd
import argparse

# import numba as nb
# import numba.cuda
# import cupy, time
# import pandas as pd
# from multiprocessing import Pool
#
#
# def parallelize(df_list, func, n_cores=4):
#     '''
#     func accepts a list of dfs
#     :param df_list:
#     :param func:
#     :param n_cores:
#     :return:
#     '''
#     '''
#     async_result = pool.map_async(process_single_df, listOfDfs)
#     allDfs = async_result.get()
#     '''
#     pool = Pool(n_cores)
#     df = pool.map(func, df_list)
#     pool.close()
#     pool.join()
#
#     if type(df) == type(pd.DataFrame()):
#         result = {}
#         for d in df:
#             result.update(d)
#         return result
#     else:
#         return df
#     return

def main(roi_name, id_roi, id_layer):
    file_dir='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/getting-layers-in-epi-space'
    # get layers file
    layers_path     = os.path.join(file_dir, 'leaky_layers_n10.nii')
    layers          = nib.load(layers_path)
    layers_data     = layers.get_fdata()

    # get parcellation file
    parc_file='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects/warped_MP2RAGE/multiAtlasTT/shen268cort/scaled_shen268cort.nii.gz'
    parc          = nib.load(parc_file)
    parc_data     = parc.get_fdata()

    LUT_file = '/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects/warped_MP2RAGE/multiAtlasTT/shen268cort/LUT_shen268cort.txt'
    lut = pd.read_table(LUT_file, sep=' ', header=None, names=['ID', 'ROI', 'R', 'G', 'B', 'T'])

    epi_dir='/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/scaled_runs'
    epi_path = os.path.join(file_dir, 'scaled_EPI.nii')
    epi_runs = glob(os.path.join(epi_dir,'scaled*'))
    epi_run     = epi_runs[1]
    epi         = nib.load(epi_run)
    e           = np.asarray(epi.dataobj)

    unq_layers = np.unique(layers_data)

    start = time.time()

    p = parc_data   == id_roi
    l = layers_data == id_layer
    ts = e[p*l]

    save_path='/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract.shen.n10'
    col         = "{}.{}.L{}".format(id_roi,roi_name,id_layer)
    np.save('{}/{}'.format(save_path,col),ts)

    end = time.time()

    print("DONE: {} - {}".format(col, end - start))

    #return



    # proc_list = []
    # for i in range(lut.shape[0]):
    #     id = lut['ID'].iloc[i]
    #     roi = lut['ROI'].iloc[i]
    #
    #     for i_layer in range(1,len_layers):
    #         proc_list.append({'roi_name':roi,
    #                           'id_roi':id,
    #                           'id_layer':i_layer,
    #                           'e':e,
    #                           'parc_data':parc_data,
    #                           'layers_data':layers_data})
    #

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