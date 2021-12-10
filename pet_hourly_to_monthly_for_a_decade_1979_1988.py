# -*- coding: utf-8 -*-
"""
Created on Wed May  8 11:23:59 2019

@author: vogel
"""

#!/usr/bin/env python
"""
Save as file calculate-daily-pev.py and run "python calculate-daily-pev.py".
  
Input file : pev_20170101-20170102.nc
Output file: daily-pev_20170101.nc
Creates a file for each month
"""
import time, sys
from datetime import datetime, timedelta
 
from netCDF4 import Dataset, date2num, num2date
import numpy as np

#import os 
#os.getcwd()
#os.chdir('D:/Local/Data/ERA5/Precipitation/1989-1999')
 
day = (19790101080000, 19790201, 19790301, 19790401, 19790501, 19790601, 19790701, 19790801, 19790901, 19791001, 19791101, 19791201, # list of all months
       19800101, 19800201, 19800301, 19800401, 19800501, 19800601, 19800701, 19800801, 19800901, 19801001, 19801101, 19801201,
       19810101, 19810201, 19810301, 19810401, 19810501, 19810601, 19810701, 19810801, 19810901, 19811001, 19811101, 19811201,
       19820101, 19820201, 19820301, 19820401, 19820501, 19820601, 19820701, 19820801, 19820901, 19821001, 19821101, 19821201,
       19830101, 19830201, 19830301, 19830401, 19830501, 19830601, 19830701, 19830801, 19830901, 19831001, 19831101, 19831201,
       19840101, 19840201, 19840301, 19840401, 19840501, 19840601, 19840701, 19840801, 19840901, 19841001, 19841101, 19841201,
       19850101, 19850201, 19850301, 19850401, 19850501, 19850601, 19850701, 19850801, 19850901, 19851001, 19851101, 19851201,
       19860101, 19860201, 19860301, 19860401, 19860501, 19860601, 19860701, 19860801, 19860901, 19861001, 19861101, 19861201,
       19870101, 19870201, 19870301, 19870401, 19870501, 19870601, 19870701, 19870801, 19870901, 19871001, 19871101, 19871201,
       19880101, 19880201, 19880301, 19880401, 19880501, 19880601, 19880701, 19880801, 19880901, 19881001, 19881101, 19881201)
#months = (31,28,31,30,31,30,31,31,30,31,30,31)
#months = (31,29,31,30,31,30,31,31,30,31,30,31) # Schaltjahr
months = (31,28,31,30,31,30,31,31,30,31,30,31,        # length of each month
          31,29,31,30,31,30,31,31,30,31,30,31,
          31,28,31,30,31,30,31,31,30,31,30,31,        
          31,28,31,30,31,30,31,31,30,31,30,31,
          31,28,31,30,31,30,31,31,30,31,30,31,
          31,29,31,30,31,30,31,31,30,31,30,31,
          31,28,31,30,31,30,31,31,30,31,30,31,
          31,28,31,30,31,30,31,31,30,31,30,31,
          31,28,31,30,31,30,31,31,30,31,30,31,
          31,29,31,30,31,30,31,31,30,31,30,31)

#d = datetime.strptime(str(day[0]), '%Y%m%d')

#f_in = 'pev_%d-%s.nc' % (day[0], (d + timedelta(days = 4017-1)).strftime('%Y%m%d')) # 11 Years including 2 leap years
f_in = 'Monthly_potential_evaporation_1979-1989.nc' # Load input file: precipitation for 11 Years including 3 leap years
#for j in day:
for c, j in enumerate (day):
    #day = 20170701
    #d = datetime.strptime(str(day), '%Y%m%d')
    
    # The first month (January 1979 does not start at 00:00 o'clock, but at 08:00 o'clock). Therefore you have to specifically indicate this: 19790101080000. 
    # (Normally, you can just leave the hours/minutes/seconds, because it automatically assigns 00:00:00, but here you have to specifically indicate it).
    if c==0:
          d = datetime.strptime(str(j), '%Y%m%d%H%M%S') 
    else:
          d = datetime.strptime(str(j), '%Y%m%d')
    
    #f_out = 'daily-pev_%d-%s.nc' % (j, (d + timedelta(days = 30)).strftime('%Y%m%d')) # 30 is not correct for all months, but for namegiving it is sufficient for now
    f_out = 'monthly-pev_%d-%s.nc' % (j, (d + timedelta(days = months[c]-1)).strftime('%Y%m%d')) 
    
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
                sys.stderr.write('Error: potential evaporation data is missing/incomplete - %s!\n'
                        % tm.strftime('%Y%m%d %H:%M:%S'))
                sys.exit(200)
            else:
                #print('Found %s' % tm.strftime('%Y%m%d %H:%M:%S'))
                indices.append(a[0])
     
        var_pev = ds_src.variables['pev']
        pev_values_set = False
        for idx in indices:
            if not pev_values_set:
                data = var_pev[idx, :, :]
                pev_values_set = True
            else:
                data += var_pev[idx, :, :] # hier werden die Werte addiert
             
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
            var = ds_dest.createVariable(var_pev.name, np.double, var_pev.dimensions)
            var[0, :, :] = data
            var.setncattr('units', var_pev.units)
            var.setncattr('long_name', var_pev.long_name)
     
            # Attributes
            ds_dest.setncattr('Conventions', 'CF-1.6')
            ds_dest.setncattr('history', '%s %s'
                    % (datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                    ' '.join(time.tzname)))
     
            print('Done! Daily total potential evaporation saved in %s' % f_out)