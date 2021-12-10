# Readme

This folder contains the code corresponding to the article "Increasing compound warm spells and droughts in the Mediterranean Basin".

The analysis was carried out using R version 3.6.1 and Python version 3.7.3.


Data download
- retrieval_daily_max_temp_1979_1989.py: Download air temperature for years 1979-1989
- retrieval_daily_max_temp_1989_1999.py: Download air temperature for years 1989-1999
- retrieval_daily_max_temp_1999_2009.py: Download air temperature for years 1999-2009
- retrieval_daily_max_temp_2009_2019.py: Download air temperature for years 2009-2019
- precipitation_hourly_for_one_decade.py: Download precipitation for years 1979-2019 (run separately for each decade)
- pet_hourly.py: Download potential evaporation for years 1979-2019 (run separately for each decade)
- data_retrieval_explanations.py: Details on the download parameters

Data preprocessing: The following files create files for monthly time step and time span based on original files with hourly time step and decadal time span
- pet_hourly_to_monthly_for_a_decade_1979_1988.py: 1979-1988
- pet_hourly_to_monthly_for_a_decade_1989_1998.py: 1989-1998
- pet_hourly_to_monthly_for_a_decade_1999_2008.py: 1999-2008
- pet_hourly_to_monthly_for_a_decade_2009_2018.py: 2009-2018
- precipitation_hourly_to_monthly_for_a_decade.py: 1979-1988
- precipitation_hourly_to_monthly_for_a_decade_1989_1998.py: 1989-1998
- precipitation_hourly_to_monthly_for_a_decade_1999_2008.py: 1999-2008
- precipitation_hourly_to_monthly_for_a_decade_2009_2018.py: 2009-2018

Data processing
- Data_processing_warm_season.R: calculate daily temperature maxima, SPI and SPEI for warm season (May-Oct)
- Data_processing_desesason.R: calculate daily temperature maxima, SPI and SPEI and deseasonalise data year-round

Detection of events
- Koeppen_Geiger.R: creates Koeppen-Geiger study area map, file retrieved from http://koeppen-geiger.vu-wien.ac.at/present.htm
- Koeppen_Geiger_map.R: refinded study area map for the Mediterranean
- Event_calculation_general.R: Detection of compound events and heat waves (load respective workspace and adjust loop accordingly, adjust section at top for either whole or warm season events)
- Event_calculation_drought.R: Detection of droughts (adjust section at top for either whole or warm season events)
- extract_key_variables.R: extract only the necessary objects to reduce required RAM space

Final plots and overview of results
- Results_mediterranean.Rmd: Overview of results for compound events and heat waves
- Results_mediterranean_droughts.Rmd: Overview of results for droughts
- Result_plots.Rmd: Final plots for compound events
- Results_mixed.Rmd: Final plots for singular events
- Analysis_per_country.Rmd: Final plots for analysis per country
- pie_chart.R: Schematic illustration of change vector analysis

