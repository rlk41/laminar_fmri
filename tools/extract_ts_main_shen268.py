import pandas as pd

# parcellation HCPMMP
LUT_file = '/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects/warped_MP2RAGE/multiAtlasTT/shen268cort/LUT_shen268cort.txt'
lut = pd.read_table(LUT_file, sep=' ', header=None, names=['ID', 'ROI', 'R', 'G', 'B', 'T'])

with open('cmds/cmds_extract_ts.shen268.n10.txt','w') as w:

    for i in range(lut.shape[0]):
        id = lut['ID'].iloc[i]
        roi = lut['ROI'].iloc[i]

        for i_layer in range(1,11):
            w.writelines('python ./extract_ts.shen268.n10.py --roi_name {} --id_roi {} --id_layer {} \n'.format(roi, id, i_layer))



# # parallel --jobs 30 < cmds_extract_ts.txt


