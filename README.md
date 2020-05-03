# WLANPi Hotspot
*Turn your WLANPi in to test AP*

This is a package created using the information in François Vergès blog article : [WLAN Pi - Setup a Wi-Fi Hotspot](https://www.semfionetworks.com/blog/wlan-pi-setup-a-wi-fi-hotspot)

This package is accessed using the menu system detailed in the WLANPi project : [Bakebit](https://github.com/WLAN-Pi/BakeBit)

## Requirements

To provide a test hotspot using your WLANPi, you will need:

 - a supported wireless adapter plugged in to one USB port of the WLANPi (e.g. CF-912AC, CF-915AC)
 - WLANPi distribution v1.7 or later installed on a WLANPi (https://github.com/WLAN-Pi/wlanpi/releases), which includes [Bakebit](https://github.com/WLAN-Pi/BakeBit) v0.17 or later

## Configurations Options

It is very likely that you will not want to use this utility with the default shared key, channel and SSID. 

To change from the default settings, ensure that the WLANPi is operating in standard "classic"mode. Then, edit the file: /etc/wlanpihostpot/conf/hostapd.conf. This can be done by opening an SSH session to the WLANPi and using the 'nano' editor:

```
 sudo nano /etc/wlanpihotspot/conf/hostapd.conf
```

There are numerous fields you can configure to change the behavior of the hotspot access point feature, but here are some of the more likely fields you'll want to look at and perhaps update (note that lines beginning with a # character are comments and do not affect operation):

```
    # WLAN SSID
    ssid=wlanpi_hotspot

    # WPA-PSK
    wpa_passphrase=wifipros

    # Mode options: a=5GHz / g=2.4GHz
    hw_mode=a

    # Set 2.4GHz Channel - 1,6,11
    # Set 5GHz Channel - 36,40,44,48,149,153,157,161,165
    channel=36

    # Set Country Code (Use your own country code here)
    country_code=CA
```

Once you have made your changes, hit Ctrl-X in the nano editor to exit and hit "Y" to save the changes when prompted.

Next, flip the WLANPi back in to "Hotspot" mode as described in previous sections. After the accompanying reboot, the WLANPi should operate using the newly configured parameters.

# Using Hotspot Mode

Following the WLANPi reboot, by default, an SSID of "wlanpi_hotspot" will be available on channel 36. You can join the SSID with a wireless client (e.g. your laptop) using the default shared key: "wifipros".

Once you have joined the SSID, an IP address is assigned to your client device via DHCP and you will have access to the WLANPi. You will be able to access features such as the speedtest using a browser pointed at : http://192.168.88.1/

# Background

(It is possible to flip in to Hotspot mode using the Linux CLI, but it is strongly recommended to use the native WLANPi front panel navigation menu)

As there are quite a few networking changes we need to make for the Hotspot to operate correctly, we need to flip the WLANPi in to a completely new mode of operation that uses a different network configuration. The 'hotspot_switcher' script is used to switch between the usual "classic" mode of operation and the "Hotspot" mode. 

When moving to the "Hotspot" mode, various configuration files are changed on the WLANPi, with the original networking files being preserved to allow restoration to the original ("classic" mode) configuration. 

When moving back to the original "classic" mode, all changed files are restored to their original state. 

When moving between modes, the WLANPi will reboot to ensure that all new network configuration starts cleanly. 

## Enabling Hotspot Mode (Via CLI)

To flip the WLANPi in to "Hotspot" mode, SSH to the WLANPi and execute the following command:

```
 sudo /etc/wlanpihotspot/hotspot_switcher on
```

At this point, the WLANPi will reboot so that the new networking configuration will take effect. 


## Exiting Hotspot Mode (via CLI)

To switch out of "Hotspot" mode, SSH to the WLANPi using network address 192.168.88.1 and run the command: 

```
 sudo /etc/wlanpihotspot/hotspot_switcher off
```

When this command is executed, the original ("classic" mode) networking configuration files will be restored and the WLANPi will reboot. After the reboot, the WLANPi will operate as it did before the switch to "Hotspot" mode.

*** Note: The front panel menu system available from image version v1.7 is a much better option for flipping WLANPi modes as it carried far less risk of causing operational issues ***


## Installation (only required by image developers, code is included with WLAN Pi image for regular users)

The install/upgrade process is relatively easy. We simply connect the WLANPi to the Internet and pull the latest files from our GitHub repository. Note that you will lose any customizations you previously applied (e.g. SSID name changes etc.), so back up any config files you need before doing this.

To install (or upgrade) the required files, connect your WLANPi to a network so that it has Internet access. Then SSH to your WLANPi and execute the following commands on the CLI of the WLANPi (make sure you copy & paste each command individually, as you will be prompted to enter a password at some point - use your wlanpi user password):

```
# Copy & paste these one at a time - you will likely need to enter your password at least once
# You will lose any customizations you previously applied, so back up any config files
# you need before doing this.
cd /etc
sudo rm -r ./wlanpihotspot
sudo git clone https://github.com/WLAN-Pi/wlanpihotspot.git
sudo sh /etc/wlanpihotspot/set_file_permissions.sh
```
 
Installation should now be now complete. If you are using the native WLANPi front panel menu system to flip modes and activate the hotspot(which is available from image ver v1.7 & highly recommended!).


