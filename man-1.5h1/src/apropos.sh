#!/bin/sh
#
# apropos -- search the whatis database for keywords.
# whatis  -- idem, but match only commands (as whole words).
#
# Copyright (c) 1990, 1991, John W. Eaton.
# Copyright (c) 1994-1999, Andries E. Brouwer.
#
# You may distribute under the terms of the GNU General Public
# License as specified in the README file that comes with the man
# distribution.  
#
# apropos/whatis-1.5h aeb 990627 (from %version%)
#
OLDPATH=$PATH
PATH=/usr/local/bin:/bin:/usr/ucb:/usr/bin

program=`basename $0`

aproposgrepopt1='i'
aproposgrepopt2=''
whatisgrepopt1='iw'
whatisgrepopt2='^'
grepopt1=$%apropos_or_whatis%grepopt1
grepopt2=$%apropos_or_whatis%grepopt2

if [ $# = 0 ]
then
    echo "usage: $program keyword ..."
    exit 1
fi

manpath=`(PATH=$OLDPATH; %bindir%/man %manpathoption%) | tr : '\040'`

if [ "$manpath" = "" ]
then
    echo "$program: manpath is null"
    exit 1
fi

if [ "$PAGER" = "" ]
then
    PAGER="%pager%"
fi

args=
for arg in $*; do
    case $arg in
        --version|-V|-v)
	    echo "$program from %version%"
	    exit 0
	    ;;
	--help|-h)
            echo "usage: $program keyword ..."
	    exit 0
	    ;;
	-*)
	    echo "$program: $arg: unknown option"
	    exit 1
	    ;;
	*)
	    args="$args $arg"
    esac
done

# avoid using a pager if only output is "nothing appropriate"
nothing=
found=0
while [ $found = 0 -a -n "$1" ]
do
    for d in $manpath /usr/lib
    do
        if [ -f $d/whatis ]
        then
            if grep -"$grepopt1"%grepsilent% "$grepopt2""$1" $d/whatis > /dev/null
            then
                found=1
            fi
        fi
    done
    if [ $found = 0 ]
    then
	nothing="$nothing $1"
	shift
    fi
done

if [ $found = 0 ]
then
    for i in $nothing
    do
	echo "$i: nothing appropriate"
    done
    exit
fi

while [ $1 ]
do
    for i in $nothing
    do
	echo "$i: nothing appropriate"
    done
    nothing=
    found=0
    for d in $manpath /usr/lib
    do
        if [ -f $d/whatis ]
        then
            if grep -"$grepopt1" "$grepopt2""$1" $d/whatis
            then
                found=1
            fi
        fi
    done

    if [ $found = 0 ]
    then
        echo "$1: nothing appropriate"
    fi

    shift
done
# Maybe don't use a pager
# | $PAGER

exit
