import os
import numpy as np
import nibabel as nib
import numba as nb
from glob import glob
import numba.cuda
import cupy, time
import pandas as pd
import time
import pandas as pd
from multiprocessing import Pool

def parallelize(df_list, func, n_cores=4):
    '''
    func accepts a list of dfs
    :param df_list:
    :param func:
    :param n_cores:
    :return:
    '''
    '''
    async_result = pool.map_async(process_single_df, listOfDfs)
    allDfs = async_result.get()
    '''
    pool = Pool(n_cores)
    df = pool.map(func, df_list)
    pool.close()
    pool.join()

    if type(df) == type(pd.DataFrame()):
        result = {}
        for d in df:
            result.update(d)
        return result
    else:
        return df
    return


file_dir='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/getting-layers-in-epi-space'
# get layers file
layers_path     = os.path.join(file_dir, 'leaky_layers.nii')
layers          = nib.load(layers_path)
layers_data     = layers.get_fdata()

# get parcellation file
parc_file='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects/warped_MP2RAGE/multiAtlasTT/hcp-mmp-b/scaled_hcp-mmp-b.nii.gz'
parc          = nib.load(parc_file)
parc_data     = parc.get_fdata()

LUT_file = '/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects/warped_MP2RAGE/multiAtlasTT/hcp-mmp-b/LUT_hcp-mmp-b_v2.txt'
lut = pd.read_table(LUT_file, sep=' ', header=None, names=['ID', 'ROI', 'R', 'G', 'B', 'T'])

epi_dir='/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/scaled_runs'
epi_path = os.path.join(file_dir, 'scaled_EPI.nii')
epi_runs = glob(os.path.join(epi_dir,'scaled*'))
epi_run     = epi_runs[1]
epi         = nib.load(epi_run)
e           = np.asarray(epi.dataobj)
#e    = epi.get_fdata()


ROI_ID = lut['ID'].loc[ lut['ROI']=='L_V1' ]
unq_layers = np.unique(layers_data)
len_layers = len(unq_layers)




def get_layers(proc):

    start = time.time()

    roi_name        = proc['roi_name']
    id_roi          = proc['id_roi']
    id_layer        = proc['id_layer']
    parc_data       = proc['parc_data']
    layers_data     = proc['layers_data']
    e               = proc['e']

    p = parc_data   == id_roi
    l = layers_data == id_layer
    ts = e[p*l]

    save_path='/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract'
    col         = "{}.{}.L{}".format(id_roi,roi_name,id_layer)
    np.save('{}/{}'.format(save_path,col),ts)

    end = time.time()

    print("DONE: {} - {}".format(col, end - start))

    return



proc_list = []
for i in range(lut.shape[0]):
    id = lut['ID'].iloc[i]
    roi = lut['ROI'].iloc[i]

    for i_layer in range(1,len_layers):
        proc_list.append({'roi_name':roi,
                          'id_roi':id,
                          'id_layer':i_layer,
                          'e':e,
                          'parc_data':parc_data,
                          'layers_data':layers_data})



'''

parallelize(proc_list, get_layers, n_cores=10)

start = time.time()
parallelize(proc_list[0:10], get_layers, n_cores=10)
end = time.time()
print('time elapsed: {}'.format(end-start))

get_layers(proc_list[0])

'''

#
# for p in proc_list:
#     get_layers(p)
#     print(p['roi_name'], p['id_layer'])

    #count   = 0
        #
        # for c in coords:
        #     x,y,z = c[0],c[1],c[2]
        #     val_layer = layers_data[x,y,z]
        #
        #     #if val_layer == i_layer:
        #         ts = e[x,y,z]
                #tss.append(ts)

                # #print(x,y,z, i_layer, val_layer)
                # col = "{}_{}_{}".format(roi,i_layer,count)
                # OUT[col] = ts
                #
                # print(id, roi, count)
                #
                # count += 1

            #tss = np.stack(tss)

            #tss.shape
            #mean = np.mean(tss,0)
            #var  = np.var(tss,0)



# OUT = pd.DataFrame()
#
# from numba import njit, prange
#
# @njit(parallel=True)
# def get_layers(lut, parc_data, layers_data, e):
#
#     save_path='/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract'
#
#     for i in range(lut.shape[0]):
#         id = lut['ID'].iloc[i]
#         roi = lut['ROI'].iloc[i]
#
#         p = parc_data == id
#
#         for i_layer in prange(1,len_layers):
#             l = layers_data == i_layer
#
#             ts = e[p*l]
#             col         = "{}_L{}".format(roi,i_layer)
#
#             np.save('{}/{}'.format(save_path,col),ts)
#
#             #OUT[col]    = np.mean(ts,0)
#
#             print(col)
#
#     return #OUT
#
#
#
#     OUT = get_layers(lut, parc_data, layers_data, e) #, OUT)
#


x,y,z = np.where(layers_data != 0)

coords  = list(zip(x,y,z))
seed    = coords[0]

vol =e



targs = [ vol[coords[c][0], coords[c][1], coords[c][2]] for c in range(len(coords))]

len_targs = len(targs)



