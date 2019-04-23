This file contains information on using MMHs scripts to concatenate data from consectutive WW deployments

To set up processing for a NEW timeseries, follow the setup prescribed in process_lajit.m. In the following, I will use and refer to the "lajit" project as an example.

This workflow begins with the setup of a structure WWmeta that is passed to various functions for plotting/concatentating data. Generally speaking, you will need to run the first several sections of the process_lajit script until WWmeta is populated.

If new data needs to be processed, WWmeta.deployement should be updated with the name of the subfolder containing aqd and rbr data (i.e. 'd19') and then process_lajit.m should be run in its entirety. Repeat this process for each deployment that needs to be processed.

If all data has been processed, you can load the data for any period of time you choose using WWgrid = get_WW_data(WWmeta,starttime,endtime). You can then plot the data for any time period/variable using [hf,ha]=plot_WW_RBRgrid(WWgrid,starttime,endtime,{'variables'}). The function contains colormaps and limits that MMH deemed "nice", but ha contains axes handles so that you can modify colormaps and color limits as needed. 
