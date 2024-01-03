# Install-Remove

This script is a bit of a mess, but it will install a series of packages and then will remove those that are never needed (or rarely!)

## Install
* updates package lists
* upgrades current packages
* python3: Needed for python, and some ansible!
* sudo: Ensure sudo packages are installed 
* google-authenticator: Old Idea for MFA on Sudo use

## Removes 
* [ftp](https://ubuntu.com/server/docs/service-ftp): FTP is inherently insecure and SFTP should be used 
* [telnet](https://linux.die.net/man/1/telnet): Telnet is inherently insecure and SSH should be used
* [autofs](https://wiki.archlinux.org/title/autofs): Automatically mounts filesystems onto the linux system; allows attackers to automatically mount remote filesystems that contain exploits!
* [nis](https://wiki.archlinux.org/title/NIS): Allows users to "defer authentication" to another server...
* [talk](https://wiki.archlinux.org/title/Talkd_and_the_talk_command): Command allows for remote communication, no need. 
* [rsh-client](https://www.ibm.com/docs/en/zos/2.2.0?topic=srrrib-rsh-command-execute-command-remote-host-receive-results-your-local-host): Insecure, host based (hostname) authentication.
