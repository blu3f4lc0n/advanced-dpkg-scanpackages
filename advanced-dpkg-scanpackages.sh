#!/bin/bash
# ----------------------------------------------------------------------------------
# @name    : advanced dpkg-scanpackages   
# @version : 1.1.3
# @date    : 03/04/2013 08:21:11
# 
# TENTANG
# ----------------------------------------------------------------------------------
# Script ini akan menjalankan dpkg-scanpackages, membuat file indeks berupa
# Packages.gz, setelah itu akan mencari dan menghapus/membackup paket-paket lama 
# yang tidak digunakan dan tidak diindeks (di-ignore) oleh dpkg-scanpackages.
#
# PERINGATAN..!
# ----------------------------------------------------------------------------------
# Masih experimental, use this script at your own risk.
# Saya rekomendasikan untuk membackup data terlebih dahulu.
#
# KONTAK
# ----------------------------------------------------------------------------------
# Ada bug? saran? sampaikan ke saya.
# Ghozy Arif Fajri / gojigeje
# email    : gojigeje@gmail.com
# web      : goji.web.id
# facebook : facebook.com/gojigeje
# twitter  : @gojigeje
# g+       : gplus.to/gojigeje
#
# LISENSI
# ----------------------------------------------------------------------------------
# Open Source tentunya :)
#  The MIT License (MIT)
#  Copyright (c) 2013 Ghozy Arif Fajri <gojigeje@gmail.com>

# Set dulu lokasi & nama folder tempat mengumpulkan paket-paket .deb
# misal:  File-file .deb tersebut disimpan di  /media/repo/oneiric
# maka:   lokasi="/media/repo" (TANPA SLASH '/' DI AKHIR)
#         namafolder="oneiric" (TANPA SLASH '/' DI AKHIR)
# ----------------------------------------------------------------------------------
# DEFAULT: lokasi="/home/goji/Desktop"
#          namafolder="oneiric"
# silahkan diubah sesuai dengan kebutuhan
lokasi="/media/BACKUP/BACKUP/REPO" 
namafolder="reponya.goji.precise"

# escfolder adalah path folder yang sudah ditambahkan escape character,
# yaitu karakter '/' (slash) harus ditambahkan dengan escape character 
# '\'(backslash) sebelumnya, biar ndak eror :D
# contoh:
#   /media/repo/oneiric  --> \/media\/repo\/oneiric (TANPA SLASH '/' DI AKHIR)
#
# Cara mudahnnya, di Ubuntu (menggunakan Nautilus), masuk ke folder di mana
# file .deb tersebut berada, lalu tampilkan path folder dengan cara CTRL+L
# (menu Go - Location), copy-paste ke sini dan tinggal menambahkan tanda
# backslash sebelum tanda slash di hasil paste-an.
# ----------------------------------------------------------------------------------
# DEFAULT: escfolder="\/home\/goji\/Desktop\/oneiric"
# silahkan diubah sesuai dengan kebutuhan
escfolder="\/media\/BACKUP\/BACKUP\/REPO\/reponya.goji.precise"

# Mode, untuk menentukan tindakan yang akan dilakukann script terhadap paket-
# paket yang outdated, akan dihapus atau dibackup?
# Bila mode backup, maka paket-paket outdated akan dibackup ke dalam folder
# dengan nama 'outdated' di direktori yang sama folder repo.
# ----------------------------------------------------------------------------------
# Nilai yang bisa diisikan: "hapus" / "backup" <-- jangan lupa tanda petiknya
# DEFAULT: mode="backup"
mode="hapus"

# ----------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------
#  STOP !! JANGAN UBAH APAPUN SETELAH TULISAN INI..!
#          Silahkan diubah apabila benar-benar mengetahui maksud dari
#          script tersebut, dan mungkin hendak menyesuaikan dengan kebutuhan.
#          Buat backup dulu sebelum mengubah.
# ----------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------
# versi, tidak perlu diubah
versi="1.1.3"

