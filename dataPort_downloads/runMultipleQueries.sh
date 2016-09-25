#!/bin/bash
# Export environment variable with password (to avoid needing to provide it interactively)
export PGPASSWORD=YOUR_PASSWORD_HERE

# Set properties for dbase access:
HOSTNAME="dataport.pecanstreet.org"
PORT_NO="5434"
DBNAME="postgres"
USERNAME="YOUR_USER_NAME_HERE"


# List of user IDs to export
readarray -t USER_ID_LIST < list_of_homes_with_use_AND_gen_from_01_01_2013_till_31_12_2014.sql
YEAR_LIST=("2013" "2014")

for i in "${YEAR_LIST[@]}"
do
	for j in "${USER_ID_LIST[@]}"
	do	
		OUT_FILE=/path/to/your/data/directory/"$i"/user_"$j".csv
		# echo $OUT_FILE
		psql -h $HOSTNAME -p $PORT_NO $DBNAME $USERNAME -t -A -c "\copy (SELECT electricity_egauge_minutes.localminute, electricity_egauge_minutes.use, electricity_egauge_minutes.gen FROM university.electricity_egauge_minutes WHERE dataid=$j AND localminute BETWEEN '$i-01-01 00:00:00' AND '$i-12-31 23:59:00' ORDER BY localminute ASC) TO '$OUT_FILE' CSV DELIMITER ';'"
	done
done
