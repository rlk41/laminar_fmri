#!/bin/bash


while getopts ":t:n:b" flag
do
    case "${flag}" in
        t) col_type=${OPTARG};;
        n) col_num=${OPTARG};;
        b) borders='true';;
    esac
done

echo "column_type: ${col_type}"
echo "column_number: ${col_num}"

echo "acceptable column_types={equivol, equidist} "

# PARAMS ###################################
#col_type='equivol'
#col_num=1000
############################################

curr_dir=`pwd`


if [ -z $borders ]
then
  col_dir="columns_${col_type}_${col_num}"
  echo "borders unset"
else 

  col_dir="columns_${col_type}_${col_num}_borders"
  echo "borders set" 
fi 

echo 'col_dir: ' ${col_dir}
mkdir -p ${col_dir}


cp rim.nii rim_midGM_equi* ${col_dir}/
cd ${col_dir}


# todo: LUT file !!!!!!!! NEED to fix !!!!!!!!!!!!!!!!!!!!!!!!!!!
LUT_col="LUT_columns_${col_num}_${col_type}.txt"
touch $LUT_col
for c in `seq 1 $((col_num))`; do
  echo "$c $c" >> $LUT_col
done

#echo "including borders!!"
# generate columns
if [ -z $borders ]
then
  echo "running LN2_COLUMNS"
  LN2_COLUMNS -rim rim.nii -midgm rim_midGM_${col_type}.nii -nr_columns ${col_num}
else
  echo "running LN2_COLUMNS -incl_borders"
  LN2_COLUMNS -rim rim.nii -midgm rim_midGM_${col_type}.nii -nr_columns ${col_num} -incl_borders
fi 



cd $curr_dir



#
## PARAMS ###################################
#col_type='equivol'
#col_num=1000
#############################################
#col_dir="${layer4EPI}/columns_${col_type}_${col_num}"
#echo 'col_dir: ' ${col_dir}
#mkdir ${col_dir}
#
#
#cp $layer4EPI/rim.nii $layer4EPI/rim_midGM_equi* ${col_dir}/
#cd ${col_dir}
#
#
## todo: LUT file !!!!!!!! NEED to fix !!!!!!!!!!!!!!!!!!!!!!!!!!!
#LUT_col="${layer4EPI}/${col_dir}/LUT_columns_${col_num}_${col_type}.txt"
#touch $LUT_col
#for c in `seq 1 $((col_num))`; do
#  echo "$c $c" >> $LUT_col
#done
#
#
## generate columns
#LN2_COLUMNS -rim rim.nii -midgm rim_midGM_${col_type}.nii -nr_columns ${col_num}
#cd ..
#
#################################################
## PARAMS ###################################
#col_type='equidist'
#col_num=19000
#############################################
#col_dir='columns_'${col_type}'_'${col_num}
#echo 'col_dir: ' ${col_dir}
#mkdir ${col_dir}
#cp rim.nii rim_midGM_equi* ${col_dir}/
#cd ${col_dir}
#LN2_COLUMNS -rim rim.nii -midgm rim_midGM_${col_type}.nii -nr_columns ${col_num}
#cd ..
#################################################
#
#
## PARAMS ###################################
#col_type='equidist'
#col_num=38000
#############################################
#col_dir='columns_'${col_type}'_'${col_num}
#echo 'col_dir: ' ${col_dir}
#mkdir ${col_dir}
#cp rim.nii rim_midGM_equi* ${col_dir}/
#cd ${col_dir}
#LN2_COLUMNS -rim rim.nii -midgm rim_midGM_${col_type}.nii -nr_columns ${col_num}
#cd ..
#################################################
#
#
## PARAMS ###################################
#col_type='equidist'
#col_num=1000
#############################################
#col_dir='columns_'${col_type}'_'${col_num}
#echo 'col_dir: ' ${col_dir}
#mkdir ${col_dir}
#cp rim.nii rim_midGM_equi* ${col_dir}/
#cd ${col_dir}
#LN2_COLUMNS -rim rim.nii -midgm rim_midGM_${col_type}.nii -nr_columns ${col_num}
##todo: add this to other resample affines are off
#
#cd ..
#################################################