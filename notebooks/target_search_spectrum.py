import matplotlib.pyplot as plt 
import pandas as pd 
import numpy as np 
from scipy import spatial
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
from matplotlib import cm
from colorspacious import cspace_converter
from scipy.cluster.hierarchy import cut_tree, fcluster
import scipy.cluster.hierarchy as sch

cmap        = cm.get_cmap('plasma')
colors      = cmap.colors
colors_len  = len(colors) 


csv_file="/data/kleinrl/Wholebrain2.0/fsl_feats/"+\
    "fsl_feats_DF-smoothed_inv_thresh_zstat1.L2D-columns_ev_1000_borders.downscaled2x_NN.pkl"

df_all = pd.read_pickle(csv_file)

df = df_all[df_all.target == 791]

vs = [ v for v in df.columns if 'value' in v ] 

x = [ i for i in range(len(vs)) ]

vals = df[vs].values

vals_len = vals.shape[0]

cs = np.zeros(shape=(vals_len, vals_len))


for j in range(vals_len):
    for k in range(j, vals_len):

        jv = vals[j,:]
        jv = (jv-np.mean(jv))/np.std(jv)

        kv = vals[k,:]
        kv = (kv-np.mean(kv))/np.std(kv)

        c = 1 - spatial.distance.cosine(jv, kv)
        cs[j,k] = c 



cs_t = cs + cs.T - np.diag(np.diag(cs))*2

D = cs_t 
dpi = 300 
size=(5,5)


print("D shape: {}".format(D.shape))

len_rois = D.shape[0]

# Compute and plot dendrogram.
fig = plt.figure(figsize=size, dpi=dpi)
axdendro = fig.add_axes([0.09,0.1,0.2,0.8])
Y = sch.linkage(D, method='centroid')
Z = sch.dendrogram(Y, orientation='right')

index           = Z['leaves']

# Plot distance matrix.
axmatrix = fig.add_axes([0.3,0.1,0.6,0.8])

D = D[index,:]
D = D[:,index]

im = axmatrix.matshow(D, aspect='auto', origin='lower')
axmatrix.set_xticks([])
axmatrix.set_yticks([])

# Plot colorbar.
axcolor = fig.add_axes([0.91,0.1,0.02,0.8])
plt.colorbar(im, cax=axcolor)

# Display and save figure.
fig.show()












fb_c    = []
ff_c    = []
flat_c  = []
up_c    = []
down_c  = []

ff_or_fb = [] 
ff_or_fb_val = []

group = [] 

for i in range(to_plot.shape[0]):

    y = to_plot[vs].iloc[i]
    y = (y-np.mean(y))/np.std(y)
    y = y.to_numpy()

    fb_co = 1 - spatial.distance.cosine(fb_ps, y)
    if fb_co != fb_co: 
        fb_co = 0

    fb_c.append(fb_co)
    
    ff_co = 1 - spatial.distance.cosine(ff_ps, y)
    if ff_co != ff_co: 
        ff_co = 0

    ff_c.append(ff_co)    
    
    flat_co = 1 - spatial.distance.cosine(flat, y)
    if flat_co != flat_co: 
        flat_co = 0

    flat_c.append(flat_co)    
    
    up_co = 1 - spatial.distance.cosine(up, y)
    if up_co != up_co: 
        up_co = 0
    
    up_c.append(up_co)

    down_co = 1 - spatial.distance.cosine(down, y)
    if down_co != down_co: 
        down_co = 0
    
    down_c.append(down_co)

    if fb_co > ff_co: 
        ff_or_fb.append(-1)
        ff_or_fb_val.append(fb_co)
    else: 
        ff_or_fb.append(1)
        ff_or_fb_val.append(ff_co)


    max_all = np.max([fb_co, ff_co, flat_co, down_co, up_co])
    print(max_all)

    if fb_co == max_all:
        group.append('fb')
    elif ff_co == max_all: 
        group.append('ff') 
    elif up_co == max_all: 
        group.append('up')
    elif down_co == max_all: 
        group.append('down')
    elif flat_co == max_all: 
        group.append('flat')  
    else: 
        group.append('none') 



to_plot['fb_corr']      = fb_c
to_plot['ff_corr']      = ff_c
to_plot['flat_corr']    = flat_c
to_plot['up_corr']      = up_c
to_plot['down_corr']    = down_c

to_plot['group']        = group
to_plot['ff_or_fb']     = ff_or_fb
to_plot['ff_or_fb_val'] = ff_or_fb_val



# feed back profiles 
to_plot_fb = to_plot
to_plot_fb.groupby(['seed'], sort=True)['fb_corr'].max()
idx = to_plot_fb.groupby(['seed'])['fb_corr'].transform(max) == to_plot['fb_corr']
to_plot_fb = to_plot_fb[idx]


