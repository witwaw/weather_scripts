#!/bin/bash
#!/bin/sh
#
# SCRIPT NAME: TephiAnim
#
# ver 02.10
#
# last updated: 2021-04-08--0807 GMT
#
# LICENCE: Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
#
# AUTHOR: Witold Wawszczak MSc, club: DSC (UK), BHPA No: 30082
#
# SPECIAL THANKS: Pawel Botulinski
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
# REQUIREMENTS: Unix-like machine (Linux, Unix, BSD, macOS, etc.), bash 4.0 or higher, wget, imagemagick (or the "convert" at least), min 20 MB free disk space per day (see the "final word" section), optionally also an auto-run solution to run this script daily and automatically (i.e. cron). MacOS users: please ensure to manually upgrade your bash to version 4.0 or higher.  Windows10 users: please google how to install Linux's Bash in Windows so that you can run Bahs scripts.
#
# DEPLOYMENT: copy this script into a location of your choice, change attributes to executable (i.e. chmod u+x tephianim.sh or chmod 755 tephianim.sh)
#
# RUN: in a command line type: bash ./<path>/tephianim.sh
#
# AUTO-RUN: add execution of this script into an automated running solution (i.e. cron)
#
# DEVELOPMENT AND MODIFICATIONS: This script can be developed further i.e. by allowing generation of animations for other locations. Please credit the original author as per licence. Thank you.
#
# FINAL WORD: At 1000x1000 px, each resultant animation takes up to 1.85 MB of disk space and there are 2 files created for each day. Over 30 days (average month), this will generate approx. 110 MB of permanent data per month per each location + approx. 15 MB of temp files at each run (the latter are immediately deleted). Please consider an adequate free storage space or periodic purging of the data on the deployment machine. Cron or a similar tool is recomended both for running this script and purging unneeded data.


# Welcome text
# Possible tweaks:
# 1. Adjust the echo text to your liking
# 2. Silence this section by commenting (addin a hash) at the beginning of lines starting with "echo"
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

As always, google is your friend."
>&2;
   exit 1;
fi

# Definitions of URL's and dates (current and the next day)
# Possible tweaks:
# 1. change the number to get soundings for a different location. Check the URL of relevant image at RASP soundings and relevant lines in this script. See this file for 


# If this script is evoked with a specific location, it generates sounding animation for that location. Otherwise it waits 5 sec for the user to specify location. If no location provided, it uses the default.

# The below list will be of a help. For more details see:
# http://rasp.stratus.org.uk/modules/mod_rasp_configuration/config.js



# Matrix (associative array) of locations and their numbers in original URL's at RASP
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


# Default location 
# Possible tweaks:
# 1. Switch the default location of generated tephigram animations by changing the number below
LOC="16"

# Do NOT modify the line below
LOCTXT=${LOCMTRX[$LOC]}


# Ask user for location of the desired sounding to animate
# Possible tweaks:
# 1. Silence or reduce this section by commenting (addin a hash) at the beginning of lines starting with "echo". Note that this will not change at all how the rest of this script works (i.e. final animation GIF size, number of frames or delay between frames/speed of animation), but only provide less visual clues for user.
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
# Ask user for the desired location of tephigrams. If no choice made after timeout, the default location will be used
# Possible tweaks:
# 1. Adjust the timeout by changing the number next to "total"
# 2. DO NOT comment (add a hash) at the beginning of "echo" line, because this one is functional - takes data input from user
total=30  # Total wait time in seconds
count=0  # Time counter
while [ ${count} -lt ${total} ] ; do
    tlimit=$(( $total - $count ))
    echo -e "\rYou have ${tlimit} seconds (default is $LOC - $LOCTXT): \c"
    read -t 1 LOC2
    test ! -z $LOC2 && { break ; }
    count=$((count+1))
done


# Possible tweaks:
# 1. Silence this section by commenting (adding a hash) at the beginning of line starting with "echo" command
if [ -z "$LOC2" ] ; then
    echo "No location specified, generating animated tephigrams for default location: ($LOC - $LOCTXT)"
    LOCTXT=${LOCMTRX[$LOC]}
else
	LOC=$LOC2
	LOCTXT=${LOCMTRX[$LOC]}
	echo "Generating animated tephigrams for $LOCTXT ($LOC)"
