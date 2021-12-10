rm(list=ls())
# load("D:/user/vogelj/compound_events_mediterran/Code/Workspaces/Events_Fri_Oct_18_11_10_09_2019.RData") # Events for warm season compound events, frequency 1
load("D:/user/vogelj/compound_events_mediterran/Code/Workspaces/Events_Thu_Jan_16_17_14_49_2020.RData") # Events for warm season compound events, frequency 12
save(event,event_b,event_series,event_series_b,events_per_time,events_per_time_b,coord,Koeppen,month_lengths,years,file="Main_variables_warm_season_compound_events.RData")

rm(list=ls())
# load("D:/user/vogelj/compound_events_mediterran/Code/Workspaces/Events_Sun_Dec_08_14_33_01_2019.RData") # Events for whole season compound events, frequency 1
load("D:/user/vogelj/compound_events_mediterran/Code/Workspaces/Events_Sat_Jan_11_20_24_32_2020.RData") # Events for whole season compound events, frequency 12
save(event,event_b,event_series,event_series_b,events_per_time,events_per_time_b,coord,Koeppen,month_lengths,years,file="Main_variables_whole_season_compound_events.RData")

rm(list=ls())
load("D:/user/vogelj/compound_events_mediterran/Code/Workspaces/Events_Fri_Oct_18_13_05_12_2019.RData") # Events for warm season heat waves
save(event,event_b,event_series,event_series_b,events_per_time,events_per_time_b,coord,Koeppen,month_lengths,years,file="Main_variables_warm_season_heat_events.RData")

rm(list=ls())
load("D:/user/vogelj/compound_events_mediterran/Code/Workspaces/Events_Wed_Oct_23_18_53_00_2019.RData") # Events for whole season heat waves
save(event,event_b,event_series,event_series_b,events_per_time,events_per_time_b,coord,Koeppen,month_lengths,years,file="Main_variables_whole_season_heat_events.RData")

rm(list=ls())
# load("D:/user/vogelj/compound_events_mediterran/Code/Workspaces/Events_Thu_Oct_31_14_55_29_2019.RData") # Events for warm season droughts, frequency 1
load("D:/user/vogelj/compound_events_mediterran/Code/Workspaces/Events_Fri_Jan_17_09_26_32_2020.RData") # Events for warm season droughts, frequency 12
save(event,event_b,event_series,event_series_b,events_per_time,events_per_time_b,coord,Koeppen,month_lengths,years,file="Main_variables_warm_season_drought_events.RData")

rm(list=ls())
# load("D:/user/vogelj/compound_events_mediterran/Code/Workspaces/Events_Sun_Dec_08_18_16_58_2019.RData") # Events for whole season droughts, frequency 1
load("D:/user/vogelj/compound_events_mediterran/Code/Workspaces/Events_Sun_Jan_12_12_37_13_2020.RData") # Events for whole season droughts, frequency 12
save(event,event_b,event_series,event_series_b,events_per_time,events_per_time_b,coord,Koeppen,month_lengths,years,file="Main_variables_whole_season_drought_events.RData")


# Revision
rm(list=ls())
load("D:/user/vogelj/compound_events_mediterran/Code/Workspaces/Events_Fri_Oct_09_12_29_34_2020.RData") # Events for warm season compound events, frequency 12, multiple drought lengths and intensities
save(event,event_b,event_series,event_series_b,events_per_time,events_per_time_b,coord,Koeppen,month_lengths,years,file="Main_variables_warm_season_compound_events_multiple_droughts.RData")

rm(list=ls())
load("D:/user/vogelj/compound_events_mediterran/Code/Workspaces/Events_Tue_Oct_06_21_57_54_2020.RData") # Events for whole season compound events, frequency 12, multiple drought lengths and intensities
save(event,event_b,event_series,event_series_b,events_per_time,events_per_time_b,coord,Koeppen,month_lengths,years,file="Main_variables_whole_season_compound_events_multiple_droughts.RData")