rois = [['1090.L_10pp', '1088.L_10v', '1065.L_10r', '1072.L_10d'], 
        ['1087.L_9a', '1071.L_9p', '1069.L_9m', '1086.L_9-46d'], 
        ['1070.L_8BL', '1063.L_8BM', '1067.L_8Av', '1073.L_8C', '1068.L_8Ad'],
        ['1010.L_FEF'], 
        ['1042.L_7AL', '1047.L_7PC', '1046.L_7PL','1029.L_7Pm', '1045.L_7Am','1030.L_7m'],
        ['1006.L_V4'],
        ['1007.L_V8','1016.L_V7','1003.L_V6', '1152.L_V6A','1023.L_MT'], 
        ['8109.lh.LGN', '1001.L_V1', '1004.L_V2', '1005.L_V3', '1013.L_V3A','1019.L_V3B', '1158.L_V3CD']]


df = to_plot_fb 

x_i,y_i = 7,7
fig = plt.figure(constrained_layout=True, figsize=(10,10))
spec = fig.add_gridspec(ncols=x_i, nrows=y_i)

row_count = 0 
for g in range(len(rois)):
    for r in range(len(rois[g])):

        row = g
        col = r 
        ax = fig.add_subplot(spec[row, col])

        roi_name = rois[g][r]

        y = df.loc[df.seed == roi_name][vs].values.tolist() #.iloc[i] #to_plot.iloc[i,:]
        
        y = (y-np.mean(y))/np.std(y)

        plt.plot(x,y[0], color='white')
        
        c = df.loc[df.seed == roi_name]['fb_corr']
        color_val = int(c * 255 )
        #ax.patch.set_alpha(0.75)
        ax.set_facecolor(colors[color_val])

        seed, seed_pca, target, vol = df.loc[df.seed == roi_name]['seed'], df.loc[df.seed == roi_name]['seed_pca'], \
            df.loc[df.seed == roi_name]['target'], df.loc[df.seed == roi_name]['vol']
    
        plt.title("{}\n{}".format(seed.values[0], round(c.values[0],3))) #split('.')[1]

plt.savefig(plotdir + "grid_to_plot_fb.png")
plt.close()






#feedforward profiles 
to_plot_ff = to_plot
to_plot_ff.groupby(['seed'], sort=True)['ff_corr'].max()
idx = to_plot_ff.groupby(['seed'])['ff_corr'].transform(max) == to_plot_ff['ff_corr']
to_plot_ff = to_plot_ff[idx]


df = to_plot_ff

x_i,y_i = 7,7
fig = plt.figure(constrained_layout=True, figsize=(10,10))
spec = fig.add_gridspec(ncols=x_i, nrows=y_i)

row_count = 0 
for g in range(len(rois)):
    for r in range(len(rois[g])):

        row = g
        col = r 
        ax = fig.add_subplot(spec[row, col])

        roi_name = rois[g][r]

        y = df.loc[df.seed == roi_name][vs].values.tolist() #.iloc[i] #to_plot.iloc[i,:]
        
        y = (y-np.mean(y))/np.std(y)

        plt.plot(x,y[0], color='white')
        
        c = df.loc[df.seed == roi_name]['fb_corr']
        color_val = int(c * 255 )
        #ax.patch.set_alpha(0.75)
        ax.set_facecolor(colors[color_val])

        seed, seed_pca, target, vol = df.loc[df.seed == roi_name]['seed'], df.loc[df.seed == roi_name]['seed_pca'], \
            df.loc[df.seed == roi_name]['target'], df.loc[df.seed == roi_name]['vol']
    
        plt.title("{}\n{}".format(seed.values[0], round(c.values[0],3))) #split('.')[1]

plt.savefig(plotdir + "grid_to_plot_ff.png")
plt.close()





# fb or ff profiles 
to_plot_ff_or_fb = to_plot
to_plot_ff_or_fb.groupby(['seed'], sort=True)['ff_or_fb_val'].max()
idx = to_plot_ff_or_fb.groupby(['seed'])['ff_or_fb_val'].transform(max) == to_plot_ff_or_fb['ff_or_fb_val']
to_plot_ff_or_fb = to_plot_ff_or_fb[idx]



df = to_plot_ff_or_fb

x_i,y_i = 7,7
fig = plt.figure(constrained_layout=True, figsize=(10,10))
spec = fig.add_gridspec(ncols=x_i, nrows=y_i)

