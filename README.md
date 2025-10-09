# Container Manager for all armv8

<a href="https://github.com/007revad/ContainerManager_for_all_armv8/releases"><img src="https://img.shields.io/github/release/007revad/ContainerManager_for_all_armv8.svg"></a>
![Badge](https://hitscounter.dev/api/hit?url=https%3A%2F%2Fgithub.com%2F007revad%2FContainerManager_for_all_armv8&label=Visitors&icon=github&color=%23198754&message=&style=flat&tz=Australia%2FSydney)
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/paypalme/007revad)
[![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/007revad)
[![committers.top badge](https://user-badge.committers.top/australia/007revad.svg)](https://user-badge.committers.top/australia/007revad)

### Description

Script to install Container Manager on a RS819, DS119j, DS418, DS418j, DS218, DS218play or DS118

There is no technical reason why these NAS models with a Realtek RTD1296, or Marvell A3720, CPU are excluded from installing Container Manager when they have the same CPU as the DS220j, or DS120j.

So I made a script to install the ContainerManager-armv8 package on any model with a Realtek RTD1296 (or Marvell A3720?) CPU running DSM 7.2 or later.

v2 and later can now update Container Mananger if there's a newer version available.

### Confirmed working on

| Model      | CPU | DSM version              | Working | Notes |
| ---------- |-----|--------------------------|---------|-------|
| RS819      | Realtek RTD1296 | DSM 7.2.2-72803 | yes |  |
| DS119j     | Marvell A3720 | DSM 7.2.2-72806 Update 2 | yes |  |
| DS418      | Realtek RTD1296 | DSM 7.3-81180 | yes |  |
| DS418      | Realtek RTD1296 | DSM 7.2.2-72806 Update 3 | yes |  |
| DS418      | Realtek RTD1296 | DSM 7.2.2-72806 Update 2 | yes |  |
| DS418      | Realtek RTD1296 | DSM 7.2.1-69057 Update 5 | yes |  |
| DS418      | Realtek RTD1296 | DSM 7.2.1-69057 Update 4 | yes |  |
| DS418j     | Realtek RTD129**3** | DSM 7.2.1-69057 Update 5 | yes |  |
| DS218      | Realtek RTD1296 | DSM 7.2.1-69057 Update 5 | yes |  |
| DS218      | Realtek RTD1296 | DSM 7.2.1-69057 Update 3 | yes |  |
| DS218play  | Realtek RTD1296 | DSM 7.3-81180 | yes |  |
| DS218play  | Realtek RTD1296 | DSM 7.2.2-72806 Update 3 | yes |  |
| DS218play  | Realtek RTD1296 | DSM 7.2.1-69057 Update 6 | yes |  |
| DS218play  | Realtek RTD1296 | DSM 7.2.1-69057 Update 5 | yes |  |
| DS118      | Realtek RTD1296 | DSM 7.2.1-69057 Update 1 | yes |  |

### Will NOT work on models with a 32 bit CPU

<details>
  <summary>Click here to see list of models with a 32 bit armv71 CPU</summary>

<br>

| Model      | CPU | Package Arch |  | uname -m | Working |
| ---------- |-----|--------------|--|----------|---------|
| DS419slim  | Marvell Armada 385 88F6820 | armada38x | 32 bit | armv71 | no |
| DS218j     | Marvell Armada 385 88F6820 | armada38x | 32 bit | armv71 | no |
| RS217      | Marvell Armada 385 88F6820 | armada38x | 32 bit | armv71 | no |
| RS816      | Marvell Armada 385 88F6820 | armada38x | 32 bit | armv71 | no |
| DS416slim  | Marvell Armada 385 88F6820 | armada38x | 32 bit | armv71 | no |
| DS416j     | Marvell Armada 385 88F6820 | armada38x | 32 bit | armv71 | no |
| DS216j     | Marvell Armada 385 88F6820 | armada38x | 32 bit | armv71 | no |
| DS216      | Marvell Armada 385 88F6820 | armada38x | 32 bit | armv71 | no |
| DS116      | Marvell Armada 385 88F6820 | armada38x | 32 bit | armv71 | no |

</details>

### Download the script

1. Download the latest version _Source code (zip)_ from https://github.com/007revad/ContainerManager_for_all_armv8/releases
2. Save the download zip file to a folder on the Synology.
3. Unzip the zip file.

### To run the script via SSH

[How to enable SSH and login to DSM via SSH](https://kb.synology.com/en-global/DSM/tutorial/How_to_login_to_DSM_with_root_permission_via_SSH_Telnet)

```YAML
sudo -s /volume1/scripts/install_container_manager.sh
```

**Note:** Replace /volume1/scripts/ with the path to where the script is located.

### When you run the script

The script will try to install Container Manager itself. 

If you get a _"Failed to query package list from server"_ error the script will pause and wait for you to do a Manual Install, and then the script will continue after you type **yes**.

### Steps to do a Manual Install if the scripts asks you to: <br>

Do **NOT** exit the script or close the window.

1. Download the latest **ContainerManager-armv8** spk file from https://archive.synology.com/download/Package/ContainerManager
2. Open Package Center. If it is already open close it and re-open it.
3. Click on the Manual Install button.
4. Click on the Browse button.
5. Browse to where you saved the ContainerManager spk file.
6. Select the spk file and click Open.
7. Click Next and install Container Manager.
8. Close Package Center.
9. Return to the script window and type **yes** so the script can restore the correct model number.

<p align="center">Manual Install of Container Manager</p>
<p align="center"><img src="/images/package_manual_install.png"></p>

### What to do after running the script

1. Open Package Center (if Package Center is already open close it and re-open it).
2. Click on Settings.
3. Click on Auto Update.
4. Select "Only packages below".
5. Make sure "All Packages" is **NOT** ticked.
6. Make sure "Important Versions" is **NOT** ticked.
7. Click OK.

<p align="center">Prevent Container Manager from auto updating</p>
<p align="center"><img src="/images/disable_auto_updates.png"></p>

### Screenshots

<p align="center">Installing Container Manager</p>
<p align="center"><img src="/images/script_install_auto.png"></p>

<p align="center">Installing Container Manager via Manual Install</p>
<p align="center"><img src="/images/script_install_manual.png"></p>

<p align="center">Upgrading Container Manager to latest version</p>
<p align="center"><img src="/images/script_upgrade.png"></p>
