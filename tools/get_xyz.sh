#!/bin/bash

roi=$1
#roi="2036.R_5m.1.nii"

x=`3dmaskdump -mask $roi $roi | awk '{ total += $1 } END { print total/NR }'` # >> "$(basename $roi .nii).xyz"
y=`3dmaskdump -mask $roi $roi | awk '{ total += $2 } END { print total/NR }'` # >> "$(basename $roi .nii).xyz"
z=`3dmaskdump -mask $roi $roi | awk '{ total += $3 } END { print total/NR }'` # >> "$(basename $roi .nii).xyz"

echo "$x $y $z"
echo "$x $y $z" >  "$(basename $roi .nii).xyz"