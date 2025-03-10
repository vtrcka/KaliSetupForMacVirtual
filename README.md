# KaliSetupForMacVirtual
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
sudo apt update && sudo apt dist-upgrade -y
```

