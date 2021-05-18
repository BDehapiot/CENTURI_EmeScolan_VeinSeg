#%% Initialize
import napari
import numpy as np

from joblib import Parallel, delayed  

from skimage import io
from skimage.filters import gaussian
from skimage.morphology import remove_small_objects, skeletonize

from scipy.ndimage.morphology import distance_transform_edt

#%% varnames
ROOTPATH = 'E:/3-GitHub_BDehapiot/BD_VeinSeg/'
NAME_CD31 = 'LCMVd2_MIP_cd31_RSize.tif'

THRESH = 25 # threshold for binary
SATO_SIG = np.arange(1,13,1) # incremental sato filter 


#%% Open Stack from RAWNAME

cd31 = io.imread(ROOTPATH+NAME_CD31)
nY = cd31.shape[0] # Get Stack dimension (y)
nX = cd31.shape[1] # Get Stack dimension (x)

#%% Threshold image

# Apply gaussian blur
cd31_bin = gaussian(cd31, sigma=1, preserve_range=True)

# Threshold image 
cd31_bin = cd31_bin > THRESH
cd31_bin = remove_small_objects(cd31_bin, min_size=500)

# Get skeleton
cd31_skel = skeletonize(cd31_bin)

# Get EDM
cd31_edm = distance_transform_edt(cd31_bin)



#%% Napari
   
# with napari.gui_qt():
#     viewer = napari.view_image(cd31_bin).astype('uint8')*255
    
#%% Saving
io.imsave(ROOTPATH+NAME_CD31[0:-4]+'_bin.tif', cd31_bin.astype('uint8')*255, check_contrast=True)
io.imsave(ROOTPATH+NAME_CD31[0:-4]+'_skel.tif', cd31_skel.astype('uint8')*255, check_contrast=True)
io.imsave(ROOTPATH+NAME_CD31[0:-4]+'_edm.tif', cd31_edm.astype('float32'), check_contrast=True)

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
# io.imsave(ROOTPATH+NAME_CD31[0:-4]+'_bin_sato.tif', cd31_bin_sato.astype('float32'), check_contrast=True)