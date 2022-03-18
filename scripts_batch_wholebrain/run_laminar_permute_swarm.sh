#!/bin/bash 

set -e 

# roi_path 
roi_path=""
# column - extract from columns 
column_id=""
# number pcas 
num_pcas=10
# outdir    
out_dir=""

#EPIs=("/data/kleinrl/Wholebrain2.0/VASO_LN.4dmean.nii")

testnum=1000000
testcount=1

X=0
A=0
N=0
C=0

print_usage() {
  printf "Usage: ..."
}

while getopts 'r:p:o:t:XANC' flag; do
  case "${flag}" in
    r) roi_path="${OPTARG}" ;;
    p) num_pcas="${OPTARG}" ;;
    o) out_dir="${OPTARG}" ;;
    t) testnum="${OPTARG}" ;;
    X) X=1 ;;
    A) A=1 ;;
    N) N=1 ;;
    C) C=1 ;;

    *) print_usage
       exit 1 ;;
  esac
done

echo "    "

echo "PARAMETERS:"
echo "    "
echo "roi_path: $roi_path"
echo "num_pcas: $num_pcas"
echo "out_dir:  $out_dir"
echo "testnum:  $testnum"
echo "X:        $X"
echo "A:        $A"
echo "N:        $N"
echo "C:        $C"
echo "    "


if [ $X -eq  1 ]; then 
  echo "X:0 - will not submit jobs " | tee -a $log
else
  echo "X:1 - submitting jobs " | tee -a $log
fi


if [ $A -eq 0 ]; then 
  echo "A=0 - Will only run congruent/diagonal runs/seeds" | tee -a $log
else 
  echo "A=1 - Will run all run/seed comparisons" | tee -a $log
fi 

if [ $N -eq 0 ]; then 
  echo "N=0 - not permutation testing" | tee -a $log
else 
  echo "N=1 - permutation testing" | tee -a $log
fi 

if [ $C -eq 0 ]; then 
  echo "C=0 - not 3dTCorrMap" | tee -a $log
else 
  echo "C=1 - 3dTCorrMap" | tee -a $log
fi 

echo "    "

if [ -d $out_dir ]; then 
  rm -rf $out_dir
fi 


log=$out_dir/fsl_feat_submit_pcas.log
swarm_dir=$out_dir/swarm 
swarm_file=$swarm_dir/swarm.feat
job_ids=$swarm_dir/job_ids.log


mkdir -p $out_dir
mkdir -p $swarm_dir


touch $log
touch $job_ids
touch $swarm_file


