#!/bin/bash

dir=$1

rm ${dir}/*.xyz
rm ${dir}/all_xyz.txt

touch ${dir}/all_xyz.txt

for roi in ${dir}/*1.nii
do
  get_xyz.sh $roi &
done


for xyz in ${dir}/*.xyz
do
  echo "`basename $xyz .xyz` `cat $xyz` "  >> ${dir}/all_xyz.txt
done
