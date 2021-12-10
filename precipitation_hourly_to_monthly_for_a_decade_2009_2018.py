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
 
day = (20090101, 20090201, 20090301, 20090401, 20090501, 20090601, 20090701, 20090801, 20090901, 20091001, 20091101, 20091201,
    20100101, 20100201, 20100301, 20100401, 20100501, 20100601, 20100701, 20100801, 20100901, 20101001, 20101101, 20101201,
    20110101, 20110201, 20110301, 20110401, 20110501, 20110601, 20110701, 20110801, 20110901, 20111001, 20111101, 20111201,
    20120101, 20120201, 20120301, 20120401, 20120501, 20120601, 20120701, 20120801, 20120901, 20121001, 20121101, 20121201,
    20130101, 20130201, 20130301, 20130401, 20130501, 20130601, 20130701, 20130801, 20130901, 20131001, 20131101, 20131201,
    20140101, 20140201, 20140301, 20140401, 20140501, 20140601, 20140701, 20140801, 20140901, 20141001, 20141101, 20141201,
    20150101, 20150201, 20150301, 20150401, 20150501, 20150601, 20150701, 20150801, 20150901, 20151001, 20151101, 20151201,
    20160101, 20160201, 20160301, 20160401, 20160501, 20160601, 20160701, 20160801, 20160901, 20161001, 20161101, 20161201,
    20170101, 20170201, 20170301, 20170401, 20170501, 20170601, 20170701, 20170801, 20170901, 20171001, 20171101, 20171201,
    20180101, 20180201, 20180301, 20180401, 20180501, 20180601, 20180701, 20180801, 20180901, 20181001, 20181101, 20181201)
#months = (31,28,31,30,31,30,31,31,30,31,30,31)
#months = (31,29,31,30,31,30,31,31,30,31,30,31) # Schaltjahr
months = (31,28,31,30,31,30,31,31,30,31,30,31,
          31,28,31,30,31,30,31,31,30,31,30,31,
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
f_in = 'Monthly_precipitation_2009-2018.nc' # Load input file: precipitation for 11 Years including 3 leap years
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