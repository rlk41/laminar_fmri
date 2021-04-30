#!/bin/bash

reconall='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects/warped_MP2RAGE'
layers='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/getting-layers-in-epi-space'
scaled='/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/scaled_runs'
extracted='/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract'
layer_profiles='/home/richard/Projects/bandettini/layer_profiles'

cp ${extracted}/*.png ${layer_profiles}/
