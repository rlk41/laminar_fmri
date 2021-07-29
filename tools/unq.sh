#!/bin/bash

rm unq.txt

#todo
3dhistog $1 -unq > unq.txt

#awk -F "\"*,\"*" '{print $2}' unq.txt

#echo "$(tail -n +2 unq.txt)" > unq.txt

#awk '$2>0' unq.txt > unq.txt


cat unq.txt

