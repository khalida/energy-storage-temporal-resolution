# energy-storage-temporal-resolution
The Importance of Temporal Resolution in Evaluating Residential Energy Storage
(git repository to accompany the draft conference paper)

## Getting Data
Source data is not included in this repository. This is because it would be very large (several GB), and also because the data is only available under agrreement from [dataport](http://dataport.pecanstreet.org/).

However, the following files may be of help in downloading data:
1) `/dataPort_downloads/list_of_homes_with_use_AND_gen_from_01_01_2013_till_31_12_2014.sql`
2) `/dataPort_downloads/runMultipleQueries.sh`

The first file is just a list of house ID numbers which have fields of interest, at 1-minute resolution during the period of interest. The second is a `bash` script to facilitate downloading year's worth of data for multiple users, by repeated requests to the dataport database. Once you have access to the database your own user-name and password will need to be integrated into this script. As this is a bash script it will be easier to get it to work from linux.

## Running the Analysis
All of the analysis which produced the tables and figures in the paper will is run from the Matlab script `/PecanStreet_run_TimeSeries_Analysis.m`. This script is expected to find the data files in a `/data/` subdirectory, so first download the data into that folder.

There are several Matlab m-file functions included in the root directory `/` which help with running the analysis.
