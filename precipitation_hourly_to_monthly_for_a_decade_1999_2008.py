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
 
day = (19990101, 19990201, 19990301, 19990401, 19990501, 19990601, 19990701, 19990801, 19990901, 19991001, 19991101, 19991201,
    20000101, 20000201, 20000301, 20000401, 20000501, 20000601, 20000701, 20000801, 20000901, 20001001, 20001101, 20001201,
    20010101, 20010201, 20010301, 20010401, 20010501, 20010601, 20010701, 20010801, 20010901, 20011001, 20011101, 20011201,
    20020101, 20020201, 20020301, 20020401, 20020501, 20020601, 20020701, 20020801, 20020901, 20021001, 20021101, 20021201,
    20030101, 20030201, 20030301, 20030401, 20030501, 20030601, 20030701, 20030801, 20030901, 20031001, 20031101, 20031201,
    20040101, 20040201, 20040301, 20040401, 20040501, 20040601, 20040701, 20040801, 20040901, 20041001, 20041101, 20041201,
    20050101, 20050201, 20050301, 20050401, 20050501, 20050601, 20050701, 20050801, 20050901, 20051001, 20051101, 20051201,
    20060101, 20060201, 20060301, 20060401, 20060501, 20060601, 20060701, 20060801, 20060901, 20061001, 20061101, 20061201,
    20070101, 20070201, 20070301, 20070401, 20070501, 20070601, 20070701, 20070801, 20070901, 20071001, 20071101, 20071201,
    20080101, 20080201, 20080301, 20080401, 20080501, 20080601, 20080701, 20080801, 20080901, 20081001, 20081101, 20081201)
#months = (31,28,31,30,31,30,31,31,30,31,30,31)
#months = (31,29,31,30,31,30,31,31,30,31,30,31) # Schaltjahr
months = (31,28,31,30,31,30,31,31,30,31,30,31,
          31,29,31,30,31,30,31,31,30,31,30,31,
          31,28,31,30,31,30,31,31,30,31,30,31,        
          31,28,31,30,31,30,31,31,30,31,30,31,
          31,28,31,30,31,30,31,31,30,31,30,31,        
          31,29,31,30,31,30,31,31,30,31,30,31,
          31,28,31,30,31,30,31,31,30,31,30,31,
          31,28,31,30,31,30,31,31,30,31,30,31,
          31,28,31,30,31,30,31,31,30,31,30,31,
          31,29,31,30,31,30,31,31,30,31,30,31)

d = datetime.strptime(str(day[0]), '%Y%m%d')
#f_in = 'tp_%d-%s.nc' % (day[0], (d + timedelta(days = 365)).strftime('%Y%m%d')) # 1 Year
#f_in = 'tp_%d-%s.nc' % (day[0], (d + timedelta(days = 3652)).strftime('%Y%m%d')) # 10 Years including 2 leap years
#f_in = 'tp_%d-%s.nc' % (day[0], (d + timedelta(days = 3653)).strftime('%Y%m%d')) # 10 Years including 3 leap years
#f_in = 'tp_%d-%s.nc' % (day[0], (d + timedelta(days = 4018-1)).strftime('%Y%m%d')) # 11 Years including 3 leap years

#f_in = 'tp_%d-%s.nc' % (day[0], (d + timedelta(days = 4017-1)).strftime('%Y%m%d')) # 11 Years including 2 leap years
f_in = 'Monthly_precipitation_1999-2008.nc' # Load input file: precipitation for 11 Years including 3 leap years
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