#!/bin/bash
#!/bin/sh
#
# SCRIPT NAME: TephiAnim
#
# ver 02.09
# last updated: 2021-04-07--2347 GMT
# LICENCE: Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
# AUTHOR: Witold Wawszczak MSc, club: DSC (UK), BHPA No: 30082
# special thanks: Pawel Botulinski
#
# DESCRIPTION: A bash script to generate soundings animations for Camphill weather station (Derbyshire). For each day it uses hour-by-hour soundings in max available grid resolution (2 km) to create two animations: one on the actual day and one for the next day. Animations are scaled to save space.
#
# PURPOSE: To automate creation of animated tephigrams, which are permanently deleted from the RASP server the next day, thus not allowing to go back if not saved for that day before midnight.
#
# INTENDED USAGE: Pre-flight assessment (for flyability) OR post-flight comparison of conditions vs. forecasted soundings (for pilots' learning and development)
#
# INTENDED AUDIENCE: paraglider and hang-glider pilots; possibly also: microlights and RC models (incl. drones)
#
# SUGGESTED DISTRIBUTION: Allow remote acces to resultant animations via web interface. Location and accessibility - of your choice.
#
# REQUIREMENTS: Unix-like machine (Linux, Unix, BSD, macOS, etc.), bash (non-root), wget, imagemagick (or the "convert" at least), min 20 MB free disk space per day (see the "final word" section), optionally also a cron to run this script automatically at daily intervals.
#
# DEPLOYMENT: copy this script into a location of your choice, change attributes to executable (i.e. chmod u+x <this_script_filename.sh>)
#
# RUN: in a command line type: bash ./<path>/<this_script_filename>.sh
#
# AUTO-RUN: add execution of this script into the cron to be run daily
#
# DEVELOPMENT AND MODIFICATIONS: This script can be developed further i.e. by allowing generation of animations for other locations. Please credit the original author as per licence. Thank you.
# FINAL WORD: At 1000x1000 px, each resultant animation takes up to 1.85 MB of disk space and there are 2 files created for each day. Over 30 days (average month), this will generate approx. 110 MB of permanent data + approx. 15 MB of temp files at each run. Please consider an adequate free storage space or periodic purging of the data on the deployment machine.


# Welcome text
# Possible tweaks:
# 1. Adjust the echo text to your liking
echo ""
echo "Welcome to TephiAnim - a script to auto-generate soundings/tephigrams as animated GIF's."
echo "Please see a short manual in the main script file header."
echo "Fly safe!"
echo "/Witold Wawszczak MSc/"
echo ""

URLPREFTD="http://rasp.mrsap.org/UK2/FCST/sounding16.curr."
URLPREFTOM="http://rasp.mrsap.org/UK2+1/FCST/sounding16.curr."
URLSUFF="00lst.d2.png"
DATETD=$(date +%Y-%m-%d)
DATETOM=$(date --date="next day" +%Y-%m-%d)

# Delete any existing temporary folders and create fresh ones
echo "Deleting old temp work directories (if applicable)"
rm -r temp_soundings_$DATETD
rm -r temp_soundings_$DATETOM
echo "Creating fresh temp work directories (if applicable)"
mkdir temp_soundings_$DATETD
mkdir temp_soundings_$DATETOM

# Download tephigrams for today
echo "Downloading raw tephigrams for today to a temp work directory"
for tm in '07' '08' '09' '10' '11' '12' '13' '14' '15' '16' '17' '18' '19'
do
    echo "for $tm:00 hrs"
	wget -q $URLPREFTD$tm$URLSUFF -P temp_soundings_"$DATETD"
done
echo "Done"

# Create animated tephigrams for today
# Possible tweaks:
# 1. Change "delay" number to manipulate the animation speed (delay between each image in miliseconds)
# 1. Change the "resize" value to manipulate resolution of the image and it's disk size
echo "Creating tephigram animation for today"
convert -delay 200 temp_soundings_"$DATETD"/*.png -resize 1000x1000 tephigram_animations/tephigram_Camphill_"$DATETD"_generated_"$DATETD"_density2k.gif
echo "Done"



# Download tephigrams for tomorrow
echo "Downloading raw tephigrams for tomorrow to a temp work directory"
for tm in '07' '08' '09' '10' '11' '12' '13' '14' '15' '16' '17' '18' '19'
do
    echo "for $tm:00 hrs"
    wget -q $URLPREFTOM$tm$URLSUFF -P temp_soundings_"$DATETOM"
done
echo "Done"

# Create animated tephigrams for tomorrow
# Possible tweaks:
# 1. Change "delay" number to manipulate the animation speed (delay between each image in miliseconds)
# 1. Change the "resize" value to manipulate resolution of the image and it's disk size
echo "Creating tephigram animation for tomorrow"
convert -delay 200 temp_soundings_"$DATETOM"/*.png -resize 1000x1000 tephigram_animations/tephigram_Camphill_"$DATETOM"_generated_"$DATETD"_density2k.gif
echo "Done"




# Delete all temporary work directories
# Possible tweaks:
# 1. Comment these 3 lines below to preserve temporary soundings images (default action: purge all downloaded soundings to save disk space)
echo "Purging temp work directories"
rm -r temp_soundings_$DATETD
rm -r temp_soundings_$DATETOM


# Say goodbye and exit
# Possible tweaks:
# 1. Adjust the text below to your liking
echo "All done. Thank you for using the TephiAnim. Remember: safe flying is the ultimate pilot's responsibility."
