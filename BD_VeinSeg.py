#%% Initialize
import napari
import numpy as np
import matplotlib.pyplot as plt

from joblib import Parallel, delayed  

from skimage import io
from skimage.util import invert
from skimage.filters import gaussian
from skimage.morphology import remove_small_objects, skeletonize, disk
from skimage.filters.rank import maximum

from scipy.ndimage import maximum_filter
from scipy.ndimage.morphology import distance_transform_edt


#%% varnames
ROOTPATH = 'E:/3-GitHub_BDehapiot/BD_VeinSeg/'
NAME_cd31 = 'LCMVd2_MIP_cd31_RSize_sCrop.tif'
NAME_iba1 = 'LCMVd2_MIP_iba1_RSize_sCrop.tif'

PIXSIZE = 3.5425 # pixel size in µm

THRESH_cd31 = 25 # threshold for binary
MINSIZE_cd31 = 500 # minsize for binary objects

THRESH_iba1 = 25 # threshold for binary
MINSIZE_iba1 = 50 # minsize for binary objects

#%% Open Stack from RAWNAME

cd31 = io.imread(ROOTPATH+NAME_cd31)
iba1 = io.imread(ROOTPATH+NAME_iba1)
nY = cd31.shape[0] # Get Stack dimension (y)
nX = cd31.shape[1] # Get Stack dimension (x)

#%% Segment&process cd31 image (veins)

# Apply gaussian blur
cd31_bin = gaussian(cd31, sigma=1, preserve_range=True)

# Threshold image 
cd31_bin = cd31_bin > THRESH_cd31
cd31_bin = remove_small_objects(cd31_bin, min_size=MINSIZE_cd31)

# Get EDM
cd31_edmIn = distance_transform_edt(cd31_bin)
cd31_edmIn = cd31_edmIn * PIXSIZE # get distance in µm
cd31_edmOut = distance_transform_edt(invert(cd31_bin))
cd31_edmOut = cd31_edmOut * PIXSIZE # get distance in µm

# Apply max filter
cd31_edmIn_max = maximum_filter(cd31_edmIn, footprint=disk(5))

# Apply max filter
cd31_edmIn_max[cd31_bin == 0] = 0

#%% Segment&process iba1 image

# Apply gaussian blur
iba1_bin = gaussian(iba1, sigma=1, preserve_range=True)

# Threshold image 
iba1_bin = iba1_bin > THRESH_iba1
iba1_bin = remove_small_objects(iba1_bin, min_size=MINSIZE_iba1)

#%% 

iba1_dist2veins = cd31_edmOut
iba1_dist2veins[iba1_bin == 0] = ['nan']
iba1_dist2veins = np.reshape(iba1_dist2veins, iba1_dist2veins.size)
iba1_dist2veins = (iba1_dist2veins[~np.isnan(iba1_dist2veins)])

plt.hist(iba1_dist2veins, bins=20, range=[0, 100], density=True, stacked=True);



#%% Napari
   
# with napari.gui_qt():
#     viewer = napari.view_image(cd31_bin).astype('uint8')*255
    
#%% Saving
io.imsave(ROOTPATH+NAME_cd31[0:-4]+'_bin.tif', cd31_bin.astype('uint8')*255, check_contrast=True)
io.imsave(ROOTPATH+NAME_cd31[0:-4]+'_edmIn.tif', cd31_edmIn.astype('float32'), check_contrast=True)
io.imsave(ROOTPATH+NAME_cd31[0:-4]+'_edmOut.tif', cd31_edmOut.astype('float32'), check_contrast=True)
io.imsave(ROOTPATH+NAME_cd31[0:-4]+'_edmIn_max.tif', cd31_edmIn_max.astype('float32'), check_contrast=True)

io.imsave(ROOTPATH+NAME_iba1[0:-4]+'_bin.tif', iba1_bin.astype('uint8')*255, check_contrast=True)

io.imsave(ROOTPATH+NAME_iba1[0:-4]+'_dist2veins.tif', iba1_dist2veins.astype('float32'), check_contrast=True)

#%% Current

#%% apply sato filter

# def sato_filter(im, sigmas):
#     '''Enter function general description + arguments'''
#     im_sato = sato(im,sigmas=sigmas,mode='reflect',black_ridges=False)   
#     return im_sato

# output_list = Parallel(n_jobs=35)(
#     delayed(sato_filter)(
#         cd31_bin,
#         SATO_SIG[i]
#         ) 
#     for i in range(len(SATO_SIG))
#     ) 

# cd31_bin_sato = np.stack([arrays for arrays in output_list], axis=0)  
# io.imsave(ROOTPATH+NAME_cd31[0:-4]+'_bin_sato.tif', cd31_bin_sato.astype('float32'), check_contrast=True)