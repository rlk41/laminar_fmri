# laminar_fmri

## ./reports 
* checkout 07.28.2021.pdf for some figures 

## ./paths 
* source this file for variables 
* need to set **$spm_dir**, **$ds_dir (data_dir)**, **$EPI** (ideally loop main_EPI.sh with main_EPI_looper.sh setting new $EPI each loop). 


## ./scripts 
* **main.sh** - topmost - runs **main_ANAT.sh** (once) then **main_EPI_looper.sh** runs **main_EPI.sh** (foreach EPI)
  * **main_ANAT.sh** - preprocess the MP2RAGE, builds rim, columns, rois, 
  * **main_EPI_looper.sh**
    * **main_EPI.s** - for each EPI, preprocess EPI, xfm rim, col, rois to EPI space, and extract timeseries



## ./analyses 
once you have the matrix/dataframe of timeseries (build_matrix.sh or build_dataframe.py) you can run the analyses 
* c1k.l3 - 1000 columns intersected by 3 layers 
* hcp.l3 - 1000 columns intersected by hcp parcelation 

* **analysis.hcp.l3.plots.sh** - generate plots uses python this does get p-values from r-values but I need to separate out and do non-parametric stats over all r-values at least easiest way I could think of doing it

* **analysis.hcp.l3.cluster.sh** - hierarchical agglomerative clustering, generates plots, generates graph-ish (todo)

* **analysis.hcp.l3.PartialCorrs.sh** - partial correlations but couldn't get to generate results, maybe need more data

* **analysis.hcp.l3.3dAutoTCorrs.sh** - runs 3dAutoTCorr - need to figure out how to deal with all volumes, average then extract layer/col mean corr

* **analysis.hcp.l3.seed2seed.sh** - extend the 3dAutoTCorr anaysis to evaluate connectivity base on corr across layers then iteratviely run to step to next seed and rerun...




## TODO
* statistics - non-parametric across all r-values - included in ploting mech
  * or just bonferoni correction? 
* Visualizing clusters
  * graph - almost in analysis.hcp.l3.cluster.sh but too many edges to plot
  * plot clusters on brain (vol,surf) 
* partial correlations - DensPars package - couldn't get to work need more data (?) ~110 timepoints now
* nordicICA
* fix columns 
* look into converting to c++?

