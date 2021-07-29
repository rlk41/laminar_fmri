#!/bin/bash

while getopts ":t:m:l:" flag
do
    case "${flag}" in
        t) timeseries_paths+=("$OPTARG");;
        m) matrix=${OPTARG};;
        l) labs=${OPTARG};;
    esac
done

shift $((OPTIND -1))


echo "USAGE: build_matrix.sh -t $timeseries_hcpl3 -t $timeseries_thalamic -m $matrix_hcpl3_thalamic -l $labs_hcpl3_thalamic  "

rm -rf $out
mkdir -p $out


rm $labs $matrix ${matrix}.tmp
touch $labs $matrix

echo "timeseries_paths: $timeseries_paths"
echo "out: $out"

echo "gathering files"
# gather all files to past together columns wise into matrix
files=()
for path in "${timeseries_paths[@]}"
  do
    files+=($path/*.1D)
  done


echo "pasting files: n=${#files[@]}"
i=1
for file in "${files[@]}"
  do
    # build matrix
    cat $matrix | paste - $file > ${matrix}.tmp
    cp ${matrix}.tmp $matrix

    # build lab table
    base=$(basename $file .txt)
    splits=$(echo $base | sed 's/\./ /g')
    echo "${splits}" >> $labs

    echo "$i"
    i=$(expr $i + 1)

  done

rm ${matrix}.tmp


echo "DONE: "
echo "      ${matrix}"
echo "      ${labs}"
