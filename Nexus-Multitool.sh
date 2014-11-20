#!/bin/bash

#Version
nmtver="0.3"

f_setup(){
  clear
  maindir=~/Nexus-Multitool
  commondir=$maindir/all
  mkdir -p $commondir
  clear

  unamestr=`uname`
  cd $maindir
  case $unamestr in
  Darwin)
    if [ -d $commondir/adb-tools ]; then
      clear
    else
      echo "Downloading ADB and Fastboot (Developer Tools required)"
      echo ""
      mkdir -p $commondir/adb-tools
      cd $commondir
      git clone git://git.kali.org/packages/google-nexus-tools
      clear
      echo "Setting Up Tools"
      cd $commondir
      mkdir -p $commondir/adb-tools
      mv ./google-nexus-tools/bin/* ./adb-tools/
      rm -rf ./bin
      rm -rf ./debian
      rm -rf install.sh
      rm -rf license.txt
      rm -rf README.md
      rm -rf udev.txt
      rm -rf uninstall.sh
      cd ~/
    fi
    adb=$commondir/adb-tools/mac-adb
    fastboot=$commondir/adb-tools/mac-fastboot;;
  *)
    if [ -d $commondir/adb-tools ]; then
      clear
    else
      echo "Installing cURL (Password may be required)"
      echo ""
      sudo apt-get -qq update && sudo apt-get -qq -y install curl
      clear
      echo "Downloading ADB and Fastboot (Developer Tools required)"
      echo ""
      mkdir -p $commondir/adb-tools
      cd $commondir
      git clone git://git.kali.org/packages/google-nexus-tools
      clear
      echo "Setting Up Tools"
      cd $commondir
      mkdir -p $commondir/adb-tools
      mv ./google-nexus-tools/bin/* ./adb-tools/
      rm -rf ./bin
      rm -rf ./debian
      rm -rf install.sh
      rm -rf license.txt
      rm -rf README.md
      rm -rf udev.txt
      rm -rf uninstall.sh
      cd ~/
    fi
    adb=$commondir/adb-tools/linux-i386-adb
    fastboot=$commondir/adb-tools/linux-i386-fastboot;;
  esac

  rm -rf $commondir/google-nexus-tools
  chmod 755 $adb
  chmod 755 $fastboot
  clear
}

f_autodevice(){
  clear
  $adb start-server
  clear
  echo "Connect your device now."
  echo ""
  echo "Start up your device like normal and open the settings menu and scroll down to"
  echo "'About Device' Tap on 'Build Number' 7 times and return to the main settings"
  echo "menu. Open 'Developer Options' and enable the box that says 'USB debugging'. In"
  echo "the RSA Autorization box that pops up, check the box that says 'Always allow"
  echo "from this computer' and tap 'OK'."
  echo ""
  echo "Waiting for device... If you get stuck here, something went wrong."
  $adb wait-for-device
  clear

  echo "Connecting to device and reading device information."
  devicemake=`$adb shell getprop ro.product.manufacturer`
  devicemodel=`$adb shell getprop ro.product.model`
  currentdevice=`$adb shell getprop ro.product.name`
  androidver=`$adb shell getprop ro.build.version.release`
  androidbuild=`$adb shell getprop ro.build.id`
  androidver=$(echo $androidver|tr -d '\r\n')
  androidbuild=$(echo $androidbuild|tr -d '\r\n')
  devicemake=$(echo $devicemake|tr -d '\r\n')
  devicemodel=$(echo $devicemodel|tr -d '\r\n')
  currentdevice=$(echo $currentdevice|tr -d '\r\n')

  clear
  case $currentdevice in
    sojus|sojuk|sojua|soju|mysidspr|mysid|yakju|takju|occam|hammerhead|shamu|nakasi|nakasig|razor|razorg|mantaray|volantis|tungsten|fugu)
      clear;;
    *)
      echo "This is not a Nexus Device. This utility only supports Nexus Devices."
      echo ""
      read -p "Press [Enter] to exit the script."
      clear
      exit;;
  esac

  devicedir=$maindir/$currentdevice
  scriptdir=$maindir/scripts
  mkdir -p $devicedir
  mkdir -p $scriptdir

  f_menu
}

f_menu(){
  clear
  echo "Nexus Multitool - Version $nmtver"
  echo "Connected Device: $devicemake $devicemodel ($currentdevice)"
  echo "Android Version: $androidver ($androidbuild)"
  echo ""
  echo "[1] Unlock Bootloader"
  echo "[2] Lock Bootloader"
  echo "[3] Root (Requires Unlocked Bootloader)"
  echo "[4] Install TWRP Recovery (Requires Unlocked Bootloader)"
  echo "[5] Restore to Stock (Requires Unlocked Bootloader)"
  echo "[6] Tools"
  echo ""
  echo "[S] Settings and Options."
  echo "[D] Go back and select a different device."
  echo "[Q] Quit."
  echo ""
  read -p "Selection: " menuselection

  case $menuselection in
    1) f_unlock; f_menu;;
    2) f_lock; f_menu;;
    3) f_root; f_menu;;
    4) f_twrp; f_menu;;
    5) f_restore; f_menu;;
    6) f_tools; f_menu;;
    S|s) f_options;;
    D|d) f_autodevice;;
    Q|q) clear; exit;;
    *) f_menu;;
  esac
}

f_unlock(){
  clear
  case $currentdevice in
    volantis|shamu)
      $adb start-server
      clear
      echo "Start up your device like normal and open the settings menu and scroll down to 'Developer Options'"
      echo "and enable 'OEM unlock'."
      echo ""
      read -p "Press [Enter] to continue." null
      clear
      echo "Waiting for device..."
      $adb wait-for-device
      clear;;
    *)
      clear;;
  esac
  echo "THIS NEXT STEP WILL ERASE YOUR DEVICE'S DATA."
  echo "Make sure taht anything you wish to keep is backed"
  echo "up and taken off of the device!"
  echo ""
  read -p "Press [Enter] to continue." null
  clear
  $adb reboot bootloader
  sleep 20
  $fastboot oem unlock
  clear
  echo "On your device, select the option to accept, unlock your device's bootloader, and erase all data."
  echo ""
  read -p "Press [Enter] to continue." null
  clear
  echo "Bootloader Unlocked"
  echo ""
  read -p "Press [Enter] to return to the menu" null
}

f_lock(){
  clear
  echo "Start up your device in the bootloader OR start the device normally and make sure ADB is enabled."
  echo ""
  read -p "Press [Enter] to continue."
  $adb reboot bootloader
  clear
  $adb oem lock
}

f_root(){
  clear
  case $currentdevice in
    mysidspr|mysid|yakju|takju|occam|shamu|hammerhead|nakasi|nakasig|razor|razorg|mantaray|volantis)
      echo "Boot into your device's OS like normal"
      $adb wait-for-device
      $adb reboot bootloader
      sleep 15
      clear
      echo "Downloading files to root device..."
      cd $devicedir
      export currentdevice
      curl -o $scriptdir/autoroot-download.py 'https://raw.githubusercontent.com/photonicgeek/Nexus-Multitool/master/autoroot-download.py' --progress-bar
      python $scriptdir/autoroot-download.py
      clear
      echo "Download Complete."
      sleep 1
      mkdir -p $devicedir/root
      cd $devicedir/root
      unzip $devicedir/root.zip
      clear
      echo "Rooting your device. This may take a minute..."
      case $currentdevice in
        mysidspr) $fastboot boot $devicedir/root/image/CF-Auto-Root-toroplus-mysidspr-nexus7.img;;
        mysid) $fastboot boot $devicedir/root/image/CF-Auto-Root-toro-mysid-nexus7.img;;
        yakju) $fastboot boot $devicedir/root/image/CF-Auto-Root-maguro-yakju-nexus7.img;;
        takju) $fastboot boot $devicedir/root/image/CF-Auto-Root-maguro-takju-nexus7.img;;
        occam) $fastboot boot $devicedir/root/image/CF-Auto-Root-mako-occam-nexus7.img;;
        shamu) $fastboot boot $devicedir/root/image/CF-Auto-Root-shamu-shamu-nexus7.img;;
        hammerhead) $fastboot boot $devicedir/root/image/CF-Auto-Root-hammerhead-hammerhead-nexus7.img;;
        nakasi) $fastboot boot $devicedir/root/image/CF-Auto-Root-grouper-nakasi-nexus7.img;;
        nakasig) $fastboot boot $devicedir/root/image/CF-Auto-Root-tilapia-nakasig-nexus7.img;;
        razor) $fastboot boot $devicedir/root/image/CF-Auto-Root-flo-razor-nexus7.img;;
        razorg) $fastboot boot $devicedir/root/image/CF-Auto-Root-deb-razorg-nexus7.img;;
        mantaray) $fastboot boot $devicedir/root/image/CF-Auto-Root-manta-mantaray-nexus7.img;;
        volantis) $fastboot boot $devicedir/root/image/CF-Auto-Root-flounder-volantis-nexus7.img;;
      esac
      echo ""
      read -p "Press [Enter] to return to the menu." null
      rm -rf $devicedir/root;;
    *)
      echo "The root method for this device is still undergoing development."
      echo ""
      read -p "Press [Enter] to return to the menu." null;;
  esac
}

f_twrp(){
  clear
  case $currentdevice in
    mysidspr) url="http://techerrata.com/get/twrp2/toroplus/openrecovery-twrp-2.8.1.0-toroplus.img";;
    mysid) url="http://techerrata.com/get/twrp2/toro/openrecovery-twrp-2.8.1.0-toro.img";;
    yakju) url="http://techerrata.com/get/twrp2/maguro/openrecovery-twrp-2.8.1.0-maguro.img";;
    takju) url="http://techerrata.com/get/twrp2/maguro/openrecovery-twrp-2.8.1.0-maguro.img";;
    occam) url="http://techerrata.com/get/twrp2/mako/openrecovery-twrp-2.8.1.0-mako.img";;
    shamu) url="http://techerrata.com/get/twrp2/shamu/openrecovery-twrp-2.8.2.0-shamu.img";;
    hammerhead) url="http://techerrata.com/get/twrp2/hammerhead/openrecovery-twrp-2.8.1.0-hammerhead.img";;
    nakasi) url="http://techerrata.com/get/twrp2/grouper/openrecovery-twrp-2.8.1.0-grouper.img";;
    nakasig) url="http://techerrata.com/get/twrp2/tilapia/openrecovery-twrp-2.8.1.0-tilapia.img";;
    razor) url="http://techerrata.com/get/twrp2/flo/openrecovery-twrp-2.8.1.0-flo.img";;
    razorg) url="http://techerrata.com/get/twrp2/deb/openrecovery-twrp-2.8.1.0-deb.img";;
    mantaray) url="http://techerrata.com/get/twrp2/manta/openrecovery-twrp-2.8.1.0-manta.img";;
    volantis) url="http://techerrata.com/get/twrp2/volantis/openrecovery-twrp-2.8.2.1-volantis.img";;
    *)
      echo "The recovery install method for this device is still undergoing development."
      echo ""
      read -p "Press [Enter] to return to the menu." null
      f_menu;;
  esac
  echo "Downloading TWRP"
  curl -L -o $devicedir/$currentdevice-twrp.img $url --progress-bar
  $adb wait-for-device
  clear
  echo "Rebooting into the bootloader"
  $adb reboot bootloader
  $fastboot flash recovery $devicedir/$currentdevice-twrp.img
  $fastboot reboot
  clear
  echo "TWRP install complete. Your device is now rebooting."
  echo ""
  read -p "Press [Enter] to return to the menu." null
  f_menu
}

f_restore(){
  clear
  echo "Are you sure you want to restore your device? This will erase ALL data!"
  echo ""
  echo "[Y]es, erase everything and restore to stock."
  echo "[N]o! I want to keep everything and return to the menu!"
  echo ""
  read -p "Selection: " selection

  case $selection in
    Y|y) clear; echo "Continuing with erase and restore.";;
    N|n) f_menu;;
  esac

  case $currentdevice in
    sojus)
      restoredir="sojus-jro03r"
      url="https://dl.google.com/dl/android/aosp/sojus-jro03r-factory-59a247f5.tgz";;
    sojuk)
      restoredir="sojuk-jro03e"
      url="https://dl.google.com/dl/android/aosp/sojuk-jro03e-factory-93a21b70.tgz";;
    sojua)
      restoredir="sojua-jzo54k"
      url="https://dl.google.com/dl/android/aosp/sojua-jzo54k-factory-1121b619.tgz";;
    soju)
      restoredir="soju-jzo54k"
      url="https://dl.google.com/dl/android/aosp/soju-jzo54k-factory-36602333.tgz";;
    mysidspr)
      restoredir="mysidspr-ga02"
      url="https://dl.google.com/dl/android/aosp/mysidspr-ga02-factory.tgz";;
    mysid)
      restoredir="mysid-jdq39"
      url="https://dl.google.com/dl/android/aosp/mysid-jdq39-factory-e365033f.tgz";;
    yakju)
      restoredir="yakju-jwr66y"
      url="https://dl.google.com/dl/android/aosp/yakju-jwr66y-factory-09207065.tgz";;
    takju)
      restoredir="takju-jwr66y"
      url="https://dl.google.com/dl/android/aosp/takju-jwr66y-factory-5104ab1d.tgz";;
    occam)
      restoredir="occam-lrx21t"
      url="https://dl.google.com/dl/android/aosp/occam-lrx21t-factory-51cee750.tgz";;
    hammerhead)
      restoredir="hammerhead-lrx21o"
      url="https://dl.google.com/dl/android/aosp/hammerhead-lrx21o-factory-01315e08.tgz";;
    shamu)
      restoredir="shamu-lrx21o"
      url="https://dl.google.com/dl/android/aosp/shamu-lrx21o-factory-e028f5ea.tgz";;
    nakasi)
      restoredir="nakasi-lrx21p"
      url="https://dl.google.com/dl/android/aosp/nakasi-lrx21p-factory-93daa4d3.tgz";;
    nakasig)
      restoredir="nakasig-ktu84p"
      url="https://dl.google.com/dl/android/aosp/nakasig-ktu84p-factory-0cc2750b.tgz";;
    razor)
      restoredir="razor-lrx21p"
      url="https://dl.google.com/dl/android/aosp/razor-lrx21p-factory-ba55c6ab.tgz";;
    razorg)
      restoredir="razorg-ktu84p"
      url="https://dl.google.com/dl/android/aosp/razorg-ktu84p-factory-f21762aa.tgz";;
    mantaray)
      restoredir="mantaray-lrx21p"
      url="https://dl.google.com/dl/android/aosp/mantaray-lrx21p-factory-ad2499ea.tgz";;
    volantis)
      restoredir="volantis-lrx21r"
      url="https://dl.google.com/dl/android/aosp/volantis-lrx21r-factory-ac87eba2.tgz";;
    tungsten)
      restoredir="tungsten-ian67k"
      url="https://dl.google.com/dl/android/aosp/tungsten-ian67k-factory-468d9865.tgz";;
    fugu)
      restoredir="fugu-lrx21v"
      url="https://dl.google.com/dl/android/aosp/fugu-lrx21v-factory-64050f47.tgz";;
    *)
      echo "The recovery install method for this device is still undergoing development."
      echo ""
      read -p "Press [Enter] to return to the menu." null
      f_menu;;
  esac

  echo "Downloading restore image."
  curl -o $devicedir/restore.tgz $url --progress-bar
  clear
  cd $devicedir
  echo "Unpacking restore image."
  gunzip -c restore.tgz | tar xopf -
  cd $devicedir/$restoredir
  clear
  echo "Rebooting into the bootloader."
  $adb reboot bootloader
  clear
  echo "Flashing restore image."
  sed 's/fastboot/$fastboot/g' ./flash-all.sh
  clear
  sh ./flash-all.sh
  clear

  echo "Did the flashing complete successfully? (The tablet should be rebooting.)"
  echo ""
  echo "[Y]es, the restore was successful."
  echo "[N]o, the flash was unsuccessful. (This has been an issue lately.)"
  echo ""
  read -p "Selection: " selection

  case $selection in
    Y|y) clear;;
    N|n)
      unzip image-$restoredir.zip
      $fastboot format userdata
      clear
      $fastboot format cache
      clear
      if [ -e ./boot.img ]; then
        $fastboot flash boot boot.img
      else
        echo "boot.img not found. Skipping."
      fi
      clear
      if [ -e ./recovery.img ]; then
        $fastboot flash recovery recovery.img
      else
        echo "recovery.img not found. Skipping."
      fi
      clear
      if [ -e ./system.img ]; then
        $fastboot flash system system.img
      else
        echo "system.img not found. Skipping."
      fi
      clear
      if [ -e ./userdata.img ]; then
        $fastboot flash userdata userdata.img
      else
        echo "userdata.img not found. Skipping."
      fi
      clear
      if [ -e ./cache.img ]; then
        $fastboot flash cache cache.img
      else
        echo "cache.img not found. Skipping."
      fi
      clear
      if [ -e ./vendor.img ]; then
        $fastboot flash vendor vendor.img
      else
        echo "vendor.img not found. Skipping."
      fi
      $fastboot reboot;;
  esac

  rm -rf $restoredir
  cd ~/
  clear
  f_autodevice
}

f_tools(){
  clear
  echo "Nexus Multitool - Version $nmtver"
  echo "Device Selected: $devicemake $devicemodel ($currentdevice)"
  echo "Android Version: "
  echo ""
  echo "[1] Pull File from Device"
  echo "[2] Push File to Device"
  echo "[3] Install APK"
  echo "[4] Start ADB Shell"
  echo ""
  echo "[R] Return to Previous Menu"
  echo "[Q] Quit"
  echo ""
  read -p "Selection: " selection

  case $selection in
    1)
      clear
      echo "What file do you want to pull?"
      read -p "" sourcedir
      clear
      echo "Where would you like the file to be put?"
      read -p "" destdir
      clear
      echo "Pulling File"
      $adb pull $sourcedir $destdir
      echo ""
      echo "Pull Complete."
      read -p "Press [Enter] to return to the menu" null
      f_tools;;
    2)
      clear
      echo "What file do you want to transfer?"
      read -p "" sourcedir
      clear
      echo "Where would you like the file to be put?"
      read -p "" destdir
      clear
      echo "Pushing File."
      $adb pull $sourcedir $destdir
      echo ""
      echo "Push Complete."
      read -p "Press [Enter] to return to the menu" null
      f_tools;;
    3)
      clear
      echo "What APK do you want to install? (Input directory or drag-and drop)"
      read -p "" apkdir
      clear
      echo "Installing APK"
      $adb install $apkdir
      echo ""
      echo "Install complete"
      read -p "Press [Enter] to return to the menu."
      f_tools;;
    4)
      clear
      echo "Starting ADB Shell. Type 'exit' to return to the menu."
      $adb shell
      f_tools;;
    R|r) f_menu;;
    Q|q) clear; exit;;
  esac
}

f_options(){
  clear
  echo "Nexus Multitool - Version $nmtver"
  echo ""
  echo "[1] Update Nexus Multitool"
  echo ""
  echo "[R] Return to previous menu"
  echo "[Q] Quit"
  echo ""
  read -p "Selection: " selection

  case $selection in
    1) f_update; f_options;;
    R|r) f_menu;;
    Q|q) clear ; exit;;
    *) f_options;;
  esac
}

f_update(){
  unamestr=`uname`
  case $unamestr in
  Darwin)
    self=$BASH_SOURCE
    curl -o /tmp/NetHunter-Installer.sh 'https://raw.githubusercontent.com/photonicgeek/Nexus-Multitool/master/Nexus-Multitool.sh'  --progress-bar
    clear
    rm -rf $self
    mv /tmp/kfu.sh $self
    rm -rf /tmp/kfu.sh
    chmod 755 $self
    exec $self;;
  *)
    self=$(readlink -f $0)
    curl -L -o $self 'https://raw.githubusercontent.com/photonicgeek/Nexus-Multitool/master/Nexus-Multitool.sh' --progress-bar
    clear
    exec $self;;
  esac
}

f_setup
f_autodevice
