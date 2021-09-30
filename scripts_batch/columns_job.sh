#!/bin/bash 
set -e 

# sbatch --mem=20g --cpus-per-task=10 --output=$log/layers_job_$EPI_base layers_job.sh

cd $layer_dir 

LN2_LAYERS -rim rim.nii -equivol -iter_smooth 50 -debug
generate_columns.sh -t "equivol" -n 1000
generate_columns.sh -t "equivol" -n 1000 -b


generate_columns.sh -t "equidist" -n 1000

generate_columns.sh -t "equivol" -n 10000
generate_columns.sh -t "equidist" -n 10000

echo "DONE"