def t_mat_corrcoef(t):
    cupy.cuda.Stream.null.synchronize()
    c = cupy.corrcoef(t)
    cupy.cuda.Stream.null.synchronize()
    return c

start = 0
out = []
#for i in range(0, len_targs, 10000):
for i in range(10000, 1000000, 10000):

    end = i
    print('start: {} end: {}'.format(start, end))


    t   = np.stack(targs[start:end])
    t   = cupy.asarray(t)

    c = t_mat_corrcoef(t)
    out.append(c)


    start = end

#t = targs[0:1000]
# def targs_corrcoef(t):
#     #a = cupy.random.random(m * n).reshape(m,n)
#     cupy.cuda.Stream.null.synchronize()
#     s = time.time_ns()
#     reps = len(t)
#     out = []
#
#     for x in range(reps):
#         for y in range(x,reps):
#             c = cupy.corrcoef(t[x],t[y])
#             out.append({'x':x,'y':y,'corr':c})
#
#     cupy.cuda.Stream.null.synchronize()
#     e = time.time_ns()
#     print((e-s)/reps/(10**6), " milliseconds")
#
#     return out
#out = targs_corrcoef(t)



#t = np.stack(targs)


#
# import numpy
# #data = numpy.ones(256)
# corrs = np.zeros((len(coords),1))
# out = np.zeros((len(targs)))
# #out = np.ndarray()
# threadsperblock = 32
# blockspergrid = (out.size + (threadsperblock - 1)) // threadsperblock
#
# calc_fc[blockspergrid, threadsperblock](t,out)
#
# calc_fc(t,out)
#
#
# np.mean(layers_data,axis=1)
#
#
#
# # print("epi data ")
# # print("Shape: {}".format(epi_data.shape))
# # #print("Unique: {}".format(np.unique(epi_data)))
# #
# #
# # print("epi data ")
# # print("Shape: {}".format(rim_data.shape))
# # #print("Unique: {}".format(np.unique(rim_data)))
#
#
# import cupy as cp
# t = np.stack(targs)
# c  = cp.corrcoef(targs)
#
#
# import math
# from numba import vectorize
# from numba import cuda
#
# # print(cuda.gpus)
# #
#
#
# # Now start the kernel
# #my_kernel[blockspergrid, threadsperblock](data)
# #
# # # Print the result
# # print(data)
#
#
# #from numba import cuda
# cuda.select_device(1)
# #
# # numba.cuda.threadIdx
# #
# # numba.cuda.blockDim
# #
# # numba.cuda.blockIdx
# #
# # numba.cuda.gridDim
#
# from numba import jit
#
#
#
# #@vectorize(['float32(float32)'], target='cuda')
# #@cuda.jit
# @jit(nopython=True, parallel=True)
# def calc_fc(seed, coords, vol):
#     seed_data = vol[seed[0], seed[1], seed[2]]
#     corrs = np.empty((len(coords),1))
#     for c in range(len(coords[0:10])):
#         coord = coords[c]
#         target = vol[coord[0], coord[1], coord[2]]
#         corrs[c,0] = np.corrcoef(seed_data, target)[0,1]
#     return corrs
#
#
# @cuda.jit
# def calc_fc(seed, coords, vol, corrs):
#     for c in range(len(coords)):
#         corrs[c] = np.corrcoef(vol[seed[0], seed[1], seed[2]],
#                                vol[coords[c][0], coords[c][1], coords[c][2]])[0,1]
#
# from numba import jit
#
# @jit(nopython=True)
# def calc_fc(targs, out):
#     i = 0
#     l = len(targs)
#     for x in range(l):
#         for y in range(l):
#             c = np.corrcoef(targs[x],targs[y])[0,1]
#             out[i] = c
#

#
# import numpy as np
# npoints = int(1e7)
# a = np.arange(npoints, dtype=np.float32)
#
# import math
# from numba import vectorize
#
# @vectorize
# def cpu_sqrt(x):
#     return math.sqrt(x)
#
# cpu_sqrt(x)
#
# import math
# from numba import vectorize
#
# @vectorize(['float32(float32)'], target='cuda')
# def gpu_sqrt(x):
#     return math.sqrt(x)
#
# gpu_sqrt(a)

import cupy, time
#
# def cupy_corrcoef(m, n, reps):
#     a = cupy.random.random(m * n).reshape(m,n)
#     cupy.cuda.Stream.null.synchronize()
#     s = time.time_ns()
#     for x in range(reps):
#         cupy.corrcoef(a)
#     cupy.cuda.Stream.null.synchronize()
#     e = time.time_ns()
#     print((e-s)/reps/(10**6), " milliseconds")
#
# cupy_corrcoef(1000, 100000, 100)

def targs_corrcoef(targs):
    #a = cupy.random.random(m * n).reshape(m,n)
    cupy.cuda.Stream.null.synchronize()
    s = time.time_ns()
    reps = len(targs)
    out = []

    for x in range(reps):
        for y in range(x,reps):
            c = cupy.corrcoef(targs[x],targs[y])
            out.append({'x':x,'y':y,'corr':c})

    cupy.cuda.Stream.null.synchronize()
    e = time.time_ns()
    print((e-s)/reps/(10**6), " milliseconds")

    return out

out = targs_corrcoef(targs)