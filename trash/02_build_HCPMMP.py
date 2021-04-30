
import os
import mne
from surfer import Brain

# conda activate nipype

## ~/anaconda3/envs/nipype/lib/python3.8/site-packages/mne/datasets/utils.py


#data_dir            = '/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/Projects/turkeltaub_gruffalo_v2/data'
#data_dir_fs         = os.path.join(data_dir, '03_easy_lausanne')

#subjects_dir = data_dir_fs
subjects_dir = '/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/subjects'
#urls = dict(lh='https://ndownloader.figshare.com/files/5528816',
#            rh='https://ndownloader.figshare.com/files/5528819')

# Need to edit permissions on /usr/local/freesurfer/subjects to
# download/edit files:
#        chmod richard -R label
# change back when done

mne.datasets.fetch_hcp_mmp_parcellation(subjects_dir=subjects_dir,
                                        verbose=True)

mne.datasets.fetch_hcp_mmp_parcellation(subjects_dir=subjects_dir,
                                        verbose=True, combine=True)

mne.datasets.fetch_aparc_sub_parcellation(subjects_dir=subjects_dir,
                                          verbose=True)


#brain.add_annotation('HCPMMP1')
# brain = Brain('fsaverage', hemi, 'inflated', subjects_dir=subjects_dir,
#               cortex='low_contrast', background='white', size=(800, 600))


#labels = [label for label in labels_HCP if label.name == 'L_A1_ROI-lh'][0]
import matplotlib
import numpy as np

cmap = matplotlib.cm.get_cmap('nipy_spectral')

sub_EL = 'HUT'
clust_total=30
colors_cmap = []
for c in np.linspace(0,1,clust_total):
    colors_cmap.append(cmap(c))


for hemi in ['lh','rh']:
    brain = Brain('fsaverage', hemi, 'inflated', subjects_dir=subjects_dir,
                  cortex='low_contrast', background='white', size=(800, 600))
    if scale == 'HCPMMP1':
        labels_HCP = mne.read_labels_from_annot(
            'fsaverage', 'HCPMMP1', hemi , subjects_dir=subjects_dir)

    elif scale in ['36','60','125','250']:
        labels_HCP = mne.read_labels_from_annot(
            sub_EL, '{}.myaparc_{}.annot'.format(hemi,scale), subjects_dir=subjects_dir)

    for clust in range(clust_total):
        labels = []
        for label in branch_dict[clust_total][clust]:
            l_hemi, l_base = label.split('.')
            label_branch = '{}-{}'.format(l_base, l_hemi)
            for label_HCP in labels_HCP:
                if label_branch == label_HCP.name:
                    labels.append(label_HCP)

        for label in labels:
            brain.add_label(label, borders=False, color=colors_cmap[clust])


    brain.save_image(filename=os.path.join(plot_dir, '{}.Clusters_{}.{}.jpeg'.format(header,clust_total,hemi)) )







labels_HCP = mne.read_labels_from_annot(
    'fsaverage', 'HCPMMP1', 'lh', subjects_dir=subjects_dir)

brain = Brain('fsaverage', 'lh', 'inflated', subjects_dir=subjects_dir,
              cortex='low_contrast', background='white', size=(800, 600))

brain.add_annotation('HCPMMP1')
aud_label = [label for label in labels_HCP if label.name == 'L_A1_ROI-lh'][0]
brain.add_label(aud_label, borders=False)

#####################################################################

import os
main_dir = '/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/Projects/turkeltaub_gruffalo_v2/'
sub_dir = os.path.join(main_dir, 'data/03_easy_lausanne')

os.environ['SUBJECTS_DIR'] = sub_dir
import sys
sys.path.append('/home/richard/bin')
from parallelize import parallelize

annot_bases    = ['HCPMMP1.annot', 'HCPMMP1_combined.annot']
subs        = [ sub for sub in os.listdir(sub_dir) if 'fsaverage' not in sub ]
hemis       = ['rh','lh']
cmds = []
for sub in subs:
    for hemi in hemis:
        for annot_base in annot_bases:
            annot = "{}.{}".format(hemi,annot_base)
            cmd = "mri_surf2surf \
            --srcsubject fsaverage \
            --trgsubject {} \
            --hemi {} \
            --sval-annot $SUBJECTS_DIR/fsaverage/label/{} \
            --tval       $SUBJECTS_DIR/{}/label/{}"\
                .format(sub, hemi, annot, sub, annot)
            print(cmd)
            cmds.append(cmd)