row_count = 0 
for g in range(len(rois)):
    for r in range(len(rois[g])):

        row = g
        col = r 
        ax = fig.add_subplot(spec[row, col])

        roi_name = rois[g][r]

        y = df.loc[df.seed == roi_name][vs].values.tolist() #.iloc[i] #to_plot.iloc[i,:]
        
        y = (y-np.mean(y))/np.std(y)

        if df.loc[df.seed == roi_name]['ff_or_fb'].values[0] == 1: 
            color = 'blue'
        else:
            color = 'red'

        plt.plot(x,y[0], color=color)
        
        c = df.loc[df.seed == roi_name]['fb_corr']
        color_val = int(c * 255 )
        
        ax.patch.set_alpha(0.75)
        ax.set_facecolor(colors[color_val])

        seed, seed_pca, target, vol = df.loc[df.seed == roi_name]['seed'], df.loc[df.seed == roi_name]['seed_pca'], \
            df.loc[df.seed == roi_name]['target'], df.loc[df.seed == roi_name]['vol']
    
        plt.title("{}\n{}".format(seed.values[0], round(c.values[0],3))) #split('.')[1]

plt.savefig(plotdir + "grid_to_plot_fb_or_fb.png")
plt.close()









# good till here 















to_plot = to_plot.sort_values('fb_corr', ascending=False)

to_plot.iloc[0:50,:]

plotdir="./target_search_plots/"

f = plt.figure()
plt.plot(x, fb_ps)
plt.savefig(plotdir + "fb_profile.png")
plt.close()

for i in range(100):
    f = plt.figure()
    y = to_plot[vs].iloc[i] #to_plot.iloc[i,:]
    y = (y-np.mean(y))/np.std(y)

    plt.plot(x,y)
    seed=to_plot['seed'].iloc[i]
    seed_pca=to_plot['seed_pca'].iloc[i]
    target=to_plot['target'].iloc[i]
    vol=to_plot['vol'].iloc[i]

    plt.title("seed: {} seed_pca: {} target: {}"\
        .format(seed, seed_pca, target))
    # plt.title("seed: {} seed_pca: {} target: {} \n vol: {}"\
    #     .format(seed, seed_pca, target, vol))

    plt.savefig(plotdir + "T791_S{}-{}.png".format(seed, seed_pca))
    plt.close()


f = plt.figure()
for i in range(to_plot.shape[0]):
    if i%10 == 0 and 1 != 0: 

        plt.savefig(plotdir + "10x_{0:03d}.png".format(i))
        plt.close()
        f = plt.figure()

    y = to_plot[vs].iloc[i] #to_plot.iloc[i,:]
    y = (y-np.mean(y))/np.std(y)

    plt.plot(x,y)




to_plot.groupby(['seed'], sort=True)['fb_corr'].max()

idx = to_plot.groupby(['seed'])['fb_corr'].transform(max) == to_plot['fb_corr']

t = to_plot[idx]



for i in range(t.shape[0]):
    f = plt.figure()
    y = t[vs].iloc[i] #to_plot.iloc[i,:]
    y = (y-np.mean(y))/np.std(y)

    plt.plot(x,y)
    seed=t['seed'].iloc[i]
    seed_pca=t['seed_pca'].iloc[i]
    target=t['target'].iloc[i]
    vol=t['vol'].iloc[i]

    plt.title("seed: {} seed_pca: {} target: {}"\
        .format(seed, seed_pca, target))
    # plt.title("seed: {} seed_pca: {} target: {} \n vol: {}"\
    #     .format(seed, seed_pca, target, vol))

    plt.savefig(plotdir + "T791_S{}-{}_best.png".format(seed, seed_pca))
    plt.close()

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
from matplotlib import cm
from colorspacious import cspace_converter

cmap = cm.get_cmap('plasma')
colors = cmap.colors
colors_len = len(colors) 







rois = [['1090.L_10pp', '1088.L_10v', '1065.L_10r', '1072.L_10d'], 
        ['1087.L_9a', '1071.L_9p', '1069.L_9m', '1086.L_9-46d'], 
        ['1070.L_8BL', '1063.L_8BM', '1067.L_8Av', '1073.L_8C', '1068.L_8Ad' '1010.L_FEF'], 
        ['1042.L_7AL', '1047.L_7PC', '1046.L_7PL','1029.L_7Pm', '1045.L_7Am','1030.L_7m'],
        ['1006.L_V4'],
        ['1007.L_V8','1016.L_V7','1003.L_V6', '1152.L_V6A','1023.L_MT'], 
        ['8109.lh.LGN', '1001.L_V1', '1004.L_V2', '1005.L_V3', '1013.L_V3A','1019.L_V3B', '1158.L_V3CD']]


x_i,y_i = 7,7
fig = plt.figure(constrained_layout=True, figsize=(10,10))
spec = fig.add_gridspec(ncols=x_i, nrows=y_i)

