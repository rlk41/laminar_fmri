# laminar_fmri

./paths - source this file for variables 
      - need to set spm_dir, ds_dir, EPI_base (ideally loop main_EPI.sh with new EPI_base var the source paths for each run). 


./scripts directory
    main_ANAT.sh - preprocess the MP2RAGE, builds rim, columns, rois, 
    main_EPI_looper.sh (TODO)
        main_EPI.sh - for each EPI, preprocess EPI, xfm rim, col, rois to EPI space, and extract timeseries



./analyses - ideal is once you have the matrix/dataframe of timeseries (build_matrix.sh or build_dataframe.py) you can runthe analyses 
    c1k.l3 - 1000 columns intersected by 3 layers 
    hcp.l3 - 1000 columns intersected by hcp parcelation 

    analysis.hcp.l3.cluster.sh - hierarchrical agglomerative clustering 
    analysis.hcp.l3.plots.sh - generate plots 


TODO
    statistics - non-parametric across all r-values - included in ploting mech
    graph - 
    plot clusters on brain (vol,surf) 
    partial correlations - DensPars package - couldn't get to work need more data ~110 timepoints now
    nordicICA
    fix columns 

