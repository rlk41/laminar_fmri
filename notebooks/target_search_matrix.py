import matplotlib.pyplot as plt 
import pandas as pd 
import numpy as np 
from scipy import spatial
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
from matplotlib import cm
from colorspacious import cspace_converter
import nibabel as nib 
import pickle 

cmap = cm.get_cmap('plasma')
colors = cmap.colors
colors_len = len(colors) 


plotdir="/home/kleinrl/target_search_plots/"


# LAB dicts 

# rois = [['1090.L_10pp', '1088.L_10v', '1065.L_10r', '1072.L_10d'], 
#         ['1087.L_9a', '1071.L_9p', '1069.L_9m', '1086.L_9-46d'], 
#         ['1070.L_8BL', '1063.L_8BM', '1067.L_8Av', '1073.L_8C', '1068.L_8Ad'],
#         ['2048.R_LIPv', '2095.R_LIPd'],
#         ['1010.L_FEF'], 
#         ['1045.L_7Am','1030.L_7m','1042.L_7AL', '1047.L_7PC', '1046.L_7PL','1029.L_7Pm'],
#         ['1007.L_V8','1016.L_V7','1003.L_V6', '1152.L_V6A','1023.L_MT'], 
#         ['1128.L_STSda', '1129.L_STSdp', '1130.L_STSvp', '1176.L_STSva'],
#         ['1006.L_V4'],
#         ['1001.L_V1', '1004.L_V2', '1005.L_V3', '1013.L_V3A','1019.L_V3B', '1158.L_V3CD'],
#         ['8109.lh.LGN']
#         ]

# rois = [['1072.L_10d'], 
#         ['1087.L_9a'], 
#         ['1063.L_8BM'],
#         ['1010.L_FEF'], 
#         ['1047.L_7PC'],
#         ['1023.L_MT'], 
#         ['1006.L_V4'],
#         ['1001.L_V1'], 
#         ['8109.lh.LGN']
#         ]
#        ['1128.L_STSda', '1129.L_STSdp', '1130.L_STSvp', '1176.L_STSva'],

rois= [[
        "8109.lh.LGN",
        "1001.L_V1",
        "1004.L_V2",
        "1005.L_V3",
        "1006.L_V4",
        "1023.L_MT",
        "1003.L_V6",
        "1010.L_FEF",
        "1047.L_7PC",
        "1063.L_8BM",
        "1087.L_9a",
        "1072.L_10d"],
        
        ]

        # ["1065.L_10r",
        # "1088.L_10v",
        # "1089.L_a10p",
        # "1090.L_10pp",
        # "1170.L_p10p"],

        # ["1074.L_44",
        # "1075.L_45",

        # "1083.L_p9-46v",
        # "1084.L_46",
        # "1085.L_a9-46v",
        # "1086.L_9-46d"],

        # ["1048.L_LIPv",
        # "1095.L_LIPd",
        # "2048.R_LIPv",
        # "2095.R_LIPd"],
rois = [
        ["1024.L_A1"],

        ["1128.L_STSda",
        "1129.L_STSdp",
        "1130.L_STSvp",
        "1176.L_STSva"], 

        ["1123.L_STGa"],

        ["1139.L_TPOJ1",
        "1140.L_TPOJ2",
        "1141.L_TPOJ3"]]


rois_flat = [ rr for r in rois for rr in r]

column_path="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/columns/columns_ev_1000_borders.downscaled2x_NN.nii.gz"
parc_path="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/multiAtlasTT/hcp-mmp-b/hcp-mmp-b.nii.gz"

img_columns = nib.load(column_path)
img_parc = nib.load(parc_path)

data_columns = img_columns.get_fdata()
data_parc = img_parc.get_fdata()

print(data_columns.shape)
print(data_parc.shape)

unq_columns = np.unique(data_columns)[1:]
unq_parc = np.unique(data_parc)[1:]

LUT_path = "/home/kleinrl/projects/laminar_fmri/tools/LUT_hcp-mmp-b_v2.txt"
df_LUT = pd.read_csv(LUT_path, delimiter=' ', header=None) 
df_LUT.columns=['id','lab','1','2','3','4']


d_id = dict()
d_lab = dict() 


