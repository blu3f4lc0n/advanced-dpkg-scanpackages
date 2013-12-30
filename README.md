advanced-dpkg-scanpackages
==========================

Simple bash script to help creating (ubuntu) local repository using dpkg-scanpackages.

Requirements:
  1. **dpkg-dev** package, `$ sudo apt-get install dpkg-dev`.
  2. Edit some configuration in script to match your requirement (backup folder, delete or backup, etc.)
  3. Run this script as root (*for backup & delete old packages*).

There are 3 files in this repository:
  * **advanced-dpkg-scanpackages.sh**, standard, interactive and verbose mode.
  * **advanced-dpkg-scanpackages-langsung.sh**, quiet mode, suitable for using with cronjob.
  * **advanced-dpkg-scanpackages-changelog**, changelog file.

### ABOUT
This script will run dpkg-scanpackages, make an index file (Packages.gz), then filter (delete or backup) old and unused pakcages which is ignored by dpkg-scanpackages.

### (Bahasa Indonesia) TENTANG
Script ini akan menjalankan dpkg-scanpackages, membuat file indeks berupa Packages.gz, setelah itu akan mencari dan menghapus/membackup paket-paket lama yang tidak digunakan dan tidak diindeks (di-ignore) oleh dpkg-scanpackages.

### WARNING
**Script still EXPERIMENTAL**, I highly recommend to backup your data first.
