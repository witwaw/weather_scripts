#!/bin/bash
#!/bin/sh
#
# SCRIPT NAME: TephiAnim
#
# ver 02.09
# last updated: 2021-04-08--0715 GMT
# LICENCE: Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
# AUTHOR: Witold Wawszczak MSc, club: DSC (UK), BHPA No: 30082
# special thanks: Pawel Botulinski
#
# DISCLAIMER: Before attempting any modifications at all, please familiarise yourself with the Bash scripting language.
#
# DESCRIPTION: A bash script to generate soundings animations for various locations (default is Camphill in Derbyshire). For each day it uses hour-by-hour soundings in max available grid resolution (2 km) to create two animations: one on the actual day and one for the next day. Animations are scaled to save space.
#
# PURPOSE: To automate creation of animated tephigrams, which are permanently deleted from the RASP server the next day, thus not allowing to go back if not saved for that day before midnight.
#
# INTENDED USAGE: Pre-flight assessment (for flyability) OR post-flight comparison of conditions vs. forecasted soundings (for pilots' learning and development)
#
# INTENDED AUDIENCE: paraglider and hang-glider pilots; possibly also: microlights and RC models (incl. drones)
#
# SUGGESTED DISTRIBUTION: Allow remote acces to resultant animations via web interface. Location and accessibility - of your choice.
#
# REQUIREMENTS: Unix-like machine (Linux, Unix, BSD, macOS, etc.), bash 4.0 or higher, wget, imagemagick package (or the "convert" at least), min 20 MB free disk space per day (see the "final word" section), optionally also a cron to run this script automatically at daily intervals. MacOS users: please ensure to manually upgrade your bash to version 4.0 or higher.
#
# DEPLOYMENT: copy this script into a location of your choice, change attributes to executable (i.e. chmod u+x <this_script_filename.sh> or chmod )
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
echo "
Welcome to TephiAnim - a script to auto-generate soundings/tephigrams as animated GIF's.
Please read the manual.
For best results, run this script daily by some automated means (i.e. cron).
If you don't know how - google has plenty of resources and step-by-step tutorials.
Fly safe!
/Witold Wawszczak MSc/
"

if ((BASH_VERSINFO[0] < 4)); then
   echo "Looks like you are a MacOS user.

This script uses so called 'associative arrays' feature that requires Bash shell to be in version 4.0 or higher. Whilst Apple won't upgrade Bash any higher than 3.0 purely for commercial reasons, it is perfectly possible that a user can do that themselves.

For simplicity, please install package manager called Homebrew, which will allow to easily upgrade your Bash to ver 4.0 or higher. Then reload your newly upgraded Bash by typing in command line 'exec bash' and you are ready to run this script.

Ideally, make the upgraded Bash to be the default one. Either with 'chpass' command-line tool or graphically in: Menu -> System Preferences -> Users and Groups -> Advanced Options -> Login shell' then change to '/usr/local/bin/bash'.

As always, google is your friend." >&2;
   exit 1;
fi

# Definitions of URL's and dates (current and the next day)
# Possible tweaks:
# 1. change the number to get soundings for a different location. Check the URL of relevant image at RASP soundings and relevant lines in this script. See this file for 


# If this script is evoked with a specific location, it generates sounding animation for that location. Otherwise it waits 5 sec for the user to specify location. If no location provided, it uses the default.

# The below list will be of a help. For more details see:
# http://rasp.stratus.org.uk/modules/mod_rasp_configuration/config.js

# LOCATIONS - names and GPS centres


# 1: Exeter	centre: [50.7344	-3.4139]
# 2: Fairford	centre: [51.6820	-1.7900]
# 3: Herstmonceaux	centre: [50.8833	0.3333]
# 4: Newtown	centre: [52.5157	-3.3000]
# 5: Cambridge	centre: [52.2050	0.1750]
# 6: Nottingham	centre: [52.9667	-1.1667]
# 7: Cheviots	centre: [55.5000	-2.2000]
# 8: Callander	centre: [56.2500	-4.2333]
# 9: Aboyne	centre: [57.0833	-2.8333]
# 10: Buckingham	centre: [52.0000	-0.9833]
# 11: Larkhill	centre: [51.2000	-1.8167]
# 12: Leeds	"centre: [53.8690	-1.6500]
# 13: Carrickmore	centre: [54.5990	-7.0490]
# 14: CastorBay NI	centre: [54.5000	-6.3300]
# 15: Talgarth	centre: [51.979558	-3.206081]
# 16: Camphill	centre: [53.3050	-1.7291]

declare -A LOCMTRX
num_rows=16
num_columns=2
LOCMTRX[1]="Exeter"
LOCMTRX[2]="Fairford"
LOCMTRX[3]="Herstmonceaux"
LOCMTRX[4]="Newtown"
LOCMTRX[5]="Cambridge"
LOCMTRX[6]="Nottingham"
LOCMTRX[7]="Cheviots"
LOCMTRX[8]="Callander"
LOCMTRX[9]="Aboyne"
LOCMTRX[10]="Buckingham"
LOCMTRX[11]="Larkhill"
LOCMTRX[12]="Leeds"
LOCMTRX[13]="Carrickmore"
LOCMTRX[14]="CastorBay NI"
LOCMTRX[15]="Talgarth"
LOCMTRX[16]="Camphill"




# Define default location by changing the number in the line below
LOC="16"

# And do NOT modify this line
LOCTXT=${LOCMTRX[$LOC]}