fi


# Definition of a generic URL for soundings - prefix - current day
# Do not modify this section unless you know what you're doing
URLPREFTD=http://rasp.mrsap.org/UK2/FCST/sounding"$LOC".curr.

# Definition of a generic URL for soundings - prefix - next day
# Do not modify this section unless you know what you're doing
URLPREFTOM=http://rasp.mrsap.org/UK2+1/FCST/sounding"$LOC".curr.

# Definition a generic URL for soundings - suffix - any day
# Do not modify this section unless you know what you're doing
URLSUFF="00lst.d2.png"

# Definition of dates for current day and next day
# Do not modify this section unless you know what you're doing
DATETD=$(date +%Y-%m-%d)
DATETOM=$(date --date="next day" +%Y-%m-%d)

# Check if any temp work directories exist. If so - purge, otherwise - ignore.
# Possible tweaks:
# 1. Silence this section by commenting (adding a hash) at the beginning of lines starting with "echo" command
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
# Possible tweaks:
# 1. Silence this section by commenting (adding a hash) at the beginning of a line starting with "echo" command
echo "Creating fresh temp work directories"
mkdir temp_soundings_"$DATETD"
mkdir temp_soundings_"$DATETOM"


# Check if the directory for animations exists. If so - skip to the next step, otherwise - create a fresh one.
# Possible tweaks:
# 1. Silence this section by commenting (adding a hash) at the beginning of a line starting with "echo" command
if [[ ! -d tephigram_animations ]]
then
    echo "No dir for soundings animations detected - creating new"
    mkdir tephigram_animations
fi


# Download raw tephigrams for the current day
# Possible tweaks:
# 1. Reduce number of animation steps by deleting respective numbers in the "for" line. Each number corresponds to a specific time, as provided by RASP soundings
# 2. Silence this section by commenting (adding a hash) at the beginning of lines starting with "echo" command
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
# 1. Manipulate animation speed by changing the nuber after the "delay" (a delay between each image in miliseconds)
# 2. Manipulate the final animation image size and disk space occupied by adjusting the number after the "resize" (in pixels)
# 3. Silence this section by commenting (adding a hash) at the beginning of line starting with "echo" command
echo "Creating tephigram animation for $LOCTXT for today ($DATETD) - this may take a while..."
convert -delay 200 temp_soundings_"$DATETD"/*.png -resize 1000x1000 tephigram_animations/tephigram_"$LOCTXT"_"$DATETD"_generated_"$DATETD"_density2k.gif
echo "Done"


# Download tephigrams for the next day
# Possible tweaks:
# 1. Reduce number of animation steps by deleting respective numbers in the "for" line. Each number corresponds to a specific time, as provided by RASP soundings
# 2. Silence this section by commenting (adding a hash) at the beginning of lines starting with "echo" command
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
# 1. Manipulate animation speed by changing the nuber after the "delay" (a delay between each image in miliseconds)
# 2. Manipulate the final animation image size and disk space occupied by adjusting the number after the "resize" (in pixels)
# 3. Silence this section by commenting (adding a hash) at the beginning of lines starting with "echo" command
echo "Creating tephigram animation for $LOCTXT for tomorrow ($DATETOM) - this may take a while..."
convert -delay 200 temp_soundings_"$DATETOM"/*.png -resize 1000x1000 tephigram_animations/tephigram_"$LOCTXT"_"$DATETOM"_generated_"$DATETD"_density2k.gif
echo "Done"


# Delete all temporary work directories
# Possible tweaks:
# 1. Comment these 4 lines below to preserve temporary soundings images (default action: purge all downloaded soundings to save disk space)
# 2. Silence this section by commenting (adding a hash) at the beginning of line starting with "echo" command
echo "Purging temp work directories"
rm -rf temp_soundings_$DATETD
rm -rf temp_soundings_$DATETOM
echo "Done"


# Say goodbye and exit
# Possible tweaks:
# 1. Adjust the text below to your liking
# 2. Silence this section by commenting (adding a hash) at the beginning of line starting with "echo" command
echo "All done. Thank you for using the TephiAnim. Remember: safe flying is the ultimate pilot's responsibility."