for u_p in unq_parc: 

    inds = np.where(data_parc == u_p)

    cols = data_columns[inds]
    (unique, counts) = np.unique(cols, return_counts=True)

    sort_ind = np.argsort(counts).tolist()
    sort_ind.reverse()

    unique, counts = unique[sort_ind], counts[sort_ind]

    ind = unique != 0 
    unique = unique[ind] 
    counts = counts[ind]

    ind = counts > 10 
    unique = unique[ind] 
    counts = counts[ind]


    d_id[u_p] = {'unique':unique, 'counts':counts}
    try: 
        lab = df_LUT[df_LUT['id'] == int(u_p)][['id','lab']].values[0]
        lab = '{}.{}'.format(lab[0], lab[1])
    except Exception as e: 
        print(e)
        print("u_p: {}".format(u_p))


    d_lab[lab] = {'unique':unique, 'counts':counts}


###################


plotdir="./target_search_plots/"

csv_file="/data/kleinrl/Wholebrain2.0/fsl_feats/"+\
    "fsl_feats_DF-smoothed_inv_thresh_zstat1.L2D-columns_ev_1000_borders.downscaled2x_NN.equalcount.pkl"

df_all = pd.read_pickle(csv_file)




vs = [ v for v in df_all.columns if 'value' in v ] 

x = [ i for i in range(len(vs)) ]



ff_ps = np.array([-0.95088414, -0.59177142,  0.17633744,  1.4424729 ,  1.24481643,
    1.31553988,  0.18318057, -0.27174834, -1.28345969, -1.26448362])

fb_ps = np.array([-0.44530771,  0.60670543,  1.66233666,  0.66287436, -1.08918178,
    -0.30745872,  0.91616032,  0.65961318, -1.08541645, -1.58032529])

fb_ps = np.array([-1,  0.60670543,  .93,  0.66287436, -1.08918178,
    -0.30745872,  0.91616032,  0.65961318, 0.2, -1.08541645])

flat = np.linspace(0,0.01,10)
up   = np.linspace(-1,1,10)
down = np.linspace(1,-1,10)

templates = [flat, ff_ps, up, down, fb_ps]

targets_lab = [] 
targets = []
for lab in rois_flat: 
    if 'LGN' not in lab: 

        if "1006.L_V4" in lab:
            targets.append(791)
            targets_lab.append("1006.L_V4")
        else: 
            col = d_lab[lab]['unique']
            if col[0] != 0:
                targets.append(int(col[0]))
                targets_lab.append(lab)
            else: 
                targets.append(int(col[1]))
                targets_lab.append(lab)

        

# calc corrs 


# for s in rois_flat:
#     ind = (df_all.seed == s)
#     df_all = df_all[df_all.seed ==]


recalc_df_all = False 
if recalc_df_all == True: 

    fb_c    = []
    ff_c    = []
    flat_c  = []
    up_c    = []
    down_c  = []

    ff_or_fb = [] 
    ff_or_fb_val = []

    group = [] 

    for i in range(df_all.shape[0]):

        y = df_all[vs].iloc[i]
        y = (y-np.mean(y))/np.std(y)
        y = y.to_numpy()

        # fb_co = 1 - spatial.distance.cosine(fb_ps, y)
        # if fb_co != fb_co: 
        #     fb_co = 0

        # fb_c.append(fb_co)
        
        # ff_co = 1 - spatial.distance.cosine(ff_ps, y)
        # if ff_co != ff_co: 
        #     ff_co = 0

        # ff_c.append(ff_co)    
        
        # flat_co = 1 - spatial.distance.cosine(flat, y)
        # if flat_co != flat_co: 
        #     flat_co = 0

        # flat_c.append(flat_co)    
        
        # up_co = 1 - spatial.distance.cosine(up, y)
        # if up_co != up_co: 
        #     up_co = 0
        
        # up_c.append(up_co)

        # down_co = 1 - spatial.distance.cosine(down, y)
        # if down_co != down_co: 
        #     down_co = 0
        
        # down_c.append(down_co)


        fb_co = np.corrcoef(fb_ps, y)[0,1]
        if fb_co != fb_co: 
            fb_co = 0

        fb_c.append(fb_co)
        
        ff_co = np.corrcoef(ff_ps, y)[0,1]
        if ff_co != ff_co: 
            ff_co = 0

        ff_c.append(ff_co)    
        
        flat_co = np.corrcoef(flat, y)[0,1]
        if flat_co != flat_co: 
            flat_co = 0

        flat_c.append(flat_co)    
        
        up_co = np.corrcoef(up, y)[0,1]
        if up_co != up_co: 
            up_co = 0
        
        up_c.append(up_co)

        down_co = np.corrcoef(down, y)[0,1]
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
        #print(max_all)

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



    df_all['fb_corr']      = fb_c
    df_all['ff_corr']      = ff_c
    df_all['flat_corr']    = flat_c
    df_all['up_corr']      = up_c
    df_all['down_corr']    = down_c

    df_all['group']        = group
    df_all['ff_or_fb']     = ff_or_fb
    df_all['ff_or_fb_val'] = ff_or_fb_val

    with open('/data/kleinrl/Wholebrain2.0/fsl_feats/df_all.pkl', 'wb') as handle:
        pickle.dump(df_all, handle, protocol=pickle.HIGHEST_PROTOCOL)


