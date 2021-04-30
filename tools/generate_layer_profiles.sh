# single ROI
#python generate_layer_profile.py --roi L_A1

while getopts p: flag
do
    case "${flag}" in
        p) path=${OPTARG};;
    esac
done

echo "${path}"

# mutliple ROIs in parallel
cmd_file='/home/richard/Projects/bandettini/cmds/cmds_create_layer_profile.txt'
rm ${cmd_file}
touch ${cmd_file}

for f in ${path}/*.npy; do
  b=$(basename $f);
  b=($(echo $b | tr '.' '\n'));
  #echo ${b[1]}
  echo "python ./generate_layer_profile.py --path '${path}' --roi_name '${b[1]}'" >> ${cmd_file};
done;

sort -u ${cmd_file} -o ${cmd_file}
cat ${cmd_file} | wc -l


echo "RUNNING JOBS"
parallel --jobs 30 < ${cmd_file}


cp ${path}/*.png /home/richard/Desktop/plots_profile/
