
source paths

# demo
# @Install_SURFLAYERS_DEMO1


cd $suma_dir

SurfLayers                          \
    -surf_A rh.smoothwm.gii         \
    -surf_B rh.pial.gii             \
    -n_intermed_surfs 3             \
    -outdir surfRH


# mri_expand

# mri_surf2vol



# start suma

echo "++ anat dset is: ${dir_afni}/${dset_anat}"

echo "++ move into output 'surfRH/' directory"
cd ${dir_suma}/surfRH

echo "++ open RH set of surfaces with suma"
suma -onestate                                       \
     -i  rh.smoothwm.gii isurf.rh.*.gii rh.pial.gii  \
     -sv ${dir_afni}/${dset_anat}   &

sleep 1

echo "++ make window larger, move around to get better view,"
echo "   zoom, start talking"
DriveSuma                                           \
    -com viewer_cont -viewer_size 700 700           \
    -com viewer_cont -key 'Ctrl+Shift+down'         \
    -com viewer_cont -key:r8 'Z'                    \
    -com viewer_cont -key 't'


# SurfClust


'''
https://www.biorxiv.org/content/10.1101/337667v1.full.pdf
mris_expand, we generated cortical surfaces positioned at different depths of the gray
17 matter. Specifically, we constructed 6 surfaces spaced equally between 10% and 90% of the distance
18 between the pial surface and the boundary between gray and white matter (see Figure 2). We also
19 increased the density of surface vertices using mris_mesh_subdivide. This bisected each edge and
20 resulted in a doubling of the number of vertices. Finally, to reduce computational burden, we truncated
21 the surfaces to include only posterior portions of cortex (since this is where functional measurements are
22 made)
Flattened versions of cortical surfaces were also generated. We cut a cortical patch covering ventral
25 temporal cortex (VTC) and a cortical patch covering early visual cortex (EVC), and flattened these
26 patches using mris_flatten. The patches were then scaled in size such that the edge lengths in the
27 flattened surfaces match, on average, the edge lengths in the corresponding white-matter surfaces (an
28 exact match is impossible given the distortions inherent in flattening). This makes it possible to interpret
29 the flattened surfaces with respect to quantitative units (e.g., see Figure 10).

cvnlookupimages

'''



'''
Overview ~1~

This program makes a *.spec file after a set of intermediate surfaces
have been generated with SurfLayers.

It can also make a *.spec file that relates inflated surfaces to
anatomically-correct surfaces. An example of this is shown below in
the "Usage Example" section.

Options ~1~

  -surf_A   SA   :inner (anatomically-correct) boundary surface dataset
                  (e.g. smoothwm.gii)

  -surf_B   SB   :outer (anatomically-correct) boundary surface dataset
                  (e.g. pial.gii)

  -surf_intermed_pref  SIP
                 :prefix for (anatomically-correct) intermediate surfaces,
                  typically output by SurfLayers
                  (def: isurf)

  -infl_surf_A  ISA
                 :inner (inflated) boundary surface dataset
                  (e.g. infl.smoothwm.gii)

  -infl_surf_B  ISB
                 :outer (inflated) boundary surface dataset
                  (e.g. infl.pial.gii)

  -infl_surf_intermed_pref  ISIP
                 :prefix for (inflated) intermediate surfaces,
                  typically output by SurfLayers
                  (def: infl.isurf)

  -both_lr       :specify an output spec for both hemispheres,
                  if surfaces for both exist

  -out_spec      :name for output *.spec file
                  (def: newspec.spec)

Examples ~1~

  1)

    quickspecSL                                  \
        -surf_A    lh.white.gii                  \
        -surf_B    lh.pial.gii                   \
        -surf_intermed_pref  lh.isurf


  2)

    quickspecSL                                  \
        -both_lr                                 \
        -surf_A lh.white.gii                     \
        -surf_B lh.pial.gii


  3) First, make inflated boundary surfaces before running SurfLayers
     on the both those and the original surfaces:

    SurfSmooth -i rh.smoothwm.gii -met NN_geom -Niter 240    \
        -o_gii -surf_out rh.inf.smoothwm_240 -match_size 9

    SurfSmooth -i rh.pial.gii -met NN_geom -Niter 240        \
        -o_gii -surf_out rh.inf.pial_240 -match_size 9

    quickspecSL                                              \
        -surf_A             rh.white.gii                     \
        -surf_B             rh.pial.gii                      \
        -surf_intermed_pref rh.isurf                         \
        -infl_surf_A        rh.inf.smoothwm_240.gii          \
        -infl_surf_B        rh.inf.pial_240.gii              \
        -infl_surf_intermed_pref  infl.rh.isurf

'''
suma -spec newspec_both.spec -sv warped_MP2RAGE.nii

../*SurfVol.nii*


quickspecSL -both_lr -surf_A lh.white.gii -surf_B lh.pial.gii

quickspecSL -surfA lh.smoothwm.gii -surfB lh.
