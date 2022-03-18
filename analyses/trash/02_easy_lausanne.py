
###########################################
SUBJECTS_DIR='/home/richard/Projects/turkeltaub_gruffalo/data/02_freesurfer'
os.environ['SUBJECTS_DIR'] = SUBJECTS_DIR
subs = [ sub for sub in os.listdir(SUBJECTS_DIR) if 'fsaverage' not in sub ]

import subprocess
#res = subprocess.check_output(["sudo", "apt", "update"])
cmds = []
for sub in subs:
    cmd=["source activate easy_lausanne;",
        "SUBJECTS_DIR='/home/richard/Projects/turkeltaub_gruffalo/data/02_freesurfer';",
        "easy_lausanne_simple --subject_id {} &".format(sub)]
    cmds.append(' '.join(cmd))

    #subprocess.check_output(cmd.split(' '))

with open('/home/richard/Projects/turkeltaub_gruffalo/easy_lausanne_cmds.txt', 'w') as filehandle:
    for listitem in cmds:
        filehandle.write('%s\n' % listitem)
