# -*- coding: utf-8 -*-
"""
Created on Wed May  8 11:23:59 2019

@author: vogel
"""

#!/usr/bin/env python
"""
Save as file calculate-daily-tp.py and run "python calculate-daily-tp.py".
  
Input file : tp_20170101-20170102.nc
Output file: daily-tp_20170101.nc
Creates a file for each month
"""
import time, sys
from datetime import datetime, timedelta
 
from netCDF4 import Dataset, date2num, num2date
import numpy as np

#import os 
#os.getcwd()
#os.chdir('D:/Local/Data/ERA5/Precipitation/1989-1999')
 
day = (19890101, 19890201, 19890301, 19890401, 19890501, 19890601, 19890701, 19890801, 19890901, 19891001, 19891101, 19891201, # list of all months
    19900101, 19900201, 19900301, 19900401, 19900501, 19900601, 19900701, 19900801, 19900901, 19901001, 19901101, 19901201,
    19910101, 19910201, 19910301, 19910401, 19910501, 19910601, 19910701, 19910801, 19910901, 19911001, 19911101, 19911201,
    19920101, 19920201, 19920301, 19920401, 19920501, 19920601, 19920701, 19920801, 19920901, 19921001, 19921101, 19921201,
    19930101, 19930201, 19930301, 19930401, 19930501, 19930601, 19930701, 19930801, 19930901, 19931001, 19931101, 19931201,
    19940101, 19940201, 19940301, 19940401, 19940501, 19940601, 19940701, 19940801, 19940901, 19941001, 19941101, 19941201,
    19950101, 19950201, 19950301, 19950401, 19950501, 19950601, 19950701, 19950801, 19950901, 19951001, 19951101, 19951201,
    19960101, 19960201, 19960301, 19960401, 19960501, 19960601, 19960701, 19960801, 19960901, 19961001, 19961101, 19961201,
    19970101, 19970201, 19970301, 19970401, 19970501, 19970601, 19970701, 19970801, 19970901, 19971001, 19971101, 19971201,
    19980101, 19980201, 19980301, 19980401, 19980501, 19980601, 19980701, 19980801, 19980901, 19981001, 19981101, 19981201)
#months = (31,28,31,30,31,30,31,31,30,31,30,31)
#months = (31,29,31,30,31,30,31,31,30,31,30,31) # Schaltjahr
months = (31,28,31,30,31,30,31,31,30,31,30,31,
          31,28,31,30,31,30,31,31,30,31,30,31, # length of each month
          31,28,31,30,31,30,31,31,30,31,30,31,        
          31,29,31,30,31,30,31,31,30,31,30,31,
          31,28,31,30,31,30,31,31,30,31,30,31,        
          31,28,31,30,31,30,31,31,30,31,30,31,
          31,28,31,30,31,30,31,31,30,31,30,31,
          31,29,31,30,31,30,31,31,30,31,30,31,
          31,28,31,30,31,30,31,31,30,31,30,31,
          31,28,31,30,31,30,31,31,30,31,30,31)

d = datetime.strptime(str(day[0]), '%Y%m%d')
#f_in = 'tp_%d-%s.nc' % (day[0], (d + timedelta(days = 365)).strftime('%Y%m%d')) # 1 Year
#f_in = 'tp_%d-%s.nc' % (day[0], (d + timedelta(days = 3652)).strftime('%Y%m%d')) # 10 Years including 2 leap years
#f_in = 'tp_%d-%s.nc' % (day[0], (d + timedelta(days = 3653)).strftime('%Y%m%d')) # 10 Years including 3 leap years
#f_in = 'tp_%d-%s.nc' % (day[0], (d + timedelta(days = 4018-1)).strftime('%Y%m%d')) # 11 Years including 3 leap years

#f_in = 'tp_%d-%s.nc' % (day[0], (d + timedelta(days = 4017-1)).strftime('%Y%m%d')) # 11 Years including 2 leap years
f_in = 'Monthly_precipitation_1989-1999.nc' # Load input file: precipitation for 11 Years including 3 leap years
#for j in day:
for c, j in enumerate (day):
    #day = 20170701
    #d = datetime.strptime(str(day), '%Y%m%d')
    d = datetime.strptime(str(j), '%Y%m%d')
    
    #f_out = 'daily-tp_%d-%s.nc' % (j, (d + timedelta(days = 364)).strftime('%Y%m%d'))
    #f_out = 'daily-tp_%d-%s.nc' % (j, (d + timedelta(days = 30)).strftime('%Y%m%d')) # 30 is not correct for all months, but for namegiving it is sufficient for now
    f_out = 'monthly-tp_%d-%s.nc' % (j, (d + timedelta(days = months[c]-1)).strftime('%Y%m%d')) 
    
    time_needed = []
    for i in range(1, 24*months[c]): # 24h*31d; das muss noch für jedes Monat angepasst werden
    #for i in range(1, 8760): # 24h*365d
        time_needed.append(d + timedelta(hours = i))
        #print(d + timedelta(hours = i))
     
    with Dataset(f_in) as ds_src:
        var_time = ds_src.variables['time']
        time_avail = num2date(var_time[:], var_time.units,
                calendar = var_time.calendar)
     
        indices = []
        for tm in time_needed:
            a = np.where(time_avail == tm)[0]
            if len(a) == 0:
                sys.stderr.write('Error: precipitation data is missing/incomplete - %s!\n'
                        % tm.strftime('%Y%m%d %H:%M:%S'))
                sys.exit(200)
            else:
                #print('Found %s' % tm.strftime('%Y%m%d %H:%M:%S'))
                indices.append(a[0])
     
        var_tp = ds_src.variables['tp']
        tp_values_set = False
        for idx in indices:
            if not tp_values_set:
                data = var_tp[idx, :, :]
                tp_values_set = True
            else:
                data += var_tp[idx, :, :] # hier werden die Werte addiert
             
        with Dataset(f_out, mode = 'w', format = 'NETCDF3_64BIT_OFFSET') as ds_dest:
            # Dimensions
            for name in ['latitude', 'longitude']:
                dim_src = ds_src.dimensions[name]
                ds_dest.createDimension(name, dim_src.size)
                var_src = ds_src.variables[name]
                var_dest = ds_dest.createVariable(name, var_src.datatype, (name,))
                var_dest[:] = var_src[:]
                var_dest.setncattr('units', var_src.units)
                var_dest.setncattr('long_name', var_src.long_name)
     
            ds_dest.createDimension('time', None)
            var = ds_dest.createVariable('time', np.int32, ('time',))
            time_units = 'hours since 1900-01-01 00:00:00'
            time_cal = 'gregorian'
            var[:] = date2num([d], units = time_units, calendar = time_cal)
            var.setncattr('units', time_units)
            var.setncattr('long_name', 'time')
            var.setncattr('calendar', time_cal)
     
            # Variables
            var = ds_dest.createVariable(var_tp.name, np.double, var_tp.dimensions)
            var[0, :, :] = data
            var.setncattr('units', var_tp.units)
            var.setncattr('long_name', var_tp.long_name)
     
            # Attributes
            ds_dest.setncattr('Conventions', 'CF-1.6')
            ds_dest.setncattr('history', '%s %s'
                    % (datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                    ' '.join(time.tzname)))
     
            print('Done! Daily total precipitation saved in %s' % f_out)