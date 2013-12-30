advanced-dpkg-scanpackages
==========================

Simple bash script to help creating (ubuntu) local repository using dpkg-scanpackages.

### ABOUT
This script will run dpkg-scanpackages, make an index file (Packages.gz), then filter (delete or backup) old and unused pakcages which is ignored by dpkg-scanpackages.

### (Bahasa Indonesia) TENTANG
Script ini akan menjalankan dpkg-scanpackages, membuat file indeks berupa Packages.gz, setelah itu akan mencari dan menghapus/membackup paket-paket lama yang tidak digunakan dan tidak diindeks (di-ignore) oleh dpkg-scanpackages.
