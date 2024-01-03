# ORDER
This directory contains bash scripts to backup certain files on the system, this is because there is quite a bit of information that we can get from the files (such as history) or they could allow us to more easily revert back to a healthy state! 

## Services 

### Gluster
Active tar archives of local bricks will be stored at **/backups/gluster/active/gluster-brick-\<TAG\>**

The config will be backed up to /backups/configs/gluster

### User History 
All user histories will be backed up to **/backups/user-histories**. This goes through all home directories, and copies them with an associative name.
### SSH
The sshd_config is stored at **/backups/configs/sshd_config.backup** with the ending .backup (As you can see) 
### PAM
The Pam directory and initial conf is stored at **/backups/configs/pam**
### Firewall
Old Firewall rules will be stored at **/backups/firewall/** or in the case of ufw at **/backups/configs/ufw**
### Crontab
The **/var/spool/cron/crontabs** directory is copied to **/backups/configs/crontabs**
### Logs
The **/var/log** directory is backed up to **/backups/logs**

