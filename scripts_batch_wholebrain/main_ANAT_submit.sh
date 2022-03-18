
mkdir -p $logs

sbatch --mem=40g --cpus-per-task=40 \
--output="$logs/main_ANAT2.log" \
--time 24:00:00 \
--job-name="main_ANAT_wb" \
"$scripts_dir/main_ANAT.sh"

sbatch --mem=40g --cpus-per-task=40 \
--output="$logs/main_ANAT.log" \
--time 24:00:00 \
--job-name="main_ANAT_wb" \
"$scripts_dir/main_ANAT.sh"


sbatch --mem=20g --cpus-per-task=50 \
--output="$logs/ANTS_wholebrain.log" \
--time 24:00:00 \
--job-name="ANTs_wb" \
"$scripts_batch_dir/run_ANTS_wb.sh"

# 26293467


sbatch --mem=40g --cpus-per-task=40 \
--output="$logs/main_updownEPI.log" \
--time 24:00:00 \
--job-name="main_ANAT_updownEPI" \
"$scripts_dir/main_ANAT_updownEPI.sh"