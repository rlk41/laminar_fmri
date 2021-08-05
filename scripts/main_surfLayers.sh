source ../paths

rh_white_EPI="./rh.white.EPI"
lh_white_EPI="./lh.white.EPI"

rh_inflated_EPI="./rh.inflated.EPI"
lh_inflated_EPI="./lh.inflated.EPI"



#mri_vol2surf --src $EPI --out $rh_white_EPI --srcreg --hemi rh --surf white --projfrac 0.0
#mri_vol2surf --src $EPI --out $rh_white_EPI --srcreg --hemi rh --surf white --projfrac 0.25
#mri_vol2surf --src $EPI --out $rh_white_EPI --srcreg --hemi rh --surf white --projfrac 0.5
#mri_vol2surf --src $EPI --out $rh_white_EPI --srcreg --hemi rh --surf white --projfrac 0.75
#mri_vol2surf --src $EPI --out $rh_white_EPI --srcreg --hemi rh --surf white --projfrac 1.0

#mri_vol2surf --src $EPI --out $lh_white_EPI --srcreg --hemi lh --surf white --projfrac 0.0
#mri_vol2surf --src $EPI --out $lh_white_EPI --srcreg --hemi lh --surf white --projfrac 0.25
#mri_vol2surf --src $EPI --out $lh_white_EPI --srcreg --hemi lh --surf white --projfrac 0.5
#mri_vol2surf --src $EPI --out $lh_white_EPI --srcreg --hemi lh --surf white --projfrac 0.75
#mri_vol2surf --src $EPI --out $lh_white_EPI --srcreg --hemi lh --surf white --projfrac 1.0


# smooth along layers here

mri_vol2surf --src $EPI --out $rh_inflated_EPI --srcreg --hemi rh --surf inflated --projfrac 0.0
mri_vol2surf --src $EPI --out $rh_inflated_EPI --srcreg --hemi rh --surf inflated --projfrac 0.25
mri_vol2surf --src $EPI --out $rh_inflated_EPI --srcreg --hemi rh --surf inflated --projfrac 0.5
mri_vol2surf --src $EPI --out $rh_inflated_EPI --srcreg --hemi rh --surf inflated --projfrac 0.75
mri_vol2surf --src $EPI --out $rh_inflated_EPI --srcreg --hemi rh --surf inflated --projfrac 1.0

mri_vol2surf --src $EPI --out $lh_inflated_EPI --srcreg --hemi lh --surf inflated --projfrac 0.0
mri_vol2surf --src $EPI --out $lh_inflated_EPI --srcreg --hemi lh --surf inflated --projfrac 0.25
mri_vol2surf --src $EPI --out $lh_inflated_EPI --srcreg --hemi lh --surf inflated --projfrac 0.5
mri_vol2surf --src $EPI --out $lh_inflated_EPI --srcreg --hemi lh --surf inflated --projfrac 0.75
mri_vol2surf --src $EPI --out $lh_inflated_EPI --srcreg --hemi lh --surf inflated --projfrac 1.0