else:
    with open('/data/kleinrl/Wholebrain2.0/fsl_feats/df_all.pkl', 'rb') as handle:
        df_all = pickle.load(handle)


#######################
# matrix plots

"""
plot all pcas 
"""
pca_grids_10pcas = False
if pca_grids_10pcas == True:

    for pca in range(10):
        x_i,y_i = len(rois_flat),len(rois_flat)
        fig = plt.figure(constrained_layout=True, figsize=(20,20))

        fig.suptitle('Targets', fontsize=20)
        fig.supylabel('Seeds', fontsize=20)

        spec = fig.add_gridspec(ncols=x_i, nrows=y_i)


        for i_seed in range(len(rois_flat)): 
            for i_target in range(len(targets)): 
                '''
                seed = rois_flat[0]
                target = targets[0]
                '''

                seed = rois_flat[i_seed]
                seed_lab = seed.split('.')[-1]

                target = targets[i_target]
                target_lab = targets_lab[i_target].split('.')[-1]

                row_count = 0 

                row = i_seed
                col = i_target
                print("row: {} col: {}".format(i_seed, i_target))
                # ind = (df_all.target == 791) & (df_all.seed == '1063.L_8BM')
                ind = (df_all.target == target) & (df_all.seed == seed)
                df = df_all[ind]
                pca_num = "pca_{:03d}".format(pca)

                #ind = (df.seed_pca == 'pca_000')
                ind = (df.seed_pca == pca_num)
                df = df[ind]


                ax = fig.add_subplot(spec[row, col])
                ax.set_xticklabels([])
                ax.set_yticklabels([])

                if col == 0:
                    ax.set_ylabel(seed_lab)

                if row == 0:
                    ax.set_title(target_lab)
                
                y = df.loc[df.seed == seed][vs].values.tolist() #.iloc[i] #to_plot.iloc[i,:]
                #y = (y-np.mean(y))/np.std(y)

                #plt.plot(x,y[0], color='white')
                plt.plot(x,y[0], color='black')

                # c = df.loc[df.seed == seed]['fb_corr']

                # color_val = int(c * 255 )
                # #ax.patch.set_alpha(0.75)
                # ax.set_facecolor(colors[color_val])


                # seed        = df.loc[df.seed == seed]['seed']
                # seed_pca    = df.loc[df.seed == seed]['seed_pca']
                # target      = df.loc[df.seed == seed]['target']
                # vol         = df.loc[df.seed == seed]['vol']
            

                # plt.title("{}\n{}".format(seed.values[0], round(c.values[0],3))) #split('.')[1]

        plt.savefig(plotdir + "matrix_ROI_{}_templates_plot.png".format(pca_num))
        plt.close()

