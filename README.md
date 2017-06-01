# energy-storage-temporal-resolution
The Importance of Temporal Resolution in Evaluating Residential Energy Storage, git repository to accompany the IEEE PES GM 2017 paper to be presented in Chicago. A PDF of the paper is available at `2017_01_23_IEEE_PESGM2017_Temporal_Resolution.pdf`.

## Getting Data
Source data is not included in this repository. This is because it would be very large (several GB), and also because the data is only available under agrreement from [dataport](http://dataport.pecanstreet.org/).


However, the following files may be of help in downloading data, once you have signed up to the data license with dataport:

1) `/dataPort_downloads/list_of_homes_with_use_AND_gen_from_01_01_2013_till_31_12_2014.sql`

2) `/dataPort_downloads/runMultipleQueries.sh`


The first file is a list of house ID numbers which have fields of interest, at 1-minute resolution during the period of interest. The second is a `bash` script to facilitate downloading one year's worth of data for multiple users, by repeated requests to the dataport database. Once you have access to the database your own user-name and password will need to be integrated into this script. As this is a `bash` script it will probably be easier to get it to work from linux and linux-like systems.


## Running the Analysis
All of the analysis which produced the tables and figures in the paper is run from the Matlab script `/PecanStreet_run_TimeSeries_Analysis.m`. There are a number of things which you have to do first:

1) Download data from the dataport website (see instructions above)

2) Update the `dataDir` variable setting in the analysis script, so it knows where to find the data

3) Change any of the other run settings as you'd like (with the settings as-is, and about 1-year of data for 70 customers, the analysis takes about 1 hour to run.

4) To get full plotting functionality (produce `Tikz` plots) the `matlab2tikz` library is needed (from [here](https://au.mathworks.com/matlabcentral/fileexchange/22022-matlab2tikz-matlab2tikz))


There are several Matlab m-file functions included in the root directory `/` which are used in running the analysis.
