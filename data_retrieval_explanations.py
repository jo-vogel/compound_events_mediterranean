# -*- coding: utf-8 -*-
"""
Created on Fri Apr  5 16:00:03 2019

@author: vogelh
"""

#!/usr/bin/env python
# Example 3: Download ERA5 monthly mean of daily means data (surface level 2m temperature) at the default reduced Gaussian grid in GRIB format.
# https://confluence.ecmwf.int/display/CKB/How+to+download+ERA5

import cdsapi
 
c = cdsapi.Client()
c.retrieve('reanalysis-era5-complete', {    # do not change this!
    'class'   : 'ea', # ERA5,  https://apps.ecmwf.int/codes/grib/format/mars/class/
    'expver'  : '1', # data version 
    'stream'  : 'moda', # HRES monthly means of daily mean  https://apps.ecmwf.int/codes/grib/format/mars/stream/
    'type'    : 'an', #analyses
    'param'   : '167.128', # first part: ID; If a GRIB code is not unique, a parameter can be specified as e.g. param=130.nnn, where nnn defines a particular table 2 version.
    'levtype' : 'sfc', # surface or single level
    'date'    : '2018-01-01',
    'decade'  : '2010',
}, 'monthly-mean-daily-mean-temp-an-sfc.grib')
# https://confluence.ecmwf.int/display/CKB/ERA5+data+documentation