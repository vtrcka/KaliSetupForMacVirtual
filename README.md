# Kali Setup For Mac Virtual (ARM64 M-series)
Setup for Apple ARM M-series, setup

## Update GRUB !! Disable arm64.nosve

```
sudo nano /etc/default/grub
```
Modify >>

```
GRUB_CMD_LINUX_DEFAULT="quite splash arm64.nosve"
```
Update GRUB >>
```
sudo update-grub && sudo reboot
```

## Update to current version

### Setup HTTPS in kali-tweaks & Upgrade

Setup kali-tweaks >>
```
sudo kali-tweaks

Network Repositories > Protocol HTTPS > Apply
```
Upgrade >>
```
sudo apt update && sudo apt dist-upgrade -y && sudo reboot
```

## Weaponized terminal 

```
sudo apt update && sudo apt install terminator -y
sudo update-alternatives --set x-terminal-emulator /usr/bin/terminator
```
### Some tweaks config, infinite history, background, start maximized etc. >>

Setup script /script/setup_terminator.sh >>
```
Usage: ./setup_terminator.sh [-u user1,user2,...] [-r]
  -u user1,user2,...  : Specify multiple usernames for setup, separated by commas (e.g., kali,user2).
  -r                  : Download the config file for the root user.
```

### Useful packages to install
## Basic
```
sudo apt update && sudo apt install -y seclists burpsuite dirsearch golang git gobuster ffuf wfuzz xxd sublist3r amass feroxbuster pdfcrack dirsearch
```

