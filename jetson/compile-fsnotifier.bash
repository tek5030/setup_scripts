#!/usr/bin/env bash
BASE_URL="https://raw.githubusercontent.com/JetBrains/intellij-community/master/native/fsNotifier/linux"

_files="fsnotifier.h inotify.c main.c make.sh util.c"

printf "$(tput setaf 4)%s$(tput sgr0)\n" "downloading ..."

for file in ${_files}
do
  wget -q --show-progress ${BASE_URL}/${file}
done

printf "$(tput setaf 4)%s$(tput sgr0)\n" "compiling ..."
sh make.sh
rm ${_files}
printf "$(tput setaf 4)%s$(tput sgr0)\n" "done."
# sudo cp fsnotifier /usr/local/bin/
# idea.filewatcher.executable.path = /usr/local/bin/fsnotifier
