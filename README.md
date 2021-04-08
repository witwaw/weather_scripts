# weather_scripts
A collection of scripts to auto-collate (i.e. download, animate, etc.) weather data for paragliding and other similar aviation activities.


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
