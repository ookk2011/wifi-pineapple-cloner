![Project Logo](assets/logo.png)

# Wifi Pineapple Cloner v4

The Pineapple NANO and TETRA are excellent security hardware but in 2020 they reached their end of life.<br>
So to give a new life to this platform on modern hardware I developed these scripts to port it to different routers.<br>

Sometime between 2019 and 2020 we started using the private beta of this project which my friends called "Pineapple Termidor".<br>
So at the time of redoing this project I decided to rescue the original name from forgotten 🤣


## About this project

This project is the result of everything I've experienced from 2018 to 2022 to successfully clone the NANO and TETRA in any hardware.<br>

For this I've develop:
* The method of patching the file system with the minimum to be able to work. For this I created the list of files to copy and the script that copies them.
* A script to patch the file system to work on any hardware.
* Completely updated [panel](https://github.com/xchwarze/wifi-pineapple-panel) with fixes and improvements.
* Completely updated [packages repository](https://github.com/xchwarze/wifi-pineapple-community-packages) ([build](https://github.com/xchwarze/wifi-pineapple-community/tree/main/packages)).
* New [module repository](https://github.com/xchwarze/wifi-pineapple-community/tree/main/modules).
* And some new modules that are basic to use a device like this nowadays. New modules: [PMKIDAttack](https://github.com/xchwarze/wifi-pineapple-community/tree/main/modules/src/PMKIDAttack) and [Terminal](https://github.com/xchwarze/wifi-pineapple-community/tree/main/modules/src/Terminal)

![Panel](assets/termidor-mipsel.png)


## Builds

You can find the complete steps to build this project in [this document](build.md). I also added several important notes about this.
<br>


## Supported devices

There are 211 devices supported by the project. You can see the full [list here](devices.md).
<br>

Also I made a second repo for [downloads](https://github.com/xchwarze/wifi-pineapple-cloner-builds) where you can find the firmwares already made for the most common devices of the Supported devices list.
<br>


## What differences are there with other methods using other firmwares that I can download from the internet?
All firmwares found on the internet were made with [securityaddicted method](https://www.securityaddicted.com/2016/11/17/weaponizing-gl-inet-gl-ar150/) which is to copy the entire original file system. This besides consuming all the space, was often unstable, so I developed this new method.<br>
I presented this new method as part of my appearances at EkoParty 2020 and DragonJar 2021. You can see the material from those [presentations here](https://github.com/indetectables-net/embedded).<br>
In 2021 an [idiot named Samy Younsi](https://github.com/xchwarze/wifi-pineapple-cloner/issues/26) first made a post stealing the method I developed and presented at conferences... months later he ported it to python using the Wifi Pineapple Cloner v1 version and kept sharing it as if it was his work.<br>
During 2022 I managed to debug the method and how to use it until I was able to port the pineapple to any hardware and have it work 100% like the original.<br>
So the most elaborate method would be this one that achieves a very low weight in the firmware and a stability equal to the original hardware.<br>
<br>


## Install steps

1. Install OpenWrt version 19.07.7 on your router.
<br>

2. Use SCP to upload the [firmware image](https://github.com/xchwarze/wifi-pineapple-cloner-builds) in your device.
```bash
scp gl-ar750s-universal-sysupgrade.bin root@192.168.1.1:/tmp 
root@192.168.1.1's password: 
gl-ar750s-universal-sysupgrade.bin                                                                        100%   13MB   2.2MB/s   00:05 
```
<br>

3. Once the image is uploaded, execute sysupgrade command to update firmware. Wait few minutes until the device install the new firmware. 
```bash
ssh root@192.168.1.1
sysupgrade -n -F /tmp/gl-ar750s-universal-sysupgrade.bin
```
<br>

4. Enter to pineapple panel and enjoy! `http://172.16.42.1:1471/`

In the [download](https://github.com/xchwarze/wifi-pineapple-cloner-builds) repo you can find some debugging tips if you have problems.
<br>

5. Once installed, the project has a tool that helps us to do several things.
For example you can use it to change the panel theme with this command:
```bash
service wpc-tools theme_install
```


## Recomended setup

1. [GL-AR150](https://www.gl-inet.com/products/gl-ar150/) or [GL-AR750S](https://www.gl-inet.com/products/gl-ar750s)
2. USB 2.0 [2 ports hub](https://www.ebay.com/itm/144520475350)
3. Generic [RT5370 WIFI adapter](https://www.ebay.com/itm/284904442887) or [MT7612U WIFI adapter](https://www.ebay.com/itm/175219205235) **you're really going to need this on hardware that doesn't have two wifi adapters**
4. Please support Hak5 work and buy the original hardware!


## If you want to collaborate with hardware 

Those who want to help buy testing hardware or just give me a tip, you can do it by sending donations to my binance account:

![binance-qr](assets/binance-qr.png)