mulai() {
   echo "# -------------------------------------------------------------"
   echo "# Advanced ScanPackages $versi by Ghozy Arif Fajri / gojigeje"
   echo "# -------------------------------------------------------------"
   if [[ $EUID -ne 0 ]]; then
      echo "# Script ini harus di-run dengan akses root!" 
      echo "# gunakan sudo"
      echo "#"
      exit 1
   fi
   if [ "$mode" = "backup" -o "$mode" = "hapus" ]; then
      tgl=$(date +%Y%m%d-%H%M)
      logfile="di$mode-$tgl.txt"
      mkdir -p $HOME/gojigeje
      mkdir -p $lokasi/$namafolder
      logfolder="$HOME/gojigeje"
      backupfolder=$escfolder"-outdated"
      escfolder=$escfolder"\/"
      jumdeb=$(ls $lokasi/$namafolder/*.deb | wc -l) > /dev/null 2>&1
      cd $lokasi/$namafolder
      totalbefore=$(du -sh | awk '{print $1}')
      separator=":"
   else
      echo "# Nilai variabel 'mode' salah. Isi dengan 'hapus'/'backup'"
      echo "# Program akan keluar..."
      echo "#"
      exit 1
   fi
   if [ "$mode" = "backup" ]; then
      separator=" :"
   fi
   upmode=$(echo "${mode^^}")
   echo "# Lokasi repo : $lokasi"
   echo "# Folder repo : $namafolder"
   echo "# Informasi   : paket-paket lama akan DI$upmode"
   echo "# -------------------------------------------------------------"
   cekdpkgdev
   echo "# Paket-paket lama akan DI$upmode,"
   confirm
}

cekdpkgdev() {
   echo "# Menyiapkan.."
   sleep 1
   echo -n "# Memeriksa dpkg-dev."
   dpkg-query -W -f='${Status}\n' dpkg-dev > $HOME/.gojigeje-dpkgdevstat 2>&1
   echo -n "."
   dpkgdevstat=$(cat $HOME/.gojigeje-dpkgdevstat)
   echo -n "."
   if echo "$dpkgdevstat" | grep installed > /dev/null 2>&1
      then 
         echo " [OK]"   
         echo "#"
      else
         echo "#"
         echo "# -------------------------------------------------------------"
         echo "# ERROR..!! #"
         echo "# Paket 'dpkg-dev' belum terpasang di sistem. Paket tersebut"
         echo "# diperlukan untuk menjalankan script ini."
         echo "# -------------------------------------------------------------"
         echo "# Pasang dengan 'apt-get install dpkg-dev' (di ubuntu), atau"
         echo "# masukkan huruf 'Y' pada inputan di bawah untuk memasangnya "
         echo "# secara otomatis (butuh koneksi internet). Masukkan huruf 'N'"
         echo "# untuk memasangnya di lain waktu (script akan keluar)."
         echo "# -------------------------------------------------------------"
         echo "#"
         while true; do
             read -p "# Pasang 'dpkg-dev' sekarang? : " yn
             case $yn in
                 [Yy]* )
                     echo "# Memasang 'dpkg-dev' (apt-get install dpkg-dev).."
                     sudo apt-get install dpkg-dev -y -qq
                     echo "# Paket telah terpasang.."
                     echo "#"
                     echo "# Memulai kembali script.."
                     sleep 1
                     echo "#"
                     break
                 ;;
                 [Nn]* )
                     echo "#"
                     echo "# Pasang 'dpkg-dev' terlebih dahulu."
                     echo "# Script akan keluar.."
                     echo "#"
                     exit 1
                 ;;
                 * ) 
                     echo "# Input salah. Masukkan y atau n";;
             esac
         done
   fi
   rm $HOME/.gojigeje-dpkgdevstat
}

confirm() {
   while true; do
       read -p "# Lanjutkan? (y/n) : " yn
       case $yn in
           [Yy]* )
               do_lanjut
               break
           ;;
           [Nn]* )
               echo "# (Keluar..)"
               exit 1 
           ;;
           * )
               echo "# Input salah. Masukkan y atau n"
           ;;
       esac
   done
}

do_lanjut() {
   echo "#"
   sleep 1
   echo "# Memeriksa cache.."
   sleep 1
   do_cekcache
   sleep 2
   echo "#"
   echo "# dpkg-scanpackages..."
   echo "# Membuat file indeks :"
   echo "#  -> $lokasi/$namafolder/Packages.gz"
   echo "# Biasanya agak lama, sabar ya :D"
   cd $lokasi
   sudo dpkg-scanpackages "$namafolder/" /dev/null 2> "$logfolder/scanpackages-warning" | gzip -9c > "$namafolder/Packages.gz"
   echo "# File indeks berhasil dibuat..."
   echo "#"
   echo "# Mencari paket lama yang outdated.."
   sleep 1
   cat "$logfolder/scanpackages-warning" | grep "ignored data from" > "$logfolder/.list1"
   cat "$logfolder/scanpackages-warning" | grep "is repeat;" > "$logfolder/.list2"
   sed 's/^[^$]*\/\/\(.*\)\!.*/\1/' "$logfolder/.list1" > "$logfolder/.list3"
   sed 's/^[^$]*\/\/\(.*\)\ is.*/\1/' "$logfolder/.list2" | tr -d '()' >> "$logfolder/.list3"
   case "$mode" in
      "hapus")
         do_hapus
      ;;
      "backup")
         do_backup
      ;;
   esac
   do_periksa
}

do_cekcache() {
   cd /var/cache/apt/archives
   cekjumlah=$(ls | wc -l)
   if [ "$cekjumlah" = "2" ]; then
      echo "# Tidak ada paket *.deb baru di cache.."
   else
      cekjumdeb=$(( cekjumlah - 2 ))
      cektotal=$(du -sh | awk '{print $1}')
      echo "# Membackup $cekjumdeb file *.deb dari cache, total $cektotal"
      sudo mv *.deb $lokasi/$namafolder/
   fi
}

