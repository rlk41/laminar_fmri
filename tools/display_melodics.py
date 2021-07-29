import tkinter as tk
from PIL import Image, ImageTk
  
import glob
import subprocess
import os
import sys

        
def saveICs (indices, path, f):
    outfile = path + f
    with open(outfile, 'w') as file:
        for item in indices:
            file.write("{},".format(item))        

def handler (event):
    if event.char=='r':
        removers[i]=1
        root.destroy()
    elif event.char=='k':
        keepers[i]=1
        root.destroy()
    
def quit (event):
    sys.exit()

def displayICs (path, root, removers, keepers, rem_indices, keep_indices):
            
    root.title("IC num" + str(i))
    
    # pick an image file you have .bmp  .jpg  .gif.  .png
    # load the file and covert it to a Tkinter image object
    ICfile = path + "IC_" + str(i) + "_thresh.png"
    image1 = Image.open(ICfile)
    #image1 = image.resize((689, 557), Image.ANTIALIAS) #The (250, 250) is (height, width)
    image1 = ImageTk.PhotoImage(image1)    
    
    ts = path + "t" + str(i) + ".png"
    timeseries = Image.open(ts) 
    #timeseries1 = timeseries.resize((622,118), Image.ANTIALIAS)
    timeseries1 = ImageTk.PhotoImage(timeseries)    
 
    fs = path + "f" + str(i) + ".png"
    power = Image.open(fs) 
    power1 = ImageTk.PhotoImage(power)    
     
    # get the image size
    wic = image1.width()
    hic = image1.height()
    wt = timeseries1.width()
    ht = timeseries1.height()
    # position coordinates of root 'upper left corner'
    x = 0
    y = 0
    
    # make the root window the size of the image
    root.geometry("%dx%d+%d+%d" % (wic+wt, hic, x, y))
    
    # root has no image argument, so use a label as a panel
    panel1 = tk.Label(root, image=image1)
    panel1.grid(row=0, column=0, rowspan=4)
      
    panel2 = tk.Label(root, image=timeseries1)
    panel2.grid(row=1, column=1, sticky="NW")
        
    panel3 = tk.Label(root, image=power1)
    panel3.grid(row=2, column=1, sticky="NW")
       
    # save the panel's image from 'garbage collection'
    panel1.image = image1
    panel2.image = timeseries1
    panel3.image = power1
    
    root.bind('<k>', handler)
    root.bind('<r>', handler)
    root.bind('<q>', quit)

    # start the event loop
    root.mainloop()
    
    rem_indices = [a for a, x in enumerate(removers) if x == 1]
    keep_indices = [a for a, x in enumerate(keepers) if x == 1]
       
    return rem_indices, keep_indices

            
if __name__ == "__main__":
    print("Display Melodics v0.01 (09-2014)")
    print("(c) Niels Janssen, njanssen@ull.es")
    print("")
    print("Usage:")
    print("Press 'r' to remove IC, press 'k' to keep IC, and 'q' to quit")
    print("Decisions are saved in files 'to_remove.txt' and 'to_keep.txt' for further use (e.g., fsl_regfilt)\n")    

    path = os.getcwd() + "/"
    ICfiles = glob.glob(path + 'IC_*_thresh.png')
    num_ics = len(ICfiles)

    if num_ics==0:
        print("*** No ICs found!")
        print("*** Run program in 'report' folder of melodic output")
        print("*** e.g., '/subject01/out.ica/report/python /my_python_scripts/display_melodics.py'")
        sys.exit()
    
    removers = [0] * (num_ics+1)
    keepers = [0] * (num_ics+1)
    rem_indices = []
    keep_indices = []

    f_rem = "to_remove.txt"
    f_keep ="to_keep.txt"

    #num_ics=10
    print("*** Found %d ICs in folder %s\n" % (num_ics, path))
    nb = input("*** Continue (y/n)?:") #raw_input
    if nb=='y':
        for i in range(1,num_ics+1):
            root = tk.Tk()
            rem_indices, keep_indices = displayICs(path, root, removers, keepers, rem_indices, keep_indices)
        saveICs(rem_indices, path, f_rem)
        saveICs(keep_indices, path, f_keep)
    
    print("*** Written %s" % (path + f_rem))
    print("*** Written %s" % (path + f_keep))

