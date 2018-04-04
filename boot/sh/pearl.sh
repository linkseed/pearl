# Usage: source pearl OR in Bash: bash --rcfile pearl
# vim: set ft=sh ts=4 sw=4 noet:

####################### VARIABLES & IMPORTS ############################
[[ -z "${PEARL_ROOT}" ]] && { echo "Error: PEARL_ROOT environment variable does not exist." 1>&2; return 1; }
[[ ! -d "${PEARL_ROOT}" ]] && { echo "Error: PEARL_ROOT directory '${PEARL_ROOT}' does not exist." 1>&2; return 2; }

export PEARL_ROOT
export PEARL_HOME=${HOME}/.config/pearl
# Fallback to a default temp directory if tty does not work
if tty -s
then
    export PEARL_TEMPORARY=${PEARL_HOME}/tmp/$(tty)
else
    export PEARL_TEMPORARY=${PEARL_HOME}/tmp/default-tty
fi
mkdir -p ${PEARL_TEMPORARY}

if [[ $PATH != *"${PEARL_HOME}/bin"* ]]
then
    PATH=$PATH:${PEARL_HOME}/bin
fi
if [[ $MANPATH != *"${PEARL_ROOT}/man"* ]]
then
    MANPATH=$MANPATH:${PEARL_ROOT}/man
fi

################################# MAIN ##############################
for reponame in $(ls ${PEARL_HOME}/packages/)
do
    for pkgname in $(ls ${PEARL_HOME}/packages/${reponame}/)
    do
        PEARL_PKGDIR=${PEARL_HOME}/packages/${reponame}/${pkgname}
        PEARL_PKGVARDIR=${PEARL_HOME}/var/${reponame}/${pkgname}
        PEARL_PKGNAME=${pkgname}
        PEARL_PKGREPONAME=${reponame}

        # TODO pearl-metadata directory is meant to be deprecated in the future versions
        if [ -e ${PEARL_PKGDIR}/pearl-metadata/config.sh ]; then
            source ${PEARL_PKGDIR}/pearl-metadata/config.sh
        fi
        if [ -n "$BASH" ] && [ -e ${PEARL_PKGDIR}/pearl-metadata/config.bash ]; then
            source ${PEARL_PKGDIR}/pearl-metadata/config.bash
        fi
        if [ -n "$ZSH_NAME" ] && [ -e ${PEARL_PKGDIR}/pearl-metadata/config.zsh ]; then
            source ${PEARL_PKGDIR}/pearl-metadata/config.zsh
        fi

        if [ -e ${PEARL_PKGDIR}/pearl-config/config.sh ]; then
            source ${PEARL_PKGDIR}/pearl-config/config.sh
        fi
        if [ -n "$BASH" ] && [ -e ${PEARL_PKGDIR}/pearl-config/config.bash ]; then
            source ${PEARL_PKGDIR}/pearl-config/config.bash
        fi
        if [ -n "$ZSH_NAME" ] && [ -e ${PEARL_PKGDIR}/pearl-config/config.zsh ]; then
            source ${PEARL_PKGDIR}/pearl-config/config.zsh
        fi
        unset PEARL_PKGDIR PEARL_PKGVARDIR PEARL_PKGNAME PEARL_PKGREPONAME
    done
done

trap "source ${PEARL_ROOT}/boot/sh/pearl.sh" USR1
