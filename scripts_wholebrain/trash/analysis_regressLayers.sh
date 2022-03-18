#!/bin/bash 
set -e 

echo "running analysis_regressLayers.sh"



for EPI in $VASO_func_dir/*movie*VASO.nii
do 
    echo $EPI 
    source /home/kleinrl/projects/laminar_fmri/paths_biowulf 
    log="/home/kleinrl/projects/laminar_fmri/logs/surfLayers-${EPI_base}.log"
    job_name="surfLayers"

    echo "  "
    echo "EPI: ${EPI}"
    echo "  "
    echo "LOG: ${log}"
    echo "  "

    sbatch --mem=10g --cpus-per-task=5 \
    --partition=norm \
    --output=$log \
    --time 10:00:00 \
    --job-name=$job_name \
    main_surfLayers.sh $EPI

done 


# >> JOBLIST DEPENDENY 

# NEED TO ADD DEPENDENCY HERE 


# mkdir -p bad_data
# mv sub-01_ses-01*run-01* bad_data
# mv sub-01_ses-04*run-01* bad_data
# mv sub-01_ses-04*run-02* bad_data
# mv sub-01_ses-04*run-03* bad_data
# mv sub-01_ses-04*run-05* bad_data




echo "done running surf layers"
echo "running regressLayers"


EPIs=($VASO_func_dir/*movie*VASO.nii)
EPIs_len=$((${#EPIs[@]}-1))
cores=5

job_list="/home/kleinrl/projects/laminar_fmri/logs/jobs_regressLayers.txt"
touch $job_list

seed_pca=1
control_pca=0

job_name="regressLayers_seedpca-${seed_pca}_controlpca${control_pca}"

pkl_dir="/data/kleinrl/pkls_sPCA-${seed_pca}_cPCA-${control_pca}/"
rm -rf $pkl_dir

vert_base="*white.surf-fwhm-2.vol-fwhm-NA.fsaverage.mgh"
columns=""

cmds=$cmds_dir/regressLayers_cmds.txt
rm $cmds 

for i in $(seq 0 $EPIs_len); do
   for j in $(seq $i $EPIs_len); do        
        log="/home/kleinrl/projects/laminar_fmri/logs/${job_name}-$i-$j-${EPI_base}.log"

        seed=${EPIs[$i]} 
        target=${EPIs[$j]}

        echo "           "
        echo "singleROI"
        echo "SEED:         $i $seed"
        echo "Targets:      $j $target"
        echo "pkl_dir:      $pkl_dir"
        echo "cores:        $cores"
        echo "seed_pca:     $seed_pca"
        echo "control_pca:  $control_pca"
        echo "vert_base:    $vert_base"
        echo "-----------------"
        #echo "regressLayers.job  $seed $target $cores $pkl_dir $seed_pca $control_pca $vert_base"

        sbatch --mem=5g --cpus-per-task=$cores \
        --partition=norm \
        --output=$log \
        --time 10:00 \
        --job-name=$job_name \
        regressLayers.job  $seed $target $cores $pkl_dir \
        $seed_pca $control_pca $vert_base $columns >> $job_list 

        echo "regressLayers.job  $seed $target $cores $pkl_dir $seed_pca $control_pca $vert_base $columns" >> $cmds

    done
done 

cat $job_list 


echo "aggregating verts "

aggregate_verts.py --pkl_dir $pkl_dir




##########

# EPIs=($VASO_func_dir/*movie*VASO.nii)
# EPIs_len=${#EPIs[@]}
# cores=5

# job_list="/home/kleinrl/projects/laminar_fmri/logs/jobs_regressLayers.txt"
# touch $job_list

# vert_base="*white.surf-fwhm-2.vol-fwhm-NA.fsaverage.mgh"

# for seed_pca in  $(seq 0 10); do
#     for control_pca in  $(seq 0 10); do
#         for i in $(seq 0 $EPIs_len); do
#             for j in $(seq $i $EPIs_len); do 
                

#                 job_name="regressLayers_seedpca-${seed_pca}_controlpca${control_pca}"

#                 pkl_dir="/data/kleinrl/pkls_sPCA-${seed_pca}_cPCA-${control_pca}/"


#                 log="/home/kleinrl/projects/laminar_fmri/logs/${job_name}-$i-$j-${EPI_base}.log"

#                 seed=${EPIs[$i]} 
#                 target=${EPIs[$j]}

#                 echo "SEED:    $i $seed"
#                 echo "Targets: $j $target"
#                 echo "pkl_dir: $pkl_dir"
#                 echo "          "


#                 sbatch --mem=10g --cpus-per-task=$cores \
#                 --partition=norm \
#                 --output=$log \
#                 --time 1:00:00 \
#                 --job-name=$job_name \
#                 regressLayers.job  $seed $target $cores $pkl_dir $seed_pca $control_pca $vert_base >> $job_list 


#             done
#         done 
#     done 
# done 



# cat $job_list 

for pkl_dir in /data/kleinrl/pkls_sPCA*; do 


        #pkl_dir="/data/kleinrl/pkls_sPCA-${seed_pca}_cPCA-${control_pca}/"
        # pkl_dir="/data/kleinrl/pkls_sPCA-1_cPCA-0"

        echo "aggregating verts "

        aggregate_verts.py --pkl_dir $pkl_dir

done 



