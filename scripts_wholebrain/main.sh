#!/bin/bash

cwd=`pwd`
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

echo "moving to parent dir: ${parent_path}"
cd "$parent_path"



# this is the general workflow
# i've been using hcp but easy to replace with columns

# preprocessing of the ANAT, build rim, layers, columns, rois
# inputs: $ANAT
# outputs: $leakylayers3 $rim $parc_hcp $columns_ev_1000
./main_ANAT.sh

# preprocessing of the EPIs, build ANTs xfm, transform layers, columns, rois into EPI space
./main_EPI_looper.sh


# run analyses

# generate plots uses python
# this does get p-values from r-values but I need to separate out
# and do non-parametric stats over all r-values
# at least easiest way I could think of doing it
../analyses/analysis.hcp.l3.plots.sh

# hierarchical agglomerative clustering, generates plots, generates graph-ish (todo)
../analyses/analysis.hcp.l3.cluster.sh

# partial correlations but couldn't get to generate results, maybe need more data
../analyses/analysis.hcp.l3.PartialCorrs.sh

# runs 3dAutoTCorr - need to figure out how to deal with all volumes, average then extract layer/col mean corr
../analyses/analysis.hcp.l3.3dAutoTCorrs.sh

# extend the 3dAutoTCorr anaysis to evaluate connectivity base on corr across layers then iteratviely run to step
# to next seed and rerun...
../analyses/analysis.hcp.l3.seed2seed.sh
