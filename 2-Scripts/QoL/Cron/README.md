# Cron 

The notes on Cron are located in [Cron README.md](../../../3-Docs_References/OS-Linux/Cron/README.md)

## auth-user.sh
This script takes on argument in the form 
```
./auth-user.sh <user>
``` 
Where *user* is a username that will be added to the appropriate allow lists making it possible for a user to schedule and run cronjobs (or at!).

## setup-schedule.sh
This is a script that takes one argument in the form

```
./setup-schedule.sh <Path-To-Script>
```
Where *Path-To-Script* is a path to an executable we would like to run every minuet.