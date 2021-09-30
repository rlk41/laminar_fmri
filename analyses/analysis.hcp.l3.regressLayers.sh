#!/bin/bash 
set -e 

"""


"""

# analysis output firectory 
export analysis_hcp_l3_regressLayers="$layer4EPI/analysis.hcp.l3.regress_layers"
mkdir -p $analysis_hcp_l3_regressLayers

# PICK SEED ROI. HCP ATLAS 
#     - WHOLE ROI 
#     - ROI BY LAYER 
#     - THALAMIC ROI 

seed=$rois_hcp/1001.L_V1.nii 

# seed=$rois_hcpl3/1001.L_V1.1.nii 
# seed=$rois_hcpl3/1001.L_V1.2.nii 
# seed=$rois_hcpl3/1001.L_V1.3.nii 

# seed=$rois_thalamic/8109.lh.LGN.nii 

mask=$rois_hcp/1001.L_V1.nii
out_base=$(basename $mask .nii)

3dpc -prefix $out_base.nii \
    -vmean -vnorm \
    -reduce 10 $out_base.reduced10.1D \
    -mask $mask \
    $EPI

    #-pcsave ALL \


extract_parc_pca.py  \
--seed $seed \
--layers $warp_layers_ev_n3 \
--columns $warp_parc_hcp \ 
--epi $EPI \ 
--outdir $analysis_hcp_l3_regressLayers