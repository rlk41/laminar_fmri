import neuropythy as ny
import nibabel as nib
'''
{"freesurfer_subject_paths": "/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/bandettini_data/fs_data",
 "data_cache_root":          "/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/bandettini_data/npythy_cache",
 "hcp_subject_paths":        "/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/bandettini_data/HCP/subjects",
 "hcp_auto_download":        true,
 "hcp_credentials":          "~/.hcp-passwd"}

'''
#ny.freesurfer.add_subject_path('/Volumes/server/Freesurfer_subjects')
#ny.hcp.add_subject_path('/Volumes/server/HCP/subjects')

ny.hcp.download(100610)


sub = ny.hcp_subject(100610)