""""
here we're trying to get single profile for each connection using some optimization over PCas
"""
single_pca_grid = True
if single_pca_grid == True:


    x_i,y_i = len(rois_flat),len(targets)
    fig = plt.figure(constrained_layout=True, figsize=(20,20))

    fig.suptitle('Targets', fontsize=20)
    fig.supylabel('Seeds', fontsize=20)

    #spec = fig.add_gridspec(ncols=x_i, nrows=y_i)
    spec = fig.add_gridspec(ncols=y_i, nrows=x_i)


    for i_seed in range(len(rois_flat)): 
        for i_target in range(len(targets)): 
            '''
            seed = rois_flat[0]
            target = targets[0]
            i_seed=4 
            i_target=6

            '''

            seed = rois_flat[i_seed]
            seed_lab = seed.split('.')[-1]

            target = targets[i_target]
            target_lab = targets_lab[i_target].split('.')[-1]

            row_count = 0 

            row = i_seed
            col = i_target
            print("row: {} col: {}".format(i_seed, i_target))
            # ind = (df_all.target == 791) & (df_all.seed == '1063.L_8BM')
            ind = (df_all.target == target) & (df_all.seed == seed)
            df = df_all[ind]

            df = df.sort_values('ff_or_fb_val', ascending=False)

            best_ff = df.sort_values('ff_corr', ascending=False).iloc[0]['ff_corr']
            best_fb = df.sort_values('fb_corr', ascending=False).iloc[0]['fb_corr']

            score_fffb = best_ff - best_fb 

            if best_ff > best_fb: 
                df = df.sort_values('ff_corr', ascending=False)
                y = df.iloc[0][vs].values.tolist()

                c = ((abs(best_ff)*125) + 125) / 255 

            else: 
                df = df.sort_values('fb_corr', ascending=False)
                y = df.iloc[0][vs].values.tolist()

                c = (125 - (abs(best_ff)*125)) / 255 




            #pca_num = "pca_{:03d}".format(pca)

            #ind = (df.seed_pca == 'pca_000')
            #ind = (df.seed_pca == pca_num)
            #df = df[ind]


            ax = fig.add_subplot(spec[row, col])
            ax.set_xticklabels([])
            ax.set_yticklabels([])

            if col == 0:
                ax.set_ylabel(seed_lab)

            if row == 0:
                ax.set_title(target_lab)
            
            #y = df.loc[df.seed == seed][vs].values.tolist() #.iloc[i] #to_plot.iloc[i,:]
            #y = (y-np.mean(y))/np.std(y)

            new_color_sch = False 
            if new_color_sch:
                plt.plot(x,y, color='white')
                
                # c = df.loc[df.seed == seed]['fb_corr']

                color_val = int(c * 255 )
                #ax.patch.set_alpha(0.75)
                ax.set_facecolor(colors[color_val])
            else: 
                plt.plot(x,y, color='black')




            # seed        = df.loc[df.seed == seed]['seed']
            # seed_pca    = df.loc[df.seed == seed]['seed_pca']
            # target      = df.loc[df.seed == seed]['target']
            # vol         = df.loc[df.seed == seed]['vol']
        

            # plt.title("{}\n{}".format(seed.values[0], round(c.values[0],3))) #split('.')[1]

    #plt.savefig(plotdir + "matrix_ROI_maxCorr_pca_templates_plot.png")
    plt.savefig(plotdir + "matrix_ROI_AUD_maxCorr_pca_templates_plot.png")
    plt.close()





single_best_ff_grid = True
if single_best_ff_grid == True:


    x_i,y_i = len(rois_flat),len(targets)
    fig = plt.figure(constrained_layout=True, figsize=(20,20))

    fig.suptitle('Targets', fontsize=20)
    fig.supylabel('Seeds', fontsize=20)

    #spec = fig.add_gridspec(ncols=x_i, nrows=y_i)
    spec = fig.add_gridspec(ncols=y_i, nrows=x_i)


    for i_seed in range(len(rois_flat)): 
        for i_target in range(len(targets)): 
            '''
            seed = rois_flat[0]
            target = targets[0]
            '''

            seed = rois_flat[i_seed]
            seed_lab = seed.split('.')[-1]

            target = targets[i_target]
            target_lab = targets_lab[i_target].split('.')[-1]

            row_count = 0 

            row = i_seed
            col = i_target
            print("row: {} col: {}".format(i_seed, i_target))
            # ind = (df_all.target == 791) & (df_all.seed == '1063.L_8BM')
            ind = (df_all.target == target) & (df_all.seed == seed)
            df = df_all[ind]

            # df = df.sort_values('ff_or_fb_val', ascending=False)

            # best_ff = df.sort_values('ff_corr', ascending=False).iloc[0]['ff_corr']
            # best_fb = df.sort_values('fb_corr', ascending=False).iloc[0]['fb_corr']

            # score_fffb = best_ff - best_fb 


            df = df.sort_values('ff_corr', ascending=False)
            y = df.iloc[0][vs].values.tolist()


            #pca_num = "pca_{:03d}".format(pca)

            #ind = (df.seed_pca == 'pca_000')
            #ind = (df.seed_pca == pca_num)
            #df = df[ind]


            ax = fig.add_subplot(spec[row, col])
            ax.set_xticklabels([])
            ax.set_yticklabels([])

            if col == 0:
                ax.set_ylabel(seed_lab)

            if row == 0:
                ax.set_title(target_lab)
            
            #y = df.loc[df.seed == seed][vs].values.tolist() #.iloc[i] #to_plot.iloc[i,:]
            #y = (y-np.mean(y))/np.std(y)

            #plt.plot(x,y[0], color='white')
            plt.plot(x,y, color='black')

            # c = df.loc[df.seed == seed]['fb_corr']

            # color_val = int(c * 255 )
            # #ax.patch.set_alpha(0.75)
            # ax.set_facecolor(colors[color_val])


            # seed        = df.loc[df.seed == seed]['seed']
            # seed_pca    = df.loc[df.seed == seed]['seed_pca']
            # target      = df.loc[df.seed == seed]['target']
            # vol         = df.loc[df.seed == seed]['vol']
        

            # plt.title("{}\n{}".format(seed.values[0], round(c.values[0],3))) #split('.')[1]

    plt.savefig(plotdir + "matrix_ROI_best_ff_pca_templates_plot.png")
    plt.close()


