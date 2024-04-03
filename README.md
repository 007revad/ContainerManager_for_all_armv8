# Container Manager for all armv8

<a href="https://github.com/007revad/ContainerManager_for_all_armv8/releases"><img src="https://img.shields.io/github/release/007revad/ContainerManager_for_all_armv8.svg"></a>
<a href="https://hits.seeyoufarm.com"><img src="https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2F007revad%2FContainerManager_for_all_armv8&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=views&edge_flat=false"/></a>
[![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/007revad)
[![committers.top badge](https://user-badge.committers.top/australia/007revad.svg)](https://user-badge.committers.top/australia/007revad)

### Description

Script to install Container Manager on a RS819, DS119j, DS418, DS418j, DS218, DS218play or DS118

There is no technical reason why these NAS models with a Realtek RTD1296, or Marvell A3720, CPU are excluded from installing Container Manager when they have the same CPU as the DS220j, or DS120j.

So I made a script to install the package from the DS424 on any model with a Realtek RTD1296 (or Marvell A3720?) CPU running DSM 7.2 or later.

### Confirmed working on

| Model      | CPU | DSM version              | Working | Notes |
| ---------- |-----|--------------------------|---------|-------|
| RS819      | Realtek RTD1296 |  | ? |  |
| DS119j     | Marvell A3720 |  | ? |  |
| DS418      | Realtek RTD1296 | DSM 7.2.1-69057 Update 3 | no | 1 person |
| DS418j     | Realtek RTD129**3**? |  | ? |  |
| DS218      | Realtek RTD1296 | DSM 7.2.1-69057 Update 3 | yes | 1 person |
| DS218play  | Realtek RTD1296 |  | ? |  |
| DS118      | Realtek RTD1296 |  | ? |  |

### Download the script

1. Download the latest version _Source code (zip)_ from https://github.com/007revad/ContainerManager_for_all_armv8/releases
2. Save the download zip file to a folder on the Synology.
    - Do ***NOT*** save the script to a M.2 volume.
3. Unzip the zip file.

## How to do a manual package install

1. Open Package Center.
2. Click on Manual Install.
3. Click Browse and browse to where you downloaded the spk to and select the spk file.
4. Click next and install the package.

<p align="center">Manual Package Install steps</p>
<p align="center"><img src="/images/package_manual_install.png"></p>
