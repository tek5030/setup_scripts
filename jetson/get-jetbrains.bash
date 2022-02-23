#!/usr/bin/env bash

complete -W "clion pycharm" get_jetbrains

get_jetbrains() (

  _func=${FUNCNAME[0]}
  usage() {
    printf "$(tput dim)Usage:$(tput sgr0)\n"
    printf "  $(tput dim)$(tput bold)${_func}$(tput sgr0) $(tput dim)clion <version>$(tput sgr0)\n"
    printf "  $(tput dim)$(tput bold)${_func}$(tput sgr0) $(tput dim)pycharm <version>$(tput sgr0)\n"
  }

  if [[ "$#" -ne 2 ]] || [[ "${1}" != "clion" && "${1}" != "pycharm" ]] ; then
    usage
    return
  fi

  set -ux

  APP=${1}
  VERSION=${2}

  [[ "${APP}" == "clion" ]]   && URL=https://download.jetbrains.com/cpp/CLion-${VERSION}.tar.gz
  [[ "${APP}" == "pycharm" ]] && https://download.jetbrains.com/python/${APP}-professional-${VERSION}.tar.gz

  sudo -n true 2>/dev/null || \
    printf "$(tput dim)%s $(tput smul)%s$(tput sgr0)\n" "Type your password to install ${APP} into" "/opt/"

  #sudo apt install default-jre pv

  curl -sL \
    ${URL} | \
    pv | \
    sudo tar xz -C /opt/ && \
  printf "$(tput setaf 2)%s$(tput sgr0)\n" "Installation complete" && \
  sudo ln -s /opt/${APP}-${VERSION}/bin/${APP}.sh /usr/local/bin/${APP} && \
  printf "$(tput setaf 2)%s $(tput smul)%s$(tput sgr0)\n" "Created symlink" "/usr/local/bin/${APP}"

)

#get_jetbrains clion   2021.3.3
#get_jetbrains pycharm 2021.3.2

