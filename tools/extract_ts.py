#!/usr/bin/env python

import os
import numpy as np
import nibabel as nib
import time
import argparse
import pandas as pd

def generate_cmds(epi_file, layers_file, parc_file, LUT_file, save_path, layers, cmd_path):

    lut = pd.read_table(LUT_file, sep=' ', header=None, names=['ID', 'ROI', 'R', 'G', 'B', 'T'])

    with open(cmd_path,'w') as w:

        for i in range(lut.shape[0]):
            id = lut['ID'].iloc[i]
            roi = lut['ROI'].iloc[i]

            for i_layer in range(1,layers+1):
                w.writelines('extract_ts.py --extract --roi_name {} --id_roi {} --id_layer {} --epi_file {}'
                             ' --layers_file {} --parc_file {} --save_path {} \n'
                             .format(roi, id, i_layer, epi_file, layers_file, parc_file, save_path))

def main(roi_name, id_roi, id_layer, epi_file, layers_file, parc_file, save_path):


    layers          = nib.load(layers_file)
    layers_data     = layers.get_fdata()

    parc          = nib.load(parc_file)
    parc_data     = parc.get_fdata()

    p = parc_data   == id_roi
    l = layers_data == id_layer

    epi         = nib.load(epi_file)
    e           = np.asarray(epi.dataobj)

    start = time.time()

    ts = e[p*l]

    base_epi = epi_file.split('/')[-1].rstrip('.nii')

    if not os.path.exists(save_path):
        os.makedirs(save_path)

    col = "{}.{}.{}.L{}".format(base_epi,id_roi,roi_name,id_layer)
    np.save('{}/{}'.format(save_path,col),ts)
    np.savetxt('{}/{}'.format(save_path,col),ts)

    end = time.time()

    print("DONE: {} - {}".format(col, end - start))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='extract_ts')
    parser.add_argument('--build_cmds',action='store_true')
    parser.add_argument('--layers',type=int)
    parser.add_argument('--cmd_path',type=str)

    parser.add_argument('--extract',action='store_true')
    parser.add_argument('--roi_name', type=str)
    parser.add_argument('--id_roi', type=int)
    parser.add_argument('--id_layer', type=int)
    parser.add_argument('--epi_file', type=str)
    parser.add_argument('--layers_file', type=str)
    parser.add_argument('--parc_file', type=str)
    parser.add_argument('--save_path', type=str)

    parser.add_argument('--LUT_file',type=str)
    args = parser.parse_args()

    if args.build_cmds == True:
        print("Generate CMDs: {} {} {}".format(args.layers, args.LUT_file, args.cmd_path))
        generate_cmds(args.epi_file, args.layers_file, args.parc_file, args.LUT_file,
                      args.save_path, args.layers, args.cmd_path)

        # EXAMPLE COMMAND
        # extract_ts.py --build_cmds --epi_file $EPI_scaled --layers_file $warp_leakylayers10_scaled --parc_file $warp_hcp_scaled \
        # --LUT_file $LUT_hcp --save_path $ROIs_hcpl10_scaled_ts --layers 10 --cmd_path $ROIs_hcpl10_scaled_ts_cmds


        print("run with 'parallel --jobs 20 < {}'".format(args.cmd_path))

    elif args.extract == True:
        print("RUNNING: {} {} {}".format(args.roi_name, args.id_roi, args.id_layer))
        main(args.roi_name, args.id_roi, args.id_layer, args.epi_file, args.layers_file, args.parc_file, args.save_path)

        # EXAMPLE COMMAND
        #extract_ts.py --extract --roi_name R_p24 --id_roi 2180 --id_layer 10 \
        # --epi_file /mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/bandettini_data/scaled_runs/scaled_sub-01_ses-06_task-movie_run-05_VASO.nii \
        # --layers_file ${layer4EPI}/warped_leaky_layers_n10.scaled.nii \
        # --parc_file ${layer4EPI}/warped_hcp-mmp-b.scaled.nii \
        # --save_path ${layer4EPI}/ROIs_hcpl10_scaled_ts