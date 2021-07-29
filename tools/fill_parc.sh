#!/bin/bash

# this script uses a text file with 2 columns to fill a parc file with values
#


while getopts ":r:e:m:j:o:c:" flag
do
    case "${flag}" in
        r) roi_dir=${OPTARG};;
        e) EPI=${OPTARG};;
        j) jobs=${OPTARG};;
        o) out=${OPTARG};;
        c) cmds=${OPTARG};;
    esac
done