# Ask user for location of the desired sounding
echo "Which location would you like the sounding for?
"
echo " 1 - Exeter, centre: [50.7344, -3.4139]"
echo " 2 - Fairford, centre: [51.6820, -1.7900]"
echo " 3 - Herstmonceaux, centre: [50.8833, 0.3333]"
echo " 4 - Newtown, centre: [52.5157, -3.3000]"
echo " 5 - Cambridge, centre: [52.2050, 0.1750]"
echo " 6 - Nottingham, centre: [52.9667, -1.1667]"
echo " 7 - Cheviots, centre: [55.5000, -2.2000]"
echo " 8 - Callander, centre: [56.2500, -4.2333]"
echo " 9 - Aboyne, centre: [57.0833, -2.8333]"
echo "10 - Buckingham, centre: [52.0000, -0.9833]"
echo "11 - Larkhill, centre: [51.2000, -1.8167]"
echo "12 - Leeds, centre: [53.8690, -1.6500]"
echo "13 - Carrickmore, centre: [54.5990, -7.0490]"
echo "14 - CastorBay NI, centre: [54.5000, -6.3300]"
echo "15 - Talgarth, centre: [51.979558, -3.206081]"
echo "16 - Camphill, centre: [53.3050, -1.7291]

"

total=30  # Total wait time in seconds
count=0  # Time counter
while [ ${count} -lt ${total} ] ; do
    tlimit=$(( $total - $count ))
    echo -e "\rYou have ${tlimit} seconds (default is $LOC - $LOCTXT): \c"
    read -t 1 LOC2
    test ! -z $LOC2 && { break ; }
    count=$((count+1))
done

if [ -z "$LOC2" ] ; then
    echo "No location specified, generating animated tephigrams for default location: ($LOC - $LOCTXT)"
    LOCTXT=${LOCMTRX[$LOC]}
else
	LOC=$LOC2
	LOCTXT=${LOCMTRX[$LOC]}
	echo "Generating animated tephigrams for $LOCTXT ($LOC)"
fi



#URLPREFTD="http://rasp.mrsap.org/UK2/FCST/sounding16.curr."
URLPREFTD=http://rasp.mrsap.org/UK2/FCST/sounding"$LOC".curr.

#URLPREFTOM="http://rasp.mrsap.org/UK2+1/FCST/sounding16.curr."
URLPREFTOM=http://rasp.mrsap.org/UK2+1/FCST/sounding"$LOC".curr.

URLSUFF="00lst.d2.png"

DATETD=$(date +%Y-%m-%d)
DATETOM=$(date --date="next day" +%Y-%m-%d)

# Check if any temp work directories exist. If so - purge.

if [[ -d temp_soundings_"$DATETD" ]]
then
    echo "An old temp work dir detected - purging"
    rm -rf temp_soundings_"$DATETD"
fi

if [[ -d temp_soundings_"$DATETOM" ]]
then
    echo "An old temp work dir detected - purging"
    rm -rf temp_soundings_"$DATETOM"
fi


# Create fresh temp work directories
echo "Creating fresh temp work directories"
mkdir temp_soundings_"$DATETD"
mkdir temp_soundings_"$DATETOM"


# Check if the directory for animations exists. If so - skip to the next step, otherwise - create a fresh one.

if [[ ! -d tephigram_animations ]]
then
    echo "No dir for soundings animations detected - creating new"
    mkdir tephigram_animations
fi




# Download tephigrams for the current day
echo "Downloading raw tephigrams for $LOCTXT for today ($DATETD)"
for tm in '07' '08' '09' '10' '11' '12' '13' '14' '15' '16' '17' '18' '19'
do
    echo -n " ... $tm:00"
	wget -q $URLPREFTD$tm$URLSUFF -P temp_soundings_"$DATETD"
done
echo "
Done"

# Create animated tephigrams for the current day
# Possible tweaks:
# 1. Change "delay" number to manipulate the animation speed (delay between each image in miliseconds)
# 2. Change the "resize" value to manipulate resolution of the image and it's disk size
echo "Creating tephigram animation for $LOCTXT for today ($DATETD) - this may take a while..."
convert -delay 200 temp_soundings_"$DATETD"/*.png -resize 1000x1000 tephigram_animations/tephigram_"$LOCTXT"_"$DATETD"_generated_"$DATETD"_density2k.gif
echo "Done"



# Download tephigrams for the next day
echo "Downloading raw tephigrams for $LOCTXT for tomorrow  ($DATETOM)"
for tm in '07' '08' '09' '10' '11' '12' '13' '14' '15' '16' '17' '18' '19'
do
    echo -n " ... $tm:00"
    wget -q $URLPREFTOM$tm$URLSUFF -P temp_soundings_"$DATETOM"
done
echo "
Done"

# Create animated tephigrams for the next day
# Possible tweaks:
# 1. Change "delay" number to manipulate the animation speed (delay between each image in miliseconds)
# 2. Change the "resize" value to manipulate resolution of the image and it's disk size
echo "Creating tephigram animation for $LOCTXT for tomorrow ($DATETOM) - this may take a while..."
convert -delay 200 temp_soundings_"$DATETOM"/*.png -resize 1000x1000 tephigram_animations/tephigram_"$LOCTXT"_"$DATETOM"_generated_"$DATETD"_density2k.gif
echo "Done"




# Delete all temporary work directories
# Possible tweaks:
# 1. Comment these 4 lines below to preserve temporary soundings images (default action: purge all downloaded soundings to save disk space)
echo "Purging temp work directories"
rm -rf temp_soundings_$DATETD
rm -rf temp_soundings_$DATETOM
echo "Done"

# Say goodbye and exit
# Possible tweaks:
# 1. Adjust the text below to your liking
echo "All done. Thank you for using the TephiAnim. Remember: safe flying is the ultimate pilot's responsibility."