#max = t['fb_corr'].max()
#min = t['fb_corr'].min()

row_count = 0 
for g in range(len(rois)):
    for r in range(len(g)):

        #row = int(i / y_i )
        #col = int(i % x_i )
        row = g
        col = r 

        ax = fig.add_subplot(spec[row, col])


        y = t[vs].iloc[i] #to_plot.iloc[i,:]
        
        y = (y-np.mean(y))/np.std(y)
        plt.plot(x,y) #, color='white')
        
        c = t['fb_corr'].iloc[i]
        color_val = int(c * 255 )
        #ax.patch.set_alpha(0.75)
        ax.set_facecolor(colors[color_val])

        seed, seed_pca, target, vol = t['seed'].iloc[i], t['seed_pca'].iloc[i], \
            t['target'].iloc[i], t['vol'].iloc[i]
    
        plt.title("{} - {}".format(seed, round(c,3))) #split('.')[1]

plt.savefig(plotdir + "grid_fb.png")
plt.close()












# BACKUP ##########################

x_i,y_i = 6,6 
fig = plt.figure(constrained_layout=True, figsize=(10,10))
spec = fig.add_gridspec(ncols=x_i, nrows=y_i)

max = t['fb_corr'].max()
min = t['fb_corr'].min()

for i in range(t.shape[0]):
    row,col = int(i / y_i ), int(i % x_i )

    ax = fig.add_subplot(spec[row, col])
    y = t[vs].iloc[i] #to_plot.iloc[i,:]
    y = (y-np.mean(y))/np.std(y)
    plt.plot(x,y, color='white')
    
    c = t['fb_corr'].iloc[i]
    color_val = int(c * 255 )
    #ax.patch.set_alpha(0.75)
    ax.set_facecolor(colors[color_val])

    seed, seed_pca, target, vol = t['seed'].iloc[i], t['seed_pca'].iloc[i], \
        t['target'].iloc[i], t['vol'].iloc[i]
 
    plt.title("{} - {}".format(seed, round(c,3))) #split('.')[1]

plt.savefig(plotdir + "grid_fb.png")
plt.close()



##########################
















to_plot = v4_to_plot #.iloc[0:100,:]
to_plot.shape 

x = [ i for i in range(len(vs)) ]

s = to_plot.shape[0]

corrs = np.zeros(shape=(s,s))

for i in range(to_plot.shape[0]):
    for ii in range(i, to_plot.shape[0]):

        y = to_plot[vs].iloc[i]
        y = (y-np.mean(y))/np.std(y)
        y = y.to_numpy()


        z = to_plot[vs].iloc[ii]
        z = (z-np.mean(z))/np.std(z)
        z = z.to_numpy()


        co = 1 - spatial.distance.cosine(z, y)

        corrs[i,ii] = co




# corrs2 = corrs[np.triu_indices(corrs.shape[0],1)]

# corrs3 = np.triu(corrs)

# corrs3 

corrs4 = corrs + corrs.T - np.diag(np.diag(corrs))*2

corrs4[0:10,0:10]

plt.matshow(corrs4)



from scipy.cluster.hierarchy import cut_tree, fcluster
import scipy.cluster.hierarchy as sch

D = corrs4 
dpi = 300 
size=(5,5)

#print("o_array shape: {}".format(o_array.shape))

#D = corrcoef(o_array)

print("D shape: {}".format(D.shape))

len_rois = D.shape[0]

# Compute and plot dendrogram.
fig = plt.figure(figsize=size, dpi=dpi)
axdendro = fig.add_axes([0.09,0.1,0.2,0.8])
Y = sch.linkage(D, method='centroid')
Z = sch.dendrogram(Y, orientation='right')

index           = Z['leaves']
#labels          = [ '-'.join([df['r1'].iloc[l], df['r2'].iloc[l]]) for l in range(df.shape[0]) ]
#labels_reorg    = [ labels [x] for x in index ]
#labels_reorg = ids 

#axdendro.set_xticks([])
#axdendro.set_yticks([])
#axdendro.set_xticks(range(len_rois))
#axdendro.set_yticks(range(len_rois))
#axdendro.set_xticklabels(labels_reorg)
#axdendro.set_yticklabels(labels_reorg)

# Plot distance matrix.
axmatrix = fig.add_axes([0.3,0.1,0.6,0.8])

D = D[index,:]
D = D[:,index]

im = axmatrix.matshow(D, aspect='auto', origin='lower')
axmatrix.set_xticks([])
axmatrix.set_yticks([])

# Plot colorbar.
axcolor = fig.add_axes([0.91,0.1,0.02,0.8])
plt.colorbar(im, cax=axcolor)

# Display and save figure.
fig.show()
