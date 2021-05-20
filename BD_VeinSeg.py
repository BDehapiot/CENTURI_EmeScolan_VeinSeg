#%% Initialize
import numpy as np

from skimage import io
from skimage.util import invert
from skimage.filters import gaussian
from skimage.morphology import remove_small_objects, disk

from scipy.ndimage import maximum_filter
from scipy.ndimage.morphology import distance_transform_edt

#%% Varnames
ROOTPATH = 'E:/3-GitHub_BDehapiot/BD_VeinSeg/'
NAME_cd31 = 'LCMVd2_MIP_cd31_sCrop.tif'
NAME_iba1 = 'LCMVd2_MIP_iba1_sCrop.tif'
NAME_mhc2 = 'LCMVd2_MIP_mhc2_sCrop.tif'

PIXSIZE = 1.7712 # pixel size in µm (1.7712 for full size images)
VEINSCAT = np.arange(0,30,5)  # define categories for veins in µm
VEINSCAT_prox = 50 # distance for veins proximity maps in µm 

THRESH_cd31 = 30 # threshold for binary
MINSIZE_cd31 = 250 # minsize for binary objects in pixels (500 for full size images)
MAXFILT_cd31 = 20 # max filter size for veins radius in pixels (20 for full size images)

THRESH_iba1 = 30 # threshold for binary 
MINSIZE_iba1 = 50 # minsize for binary objects (50 for full size images)

THRESH_mhc2 = 30 # threshold for binary 
MINSIZE_mhc2 = 50 # minsize for binary objects (50 for full size images)

#%% Open Stack from RAWNAME

cd31 = io.imread(ROOTPATH+NAME_cd31)
iba1 = io.imread(ROOTPATH+NAME_iba1)
mhc2 = io.imread(ROOTPATH+NAME_mhc2)
nY = cd31.shape[0] # Get Stack dimension (y)
nX = cd31.shape[1] # Get Stack dimension (x)

#%% Segment & process cd31 image (veins)

# Apply gaussian blur
cd31_bin = gaussian(cd31, sigma=2, preserve_range=True)

# Threshold image 
cd31_bin = cd31_bin > THRESH_cd31
cd31_bin = remove_small_objects(cd31_bin, min_size=MINSIZE_cd31)

# Get EDM
cd31_edmIn = distance_transform_edt(cd31_bin)
cd31_edmIn = cd31_edmIn * PIXSIZE # get distance in µm
cd31_edmOut = distance_transform_edt(invert(cd31_bin))
cd31_edmOut = cd31_edmOut * PIXSIZE # get distance in µm

# Apply max filter
cd31_edmIn_max = maximum_filter(cd31_edmIn, footprint=disk(MAXFILT_cd31))

# Apply max filter
cd31_edmIn_max[cd31_bin == 0] = 0

#%% Categorize veins and generate proximity maps

nCat = VEINSCAT.size
cd31_cat = np.zeros([nCat,nY,nX], dtype='bool')
cd31_cat_edmOut = np.zeros([nCat,nY,nX], dtype='float32')
cd31_cat_edmOut_proxmaps = np.zeros([nCat,nY,nX], dtype='bool')
for i in range(nCat):
    # Categorize veins
    if i < nCat-1:
        temp = (cd31_edmIn_max > VEINSCAT[i]) & (cd31_edmIn_max <= VEINSCAT[i+1])
    else :
        temp = cd31_edmIn_max > VEINSCAT[i]   
        
    # Pocess masks and get proximity maps  
    temp = remove_small_objects(temp, min_size=MINSIZE_iba1)    
    temp_edmOut = distance_transform_edt(invert(temp))   
    temp_edmOut_proxmaps = (temp_edmOut <= VEINSCAT_prox/PIXSIZE) 
    
    # Append arrays
    cd31_cat[i,:,:] = temp
    cd31_cat_edmOut[i,:,:] = temp_edmOut    
    cd31_cat_edmOut_proxmaps[i,:,:] = temp_edmOut_proxmaps

#%% Segment & process iba1 and mhc2 images

# Apply gaussian blur
iba1_bin = gaussian(iba1, sigma=2, preserve_range=True)
mhc2_bin = gaussian(mhc2, sigma=2, preserve_range=True)

# Threshold image 
iba1_bin = iba1_bin > THRESH_iba1
iba1_bin = remove_small_objects(iba1_bin, min_size=MINSIZE_iba1)
mhc2_bin = mhc2_bin > THRESH_mhc2
mhc2_bin = remove_small_objects(mhc2_bin, min_size=MINSIZE_mhc2)

#%% Measure 

proxmaps_area = np.zeros([nCat,5])
for i in range(nCat):
    
    temp_cd31_bin = np.copy(cd31_bin)
    temp_proxmap = cd31_cat_edmOut_proxmaps[i,:,:]
    
    temp_iba1_bin = np.copy(iba1_bin)
    # temp_iba1_bin[temp_cd31_bin == 1] = 0 # remove iba1 signal overlapping veins
    temp_iba1_bin[temp_proxmap == 0] = 0 # remove iba1 signal outside proxmap
    
    temp_mhc2_bin = np.copy(mhc2_bin)
    # temp_mhc2_bin[temp_cd31_bin == 1] = 0 # remove mhc2 signal overlapping veins
    temp_mhc2_bin[temp_proxmap == 0] = 0 # remove mhc2 signal outside proxmap     
    
    proxmaps_area[i,0] = np.sum(temp_proxmap)*(PIXSIZE**2) # surface in µm²
    proxmaps_area[i,1] = np.sum(temp_iba1_bin)*(PIXSIZE**2) # surface in µm²
    proxmaps_area[i,2] = (proxmaps_area[i,1])/(proxmaps_area[i,0]) # proportion of iba1 signal in proximity of veins
    proxmaps_area[i,3] = np.sum(temp_mhc2_bin)*(PIXSIZE**2) # surface in µm²
    proxmaps_area[i,4] = (proxmaps_area[i,3])/(proxmaps_area[i,0]) # proportion of mhc2 signal in proximity of veins
   
#%% Saving
io.imsave(ROOTPATH+NAME_cd31[0:-4]+'_bin.tif', cd31_bin.astype('uint8')*255, check_contrast=True, imagej=True)
io.imsave(ROOTPATH+NAME_cd31[0:-4]+'_edmIn.tif', cd31_edmIn.astype('float32'), check_contrast=True, imagej=True)
io.imsave(ROOTPATH+NAME_cd31[0:-4]+'_edmOut.tif', cd31_edmOut.astype('float32'), check_contrast=True, imagej=True)
io.imsave(ROOTPATH+NAME_cd31[0:-4]+'_edmIn_max.tif', cd31_edmIn_max.astype('float32'), check_contrast=True, imagej=True)
io.imsave(ROOTPATH+NAME_cd31[0:-4]+'_cat.tif', cd31_cat.astype('uint8')*255, check_contrast=True, imagej=True)
io.imsave(ROOTPATH+NAME_cd31[0:-4]+'_cat_edmOut.tif', cd31_cat_edmOut.astype('float32'), check_contrast=True, imagej=True)
io.imsave(ROOTPATH+NAME_cd31[0:-4]+'_cat_edmOut_proxmaps.tif', cd31_cat_edmOut_proxmaps.astype('uint8')*255, check_contrast=True, imagej=True)

#%% Current
