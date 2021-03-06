#!/usr/bin/env bash

current_path=${PATH}

PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin

lowercase(){
    echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}

OS=`lowercase \`uname\``
KERNEL=`uname -r`
MACH=`uname -m`

if [ "${OS}" = "windowsnt" ]; then
    OS=windows
elif [ "${OS}" = "darwin" ]; then
    DistroBasedOn="Darwin"
    DIST=$(sw_vers -productName)
    REV=$(sw_vers -productVersion)
    MAJOR_REV=$(echo ${REV} | cut -d. -f 1)
    readonly DistroBasedOn
    readonly DIST
    readonly OS
    readonly REV
    readonly KERNEL
    readonly MACH
else
    OS=`uname`
    if [ "${OS}" = "SunOS" ] ; then
        OS=Solaris
        ARCH=`uname -p`
        OSSTR="${OS} ${REV}(${ARCH} `uname -v`)"
    elif [ "${OS}" = "AIX" ] ; then
        OSSTR="${OS} `oslevel` (`oslevel -r`)"
    elif [ "${OS}" = "Linux" ] ; then
	if [ -f /etc/os-release ] ; then
	    DIST=`sed -n -r -e '/^NAME/s/"$//; /^NAME/s/.*="//p' /etc/os-release`
	    REV=`sed -n -r -e '/^VERSION_ID/s/"$//; /^VERSION_ID/s/.*="//p' /etc/os-release`
	    case $DIST in
		"Red Hat"* | "CentOS"*)
		    DistroBasedOn='RedHat'
		    PSEUDONAME=`sed -n -r -e '/^PRETTY_NAME/ { s/[)].*$//; s/.*[(]//p }' /etc/os-release`
		    ;;
		*[Ss][Uu][Ss][Ee]*)
		    DistroBasedOn='SuSe'
		    PSEUDONAME=`sed -n -r -e '/^NAME/s/"$//; /^NAME/s/.* //p' /etc/os-release`
		    ;;
	    esac
        elif [ -f /etc/redhat-release ] ; then
            DistroBasedOn='RedHat'
            DIST=`sed 's/ release.*//' /etc/redhat-release`
            PSUEDONAME=`sed 's/.*(//; s/).*//' /etc/redhat-release`
            REV=`sed 's/.*release //; s/ .*//' /etc/redhat-release`
        elif [ -f /etc/SuSE-release ] ; then
            DistroBasedOn='SuSe'
            PSUEDONAME=`cat /etc/SuSE-release | tr "\n" ' '| sed s/VERSION.*//`
            REV=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //`
        elif [ -f /etc/mandrake-release ] ; then
            DistroBasedOn='Mandrake'
            PSUEDONAME=`cat /etc/mandrake-release | sed s/.*\(// | sed s/\)//`
            REV=`cat /etc/mandrake-release | sed s/.*release\ // | sed s/\ .*//`
        elif [ -f /etc/debian_version ] ; then
            DistroBasedOn='Debian'
            DIST=`cat /etc/lsb-release | grep '^DISTRIB_ID' | awk -F=  '{ print $2 }'`
            PSUEDONAME=`cat /etc/lsb-release | grep '^DISTRIB_CODENAME' | awk -F=  '{ print $2 }'`
            REV=`cat /etc/lsb-release | grep '^DISTRIB_RELEASE' | awk -F=  '{ print $2 }'`
        fi
        if [ -f /etc/UnitedLinux-release ] ; then
            DIST="${DIST}[`cat /etc/UnitedLinux-release | tr "\n" ' ' | sed s/VERSION.*//`]"
        fi
        MAJOR_REV=$(echo ${REV} | cut -d. -f 1)
        OS=`lowercase $OS`
        DistroBasedOn=`lowercase $DistroBasedOn`
        readonly OS
        readonly DIST
        readonly DistroBasedOn
        readonly PSUEDONAME
        readonly REV
        readonly MAJOR_REV
        readonly KERNEL
        readonly MACH
    fi
fi

PATH=${current_path}
unset current_path