single_best_ff_grid = True
if single_best_ff_grid == True:


    x_i,y_i = len(rois_flat),len(targets)
    fig = plt.figure(constrained_layout=True, figsize=(20,20))

    fig.suptitle('Targets', fontsize=20)
    fig.supylabel('Seeds', fontsize=20)

    #spec = fig.add_gridspec(ncols=x_i, nrows=y_i)
    spec = fig.add_gridspec(ncols=y_i, nrows=x_i)


    for i_seed in range(len(rois_flat)): 
        for i_target in range(len(targets)): 

            seed = rois_flat[i_seed]
            seed_lab = seed.split('.')[-1]

            target = targets[i_target]
            target_lab = targets_lab[i_target].split('.')[-1]

            row_count = 0 

            row = i_seed
            col = i_target
            print("row: {} col: {}".format(i_seed, i_target))
            # ind = (df_all.target == 791) & (df_all.seed == '1063.L_8BM')
            ind = (df_all.target == target) & (df_all.seed == seed)
            df = df_all[ind]

            # df = df.sort_values('ff_or_fb_val', ascending=False)

            # best_ff = df.sort_values('ff_corr', ascending=False).iloc[0]['ff_corr']
            # best_fb = df.sort_values('fb_corr', ascending=False).iloc[0]['fb_corr']

            # score_fffb = best_ff - best_fb 


            df = df.sort_values('fb_corr', ascending=False)
            y = df.iloc[0][vs].values.tolist()


            #pca_num = "pca_{:03d}".format(pca)

            #ind = (df.seed_pca == 'pca_000')
            #ind = (df.seed_pca == pca_num)
            #df = df[ind]


            ax = fig.add_subplot(spec[row, col])
            ax.set_xticklabels([])
            ax.set_yticklabels([])

            if col == 0:
                ax.set_ylabel(seed_lab)

            if row == 0:
                ax.set_title(target_lab)
            
            #y = df.loc[df.seed == seed][vs].values.tolist() #.iloc[i] #to_plot.iloc[i,:]
            #y = (y-np.mean(y))/np.std(y)

            #plt.plot(x,y[0], color='white')
            plt.plot(x,y, color='black')

            # c = df.loc[df.seed == seed]['fb_corr']

            # color_val = int(c * 255 )
            # #ax.patch.set_alpha(0.75)
            # ax.set_facecolor(colors[color_val])


            # seed        = df.loc[df.seed == seed]['seed']
            # seed_pca    = df.loc[df.seed == seed]['seed_pca']
            # target      = df.loc[df.seed == seed]['target']
            # vol         = df.loc[df.seed == seed]['vol']
        

            # plt.title("{}\n{}".format(seed.values[0], round(c.values[0],3))) #split('.')[1]

    plt.savefig(plotdir + "matrix_ROI_best_fb_pca_templates_plot.png")
    plt.close()




