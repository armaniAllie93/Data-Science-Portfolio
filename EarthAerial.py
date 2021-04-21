get_ipython().run_line_magic('matplotlib', 'inline')
import rasterio as rio
import rasterio.plot as shw
import os
import matplotlib.pyplot as plt
import numpy as np
import geopandas as gpd
import earthpy as et
import earthpy.spatial as es
import earthpy.plot as ep
import gdal
import sys
get_ipython().system('{sys.executable} -m pip install fastai')
import glob
from arcgis.gis import GIS
from arcgis.raster import ImageryLayer
from sentinelhub import SHConfig,MimeType, CRS, BBox, SentinelHubRequest, SentinelHubDownloadClient,     DataSource, bbox_to_dimensions, DownloadRequest, BBoxSplitter, OsmSplitter, TileSplitter, CustomGridSplitter, UtmZoneSplitter, UtmGridSplitter
import itertools


# In[3]:


epaths = glob.glob("Sentinel/*.jp2")
epaths.sort()
epath = ("Sentinel/T11SMT_20200717T182921_B01_60m.jp2")
arr_stack, metadata = es.stack(epaths)
ep.plot_rgb(arr_stack,rgb=[4,3,1],stretch=True,figsize=(20,20))
plt.savefig('edata')


# In[2]:


#sentinel2 processing
config = SHConfig()
CLIENT_SECRET = 'm*JW}?-76bBH)PjZp:-sW,3ISibK)mfh0GPc])n^'
CLIENT_ID = 'edb4f750-7cb2-475c-b190-3406e33de291'
config.sh_client_id = CLIENT_ID
config.sh_client_secret = CLIENT_SECRET

usa_bbox = -118.572693,34.002581,-118.446350,34.057211
resolution = 60
bbox = BBox(bbox=usa_bbox, crs=CRS.WGS84)
size = bbox_to_dimensions(bbox, resolution=resolution)

evalscript_true_color = """
    //VERSION=3
    function setup() {
        return {
            input: [{
                bands: ["B02", "B03", "B04"]
            }],
            output: {
                bands: 3
            }
        };
    }
    function evaluatePixel(sample) {
        return [sample.B04, sample.B03, sample.B02];
    }
"""
request_true_color = SentinelHubRequest(
    evalscript=evalscript_true_color,
    data_folder='Sentinel',
    input_data=[
        SentinelHubRequest.input_data(
            data_source=DataSource.SENTINEL2_L1C,
            time_interval=('2020-09-08', '2020-09-10'),
        )
    ],
    responses=[
        SentinelHubRequest.output_response('default', MimeType.TIFF)
    ],
    bbox=bbox,
    size=size,
    config=config
)
#true_color_imgs = request_true_color.save_data()
#sc_image = true_color_imgs[0]
#plt.imshow(sc_image)


# In[21]:


my_gis = GIS("", "", "")
m = my_gis.map()
m
data_path = (r"./Sentinel/00da87d4e771b8b8b30e2d1ac70e1390")
tiff_path = os.path.join(data_path, "response.tiff")
tiff_properties={'title':'Sentinel 2 Imagery','description':'true real color imagery September 9 - 10',
                 'tags':'arcgis, python, imagery, sentinel2','type':'Image'}
#tiff_item = my_gis.content.add(data=tiff_path,item_properties=tiff_properties)
#earth = ImageryLayer(img_svc_url)
#earth
tiff_item
