![neutron](https://github.com/valorisa/Script_Update_VirtualBox_for_macOS/assets/13067566/b540c778-e9f6-487e-b53c-773f09675fb8)

# Script to update VirtualBox version for macOS from terminal (CLI)

#!/bin/bash

open -a virtualbox ; sleep 10 && sudo kill `ps -ef | grep VirtualBox | awk '{print $2}'`

echo " What recent version of VirtualBox do you want to install as an update ? "; read nv ; v="$nv"

echo " What is the recent VirtualBox build number you want to install as an update ? "; read nb ; b="$nb"

cd /Users/$(logname)/Downloads
sudo rm -iRv ./VirtualBox\ 6.* #Optional line, only if you have already a 'VirtualBox' directory in 'Downloads'
mkdir VirtualBox\ "$nv"\ Build\ "$nb"
cd ./VirtualBox\ "$nv"\ Build\ "$nb"/

wget https://download.virtualbox.org/virtualbox/"$v"/VirtualBox-"$v"-"$b"-OSX.dmg https://download.virtualbox.org/virtualbox/"$v"/VBoxGuestAdditions_"$v".iso https://download.virtualbox.org/virtualbox/"$v"/Oracle_VM_VirtualBox_Extension_Pack-"$v"-"$b".vbox-extpack

MOUNTDIR=$(echo `hdiutil mount /Users/$(logname)/Downloads/VirtualBox\ "$v"\ Build\ "$b"/VirtualBox-"$v"-"$b"-OSX.dmg | tail -1 | awk '{$1=$2=""; print $0}'` | xargs -0 echo)

sudo installer -pkg "${MOUNTDIR}"/*.pkg -target /

diskutil unmount "${MOUNTDIR}"

cd

open -a virtualbox ; vboxmanage --version
sudo vboxmanage extpack install /Users/$(logname)/Downloads/VirtualBox\ "$v"\ Build\ "$b"/Oracle_VM_VirtualBox_Extension_Pack-"$v"-"$b".vbox-extpack --replace
