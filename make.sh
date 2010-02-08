#!/bin/sh
# Script name: make.sh
# Description: Compile Infiniverse
# Version:     0.3

FBC="fbc" # Path to fbc
WINFBC="C:\Program Files\FreeBASIC\fbc.exe" # Path to fbc.exe
WINE="wine" # Wine command
FLAGS="-w all -mt -t 4096" # Default compilation flags
DEBUGFLAGS="$FLAGS -g -exx" # Debug flags
EXENAME="./infiniverse-client" # .exe is added if wine is enabled
UPDATERNAME="./updater" # .exe is added if wine is enabled
LIBPATH="../lib" # Where are binary libraries?
CONTRIBPATH="../contrib" # Where is additional code?
INCLUDEPATH="../include" # Where are library headers?

HELPSTRING="Usage: $0 [RELEASE|DEBUG|CLEAN|WINERELEASE|WINEDEBUG|WINECLEAN|CLEANALL]"

RULE="$1"
if [ "$RULE" = "" ]; then
	echo "$HELPSTRING"
	echo "No rule specified, defaulting to DEBUG"
	RULE="DEBUG" # Default make rule
fi

case $RULE in
	-h | --help )
		echo "$HELPSTRING"
		exit 0
		;;
	DEBUG )
		FLAGS=$DEBUGFLAGS
		WINE=""
		LIBPATH="$LIBPATH/linux"
		;;
	WINEDEBUG )
		FBC="$WINFBC"
		FLAGS=$DEBUGFLAGS
		EXENAME="$EXENAME.exe"
		UPDATERNAME="$UPDATERNAME.exe"
		LIBPATH="$LIBPATH/win32"
		;;
	RELEASE )
		WINE=""
		LIBPATH="$LIBPATH/linux"
		;;
	WINERELEASE )
		FBC=$WINFBC
		EXENAME="$EXENAME.exe"
		UPDATERNAME="$UPDATERNAME.exe"
		LIBPATH="$LIBPATH/win32"
		;;
	CLEAN )
		rm "$EXENAME"
		rm "$UPDATERNAME"
		exit 0
		;;
	WINECLEAN )
		rm "$EXENAME.exe"
		rm "$UPDATERNAME.exe"
		exit 0
		;;
	CLEANALL )
		rm "$EXENAME"
		rm "$UPDATERNAME"
		rm "$EXENAME.exe"
		rm "$UPDATERNAME.exe"
		exit 0
		;;		
	* )
		echo "Unknown rule $1"
		echo "$HELPSTRING"
		exit 1
esac

# Make client
echo "Make Infiniverse client ($EXENAME)"
$WINE "$FBC" $FLAGS -p "$LIBPATH" -i "$CONTRIBPATH" -i "$INCLUDEPATH" "src/infiniverse.bas" -x "$EXENAME"

# Make updater
echo "Make Updater ($UPDATERNAME)"
$WINE "$FBC" $FLAGS -p "$LIBPATH" -i "$CONTRIBPATH" -i "$INCLUDEPATH" "src/updater.bas" -x "$UPDATERNAME"