do_hapus() {
      sed "s/^/rm -rf $escfolder/g" "$logfolder/.list3" > "$logfolder/.list4"
      echo "#!/bin/bash" > "$logfolder/delete"
      cat "$logfolder/.list4" >> "$logfolder/delete"
      chmod +x "$logfolder/delete"
      numfile=$(cat "$logfolder/.list3" | wc -l)
      echo "# Ada $numfile paket outdated di folder repo, akan DIHAPUS.."
      echo "#"
      sleep 1
      echo "# Menghapus file.."
      $logfolder/delete
      sleep 2
      echo "# File-file berhasil dihapus.."
      echo "---------------------------------------------------------------------------------" > $HOME/Desktop/$logfile
      echo "Advanced ScanPackages $versi by Ghozy Arif Fajri / gojigeje" >> $HOME/Desktop/$logfile
      echo "---------------------------------------------------------------------------------" >> $HOME/Desktop/$logfile
      echo "Daftar paket yang dihapus dari folder repo" >> $HOME/Desktop/$logfile
      echo "Path folder repo: $lokasi/$namafolder" >> $HOME/Desktop/$logfile
      echo "Dihapus pada tanggal: $tgl (YYmmdd-HHMM)" >> $HOME/Desktop/$logfile
      echo "" >> $HOME/Desktop/$logfile
      echo "---------------------------------------------------------------------------------" >> $HOME/Desktop/$logfile
      cat "$logfolder/.list3" >> $HOME/Desktop/$logfile
}

do_backup() {
      mkdir -p $lokasi/$namafolder-outdated-$tgl
      sed "s/^/mv -f $escfolder/g" "$logfolder/.list3" > "$logfolder/.list4"
      sed -e "s/$/ $backupfolder-$tgl\//" "$logfolder/.list4" > "$logfolder/.list5"
      echo "#!/bin/bash" > "$logfolder/backup"
      cat "$logfolder/.list5" >> "$logfolder/backup"
      chmod +x "$logfolder/backup"
      numfile=$(cat "$logfolder/.list3" | wc -l)
      echo "# Ada $numfile paket outdated di folder repo, akan DIBACKUP..."
      echo "#"
      sleep 1
      echo "# Membackup file.."
      $logfolder/backup
      sleep 2
      echo "# File-file berhasil dibackup.."
      echo "---------------------------------------------------------------------------------" > $HOME/Desktop/$logfile
      echo "Advanced ScanPackages $versi by Ghozy Arif Fajri / gojigeje" >> $HOME/Desktop/$logfile
      echo "---------------------------------------------------------------------------------" >> $HOME/Desktop/$logfile
      echo "Daftar paket yang dibackup dari folder repo" >> $HOME/Desktop/$logfile
      echo "Path folder repo: $lokasi/$namafolder" >> $HOME/Desktop/$logfile
      echo "Dibackup pada: $tgl (YYmmdd-HHMM)" >> $HOME/Desktop/$logfile
      echo "" >> $HOME/Desktop/$logfile
      echo "File-file berikut ini bisa temukan di backup folder:" >> $HOME/Desktop/$logfile
      echo "$lokasi/$namafolder-outdated-$tgl/" >> $HOME/Desktop/$logfile
      echo "---------------------------------------------------------------------------------" >> $HOME/Desktop/$logfile
      cat "$logfolder/.list3" >> $HOME/Desktop/$logfile
}

do_periksa() {
   jumdebnow=$(ls $lokasi/$namafolder/*.deb | wc -l)
   cd $lokasi/$namafolder
   totaldeb=$(du -sh | awk '{print $1}')
   chmod 777 $HOME/Desktop/$logfile
   echo "# -------------------------------------------------------------"
   echo "# Jumlah paket sebelum scanpackages      $separator $jumdeb"
   echo "# Jumlah paket yang outdated dan di$mode : $numfile"
   echo "# Jumlah paket di folder repo sekarang   $separator $jumdebnow"
   echo "# Ukuran repo sebelum scanpackages       $separator $totalbefore"
   echo "# Total ukuran repo sekarang             $separator $totaldeb"
   if [ "$mode" = "backup" ]; then
      cd $lokasi/$namafolder-outdated-$tgl/
      total=$(du -sh | awk '{print $1}')
      echo "# Berhasil mem-backup paket sebesar       : $total"
      echo "# Backup ini bisa dihapus untuk menghemat disk space.."
      echo "# Lokasi backup folder:"
      echo "# $lokasi/$namafolder-outdated-$tgl/"
      chmod 777 $lokasi/$namafolder-outdated-$tgl -R
   fi
   echo "# -------------------------------------------------------------"
   echo "# Daftar file yang di$mode bisa dilihat di desktop."
   echo "# Selesai.."
   echo "#"
}

mulai

# That's it :D