EPIs=($(find $ds_dir/DAY*/run* -name "VASO_LN.nii"))
EPI_total=${#EPIs[@]}
EPI_num_list=$( seq 0 $(($EPI_total-1)) )

#for epi in ${EPIs[@]}; do 


echo "EPI_total: $EPI_total" | tee -a  $log
echo "EPI_num_list: ${EPI_num_list[*]}" | tee -a  $log


for epi_num in $EPI_num_list; do 


  if [ $A -eq 1 ]; then 
    EPI_tocompare=$EPI_num_list
  elif [ $A -eq 0 ]; then 
    EPI_tocompare=($epi_num)
  else
    echo "somethign wrong with -A flag -- setting EPI_tocompare list " | tee -a $log
  fi 

  echo "EPI comparing $epi_num vs ${EPI_tocompare[*]}" | tee -a  $log



  epi=${EPIs[$epi_num]}

  epi_pre=$(echo $epi | cut -d'/' -f5- )
  epi_pre=$(basename "${epi_pre////_}" .nii)

  mask=$roi_path
  roi=$(basename $roi_path .nii)


  timeseries_dir=$out_dir/timeseries/
  timeseries_1D=$timeseries_dir/$epi_pre.1D
  timeseries_2D=$timeseries_dir/$epi_pre.2D
  
  mkdir -p $timeseries_dir

  cd $timeseries_dir
  if [ -f $timeseries_2D ]; then 
    rm $timeseries_2D
  fi 


  echo "epi           $epi"            | tee -a $log
  echo "epi_pre:      $epi_pre"        | tee -a $log
  echo "mask:         $mask "          | tee -a $log
  echo "timeseries_1D $timeseries_1D"  | tee -a $log
  echo "timeseries_2D $timeseries_2D"  | tee -a $log
  echo "out_dir_1D    $out_dir_1D"     | tee -a $log


  # IF PCA == 0 - DO AVERGAE 
  if [ $num_pcas -eq 0 ]; then 

    echo "using average " | tee -a $log 

    3dmaskave -quiet -mask $mask $epi >> $timeseries_1D 

    #3dmaskdump -noijk -mask $mask -o $timeseries_2D -overwrite $epi 
    #ts=($timeseries_dir/$epi_pre.1D)


    for e_num in $EPI_tocompare; do 

      e=${EPIs[$e_num]}

      e_pre=$(echo $e | cut -d'/' -f5- )
      e_pre=$(basename "${e_pre////_}" .nii)


      
      if [ $C -eq 1 ]; then 


        out_dir_2D="$out_dir/$(basename $timeseries_1D .1D)/$epi_pre-$e_pre.corr"
        

        echo "AVE:          $timeseries_1D "  | tee -a $log
        echo "out_dir_2D:   $out_dir_2D"  | tee -a $log

        rm -rf $out_dir_2D*
        mkdir -p $out_dir_2D

        echo "3dTcorr1D -prefix $out_dir_2D/corr.nii.gz  $e $timeseries_1D " >> $swarm_file 
      else 

        out_dir_2D="$out_dir/$(basename $timeseries_1D .1D)/$epi_pre-$e_pre"
        

        echo "AVE:          $timeseries_1D "  | tee -a $log
        echo "out_dir_2D:   $out_dir_2D"  | tee -a $log

        rm -rf $out_dir_2D*
        mkdir -p $out_dir_2D

        echo "export NOBATCH=true ; fsl_feat.job.sh $e $timeseries_1D $out_dir_2D" >> $swarm_file 
      fi 



    done 

  # IF PCA > 0 THEN DO PCAS 
  elif [ $num_pcas -gt 0 ]; then 

    3dmaskdump -noijk -mask $mask -o $timeseries_2D -overwrite $epi 

    if [ $N -eq 1 ]; then 
      2D_rotate_timeseries.py --input $timeseries_2D 

      timeseries_2D=${timeseries_2D}.perm
    fi 


    get_pcas.py --file $timeseries_2D   #--var 0.50

    ts=(${timeseries_2D}.pca*.1D)


    for t in ${ts[@]:0:$num_pcas}; do 
      for e_num in $EPI_tocompare; do 

        e=${EPIs[$e_num]}

        e_pre=$(echo $e | cut -d'/' -f5- )
        e_pre=$(basename "${e_pre////_}" .nii)

        if [ $C -eq 1 ]; then 


          out_dir_2D="$out_dir/$(basename $t .1D)/$epi_pre-$e_pre.corr"
          

          echo "pca:          $t "  | tee -a $log
          echo "out_dir_2D:   $out_dir_2D"  | tee -a $log

          rm -rf $out_dir_2D*
          mkdir -p $out_dir_2D

          echo "3dTcorr1D -prefix $out_dir_2D/corr.nii.gz  $e $t " >> $swarm_file 
        else 

          out_dir_2D="$out_dir/$(basename $t .1D)/$epi_pre-$e_pre"
          

          echo "pca:          $t "  | tee -a $log
          echo "out_dir_2D:   $out_dir_2D"  | tee -a $log

          rm -rf $out_dir_2D*
          mkdir -p $out_dir_2D

          echo "export NOBATCH=true ; fsl_feat.job.sh $e $t $out_dir_2D" >> $swarm_file 
        fi 








      done 
    done 


  fi

  testcount=$(($testcount+1))

  if [ $testcount -gt $testnum ]; then 
    echo 'BREAKING OUT testcount > testnum'
    break
  fi 


done 





if [ $X -eq 0 ]; then 
  dep_feat=$(swarm -f $swarm_file -g 20 -t 1 --job-name feat_run --logdir $swarm_dir --time 10:00:00 )
  echo "FEAT $dep_feat"  | tee -a $log $job_ids 
else
  echo "FEAT NOT SUBMITTED TEST OPTION"  | tee -a $log
fi 





if [ -f $swarm_dir/swarm.post ]; then 
  rm $swarm_dir/swarm.post
fi 

echo "run_laminar_permute_post.sh -d $out_dir" | tee -a $swarm_dir/swarm.post $log

#dep_post=$(swarm -f $swarm_dir/swarm.post -g 10 --job-name feat_post --dependency afterok:$dep_feat --time 00:30:00)

#echo "POST $dep_post" >> $job_ids



if [ $X -eq 0 ]; then 

  dep_post=$(swarm -f $swarm_dir/swarm.post -g 10 --job-name feat_post --dependency afterok:$dep_feat --time 00:30:00)

  echo "POST $dep_post" | tee -a $job_ids $log
else
  echo "POST NOT SUBMITTED TEST OPTION" | tee -a $log
fi 




# swarm -f swarm.post -g 10 --job-name feat_post --time 00:30:00


s=( 1 3 5 8 )
dir="$out_dir/mean"
mkdir -p $dir 
mkdir -p $dir/logs


if [ -f $swarm_dir/swarm.L2D ]; then 
  rm $swarm_dir/swarm.L2D
fi 

for smoothing in ${s[@]};do 
  echo "L2D.job.sh $dir $smoothing" | tee -a $swarm_dir/swarm.L2D $log
done 

#dep_L2D=$(swarm -f $swarm_dir/swarm.L2D -g 20 --job-name L2D --logdir $swarm_dir \
#--time 24:00:00 --dependency=afterok:$dep_post)

# swarm -f swarm.L2D -g 20 --job-name L2D --logdir . --time 24:00:00

#echo "L2D $dep_L2D " >> $job_ids



if [ $X -eq 0 ]; then 

  dep_L2D=$(swarm -f $swarm_dir/swarm.L2D -g 20  --job-name L2D --logdir $swarm_dir \
  --time 48:00:00 --dependency=afterok:$dep_post)

  echo "POST $dep_L2D" | tee -a $job_ids $log 
else
  echo "L2D NOT SUBMITTED TEST OPTION" | tee -a $log
fi 





# if [ -f $swarm_dir/swarm.L2D_post ]; then 
#   rm $swarm_dir/swarm.L2D_post
# fi 

# echo "L2D_post.job.sh $out_dir/mean" | tee -a $swarm_dir/swarm.L2D_post $log


# if [ $X -eq 0 ]; then 


#   dep_L2D_post=$(swarm -f $swarm_dir/swarm.L2D_post -g 20  --job-name L2D_post --logdir $swarm_dir \
#   --time 24:00:00 --dependency=afterok:$dep_L2D)


#   echo "POST $dep_L2D_post" | tee -a $job_ids $log 
# else
#   echo "L2D_post NOT SUBMITTED TEST OPTION" | tee -a $log
# fi 





# for smoothing in ${s[@]};do 
#   echo $dir $smoothing
#   sbatch --mem=20g --cpus-per-task=5 \
#       --job-name=L2D \
#       --output=$dir/logs/L2D_fwhm$smoothing.log \
#       --time 3-0 \
#       L2D.job.sh $dir $smoothing
# done 
