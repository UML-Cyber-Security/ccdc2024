#! /bin/bash

#********************************
# Written by a sad Matthew Harper...\
# One argument to create a new cron job to run every minuet
#********************************

# Check if the scrip is ran as root.
# $EUID is a env variable that contains the users UID
# -ne 0 is not equal zero
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# https://stackoverflow.com/questions/878600/how-to-create-a-cron-job-using-bash-automatically-without-the-interactive-editor
# Write out current crontab
# echo new cron job 
# Run the job every 5 minuets (Any over 5)
crontab -l > new-cron
echo "*/1 * * * * $1" >> new-cron
crontab new-cron
rm new-cron
#install new cron file
#crontab mycron
#rm mycron