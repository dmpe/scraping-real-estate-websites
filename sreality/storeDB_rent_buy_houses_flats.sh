#!/bin/bash

clear

echo "run with sudo"
echo "chmod u+x script1.sh && ./script_name.sh"

cd scraping_data

echo "changed dir. now execute PDF creation"

python3 sreality_a.py 7 buy

echo "Done with apartments-buy"
echo "  "

python3 sreality_a.py 7 rent

echo "Done with apartments-rent"
echo "  "

python3 sreality_h.py 7 buy

echo "Done with houses-buy"
echo "  "

python3 sreality_h.py 7 rent


echo "All Done"
exit
