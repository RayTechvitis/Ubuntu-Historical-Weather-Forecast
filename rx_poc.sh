#!/bin/bash

# Set timezone to Casablanca
TZ='Morocco/Casablanca'

# Step 2.2.1: Create the filename for today's date
TODAY=$(date +%Y%m%d)
FILENAME="raw_data_$TODAY"

# Step 2.2.2: Download the weather report
curl -s "https://wttr.in/Casablanca" -o "$FILENAME"

#grep -oE '\+[0-9]+' "$FILENAME" | awk -F '+' '{print $2}' > temperature.txt

# Step 3.1.1: Extract the current noon temperature
curr_tmp=$(grep "°C" "$FILENAME" | awk '{print $(NF-1), $NF}' | head -1)

# Step 3.1.2: Extract tomorrow's noon temperature forecast
for_tmp=$(grep -A 6 -m 4 "┤" "$FILENAME" | tail -n 5 | head -n 1 | awk '{print $11, $12}')

# Debugging - echo the temperatures to verify
echo "Observed Temperature: $curr_tmp"
echo "Forecasted Temperature: $for_tmp"

# Step 3.2: Get current date details
year=$(date +%Y)
month=$(date +%m)
day=$(date +%d)

grep -oE '\+[0-9]+' "$FILENAME" | awk -F '+' '{print $2}' > temperature.txt
obs_tmp=$(head -n 6 temperature.txt | awk 'NR==1')
fc_tmp=$(head -n 6 temperature.txt | awk 'NR==6')
difference=$((fc_tmp-obs_tmp))
echo "$difference"

# Step 3.3: Combine the data into a single row
record="$year\t$month\t$day\t$obs_tmp\t$fc_tmp\t$difference"

# Ensure the record has no leading or trailing whitespace
record=$(echo -e "$record" | sed 's/^[ \t]*//;s/[ \t]*$//')

# Append the record to the log file
echo -e "$record" >> rx_poc.log
