#!/bin/bash 


# sbatch --mem=20g --cpus-per-task=2 \
# --output="$logs/build_columns.log" \
# --time 48:00:00 \
# --job-name="build_col_scaled" \
# "$scripts_batch_dir/build_columns.sh"


#source_wholebrain2

source /home/kleinrl/projects/laminar_fmri/paths_wholebrain2.0

cd $layer_dir/columns 


#cp ../rim.nii . 
#cp ../layers/rim_equidist_n10_midGM_equidist.nii . 


# 10000 columns 
# LN2_COLUMNS -rim rim.nii -midgm rim_equidist_n10_midGM_equidist.nii \
# -nr_columns 10000 \
# -incl_borders -output 'columns_ev_10000_borders.nii'

# mv columns_ev_10000_borders_columns10000.nii columns_ev_10000_borders.nii




# # 30000 columns 
# LN2_COLUMNS -rim rim.nii -midgm rim_equidist_n10_midGM_equidist.nii \
# -centroids columns_ev_10000_borders_centroids10000.nii -nr_columns 30000 \
# -incl_borders -output 'columns_ev_30000_borders.nii'

# mv columns_ev_30000_borders_columns30000.nii columns_ev_30000_borders.nii



# 50000
LN2_COLUMNS -rim rim.nii -midgm rim_equidist_n10_midGM_equidist.nii \
-centroids columns_ev_30000_borders_centroids30000.nii -nr_columns 50000 \
-incl_borders -output 'columns_ev_50000_borders.nii'

mv columns_ev_50000_borders_columns50000.nii columns_ev_50000_borders.nii


# 70000
LN2_COLUMNS -rim rim.nii -midgm rim_equidist_n10_midGM_equidist.nii \
-centroids columns_ev_50000_borders_centroids50000.nii -nr_columns 70000 \
-incl_borders -output 'columns_ev_70000_borders.nii'

mv columns_ev_70000_borders_columns70000.nii columns_ev_70000_borders.nii


# 100000
LN2_COLUMNS -rim rim.nii -midgm rim_equidist_n10_midGM_equidist.nii \
-centroids columns_ev_70000_borders_centroids70000.nii -nr_columns 100000 \
-incl_borders -output 'columns_ev_100000_borders.nii'

mv columns_ev_100000_borders_columns100000.nii columns_ev_100000_borders.nii