all_pcas_grid = True
if all_pcas_grid == True:


    x_i,y_i = len(rois_flat),len(targets)
    fig = plt.figure(constrained_layout=True, figsize=(20,20))

    fig.suptitle('Targets', fontsize=20)
    fig.supylabel('Seeds', fontsize=20)

    #spec = fig.add_gridspec(ncols=x_i, nrows=y_i)
    spec = fig.add_gridspec(ncols=y_i, nrows=x_i)

    row_count = 0 

    for i_seed in range(len(rois_flat)): 
        for i_target in range(len(targets)): 

            seed = rois_flat[i_seed]
            seed_lab = seed.split('.')[-1]




            target = targets[i_target]
            target_lab_full = targets_lab[i_target]
            target_lab = target_lab_full.split('.')[-1]


            target_cols = d_lab[target_lab_full]

            for target in  target_cols['unique'].tolist(): 



                print("row: {} col: {}".format(i_seed, target))
                # ind = (df_all.target == 791) & (df_all.seed == '1063.L_8BM')







                row_count += 1 
                
                #col = i_target







                ind = (df_all.target == target) & (df_all.seed == seed)
                df = df_all[ind]

                # df = df.sort_values('ff_or_fb_val', ascending=False)

                # best_ff = df.sort_values('ff_corr', ascending=False).iloc[0]['ff_corr']
                # best_fb = df.sort_values('fb_corr', ascending=False).iloc[0]['fb_corr']

                # score_fffb = best_ff - best_fb 


                df = df.sort_values('fb_corr', ascending=False)
                y = df.iloc[0][vs].values.tolist()


                #pca_num = "pca_{:03d}".format(pca)

                #ind = (df.seed_pca == 'pca_000')
                #ind = (df.seed_pca == pca_num)
                #df = df[ind]


                ax = fig.add_subplot(spec[row, col])
                ax.set_xticklabels([])
                ax.set_yticklabels([])

                if col == 0:
                    ax.set_ylabel("{}-{}-{}".format(seed_lab, target_lab, target_col))

                if row == 0:
                    ax.set_title(target_lab)
                
                #y = df.loc[df.seed == seed][vs].values.tolist() #.iloc[i] #to_plot.iloc[i,:]
                #y = (y-np.mean(y))/np.std(y)

                #plt.plot(x,y[0], color='white')
                plt.plot(x,y, color='black')

                # c = df.loc[df.seed == seed]['fb_corr']

                # color_val = int(c * 255 )
                # #ax.patch.set_alpha(0.75)
                # ax.set_facecolor(colors[color_val])


                # seed        = df.loc[df.seed == seed]['seed']
                # seed_pca    = df.loc[df.seed == seed]['seed_pca']
                # target      = df.loc[df.seed == seed]['target']
                # vol         = df.loc[df.seed == seed]['vol']
            

                # plt.title("{}\n{}".format(seed.values[0], round(c.values[0],3))) #split('.')[1]

    plt.savefig(plotdir + "matrix_ROI_best_fb_pca_templates_plot.png")
    plt.close()

























#######################
# single ROI PCAS plots 


ind = (df_all.target == 791) & (df_all.seed == '1063.L_8BM')
df = df_all[ind]


x_i,y_i = 10,5
fig = plt.figure(constrained_layout=True, figsize=(10,10))
spec = fig.add_gridspec(ncols=x_i, nrows=y_i)

df = df.sort_values('seed_pca')

temp_corr = np.zeros(shape=(df.shape[0], len(templates)))

to_plot = df[vs].values 
for i in range(df.shape[0]):
    y = to_plot[i,:]
    y = (y-np.mean(y))/np.std(y)

    for ii in range(len(templates)): 
        template = templates[ii]
        c = np.corrcoef(y, template)[0,1]
        temp_corr[i,ii] = c





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

plt.savefig(plotdir + "single_ROI_PCAs_templates_plot.png")
plt.close()





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


# rois = [['1090.L_10pp', '1088.L_10v', '1065.L_10r', '1072.L_10d'], 
#         ['1087.L_9a', '1071.L_9p', '1069.L_9m', '1086.L_9-46d'], 
#         ['1070.L_8BL', '1063.L_8BM', '1067.L_8Av', '1073.L_8C', '1068.L_8Ad'],
#         ['1010.L_FEF'], 
#         ['1042.L_7AL', '1047.L_7PC', '1046.L_7PL','1029.L_7Pm', '1045.L_7Am','1030.L_7m'],
#         ['1006.L_V4'],
#         ['1007.L_V8','1016.L_V7','1003.L_V6', '1152.L_V6A','1023.L_MT'], 
#         ['8109.lh.LGN', '1001.L_V1', '1004.L_V2', '1005.L_V3', '1013.L_V3A','1019.L_V3B', '1158.L_V3CD']]


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