with open(os.path.join(main_dir,'cmds.txt'), 'w') as handle:
    for cmd in cmds:
        handle.write("{}\n".format(cmd))


# parallel --jobs 30 < cmds.txt

#parallelize(cmd, )



'''
groups = dict([
            ('Primary Visual Cortex (V1)',
             ('V1',)),
            ('Early Visual Cortex',
             ('V2', 'V3', 'V4')),
            ('Dorsal Stream Visual Cortex',
             ('V3A', 'V3B', 'V6', 'V6A', 'V7', 'IPS1')),
            ('Ventral Stream Visual Cortex',
             ('V8', 'VVC', 'PIT', 'FFC', 'VMV1', 'VMV2', 'VMV3')),
            ('MT+ Complex and Neighboring Visual Areas',
             ('V3CD', 'LO1', 'LO2', 'LO3', 'V4t', 'FST', 'MT', 'MST', 'PH')),
            ('Somatosensory and Motor Cortex',
             ('4', '3a', '3b', '1', '2')),
            ('Paracentral Lobular and Mid Cingulate Cortex',
             ('24dd', '24dv', '6mp', '6ma', 'SCEF', '5m', '5L', '5mv',)),
            ('Premotor Cortex',
             ('55b', '6d', '6a', 'FEF', '6v', '6r', 'PEF')),
            ('Posterior Opercular Cortex',
             ('43', 'FOP1', 'OP4', 'OP1', 'OP2-3', 'PFcm')),
            ('Early Auditory Cortex',
             ('A1', 'LBelt', 'MBelt', 'PBelt', 'RI')),
            ('Auditory Association Cortex',
             ('A4', 'A5', 'STSdp', 'STSda', 'STSvp', 'STSva', 'STGa', 'TA2',)),
            ('Insular and Frontal Opercular Cortex',
             ('52', 'PI', 'Ig', 'PoI1', 'PoI2', 'FOP2', 'FOP3',
              'MI', 'AVI', 'AAIC', 'Pir', 'FOP4', 'FOP5')),
            ('Medial Temporal Cortex',
             ('H', 'PreS', 'EC', 'PeEc', 'PHA1', 'PHA2', 'PHA3',)),
            ('Lateral Temporal Cortex',
             ('PHT', 'TE1p', 'TE1m', 'TE1a', 'TE2p', 'TE2a',
              'TGv', 'TGd', 'TF',)),
            ('Temporo-Parieto-Occipital Junction',
             ('TPOJ1', 'TPOJ2', 'TPOJ3', 'STV', 'PSL',)),
            ('Superior Parietal Cortex',
             ('LIPv', 'LIPd', 'VIP', 'AIP', 'MIP',
              '7PC', '7AL', '7Am', '7PL', '7Pm',)),
            ('Inferior Parietal Cortex',
             ('PGp', 'PGs', 'PGi', 'PFm', 'PF', 'PFt', 'PFop',
              'IP0', 'IP1', 'IP2',)),
            ('Posterior Cingulate Cortex',
             ('DVT', 'ProS', 'POS1', 'POS2', 'RSC', 'v23ab', 'd23ab',
              '31pv', '31pd', '31a', '23d', '23c', 'PCV', '7m',)),
            ('Anterior Cingulate and Medial Prefrontal Cortex',
             ('33pr', 'p24pr', 'a24pr', 'p24', 'a24', 'p32pr', 'a32pr', 'd32',
              'p32', 's32', '8BM', '9m', '10v', '10r', '25',)),
            ('Orbital and Polar Frontal Cortex',
             ('47s', '47m', 'a47r', '11l', '13l',
              'a10p', 'p10p', '10pp', '10d', 'OFC', 'pOFC',)),
            ('Inferior Frontal Cortex',
             ('44', '45', 'IFJp', 'IFJa', 'IFSp', 'IFSa', '47l', 'p47r',)),
            ('DorsoLateral Prefrontal Cortex',
             ('8C', '8Av', 'i6-8', 's6-8', 'SFL', '8BL', '9p', '9a', '8Ad',
              'p9-46v', 'a9-46v', '46', '9-46d',)),
            ('???',
             ('???',))])

'''