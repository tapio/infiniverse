#!/bin/sh
# Simple compilation & testing
# script for infiniverse-client

fbc -g -exx -w all -mt "src/infiniverse.bas" -x "./infiniverse-client"
fbc -g -exx -w all -mt "src/updater.bas" -x "./updater"
./infiniverse-client $@ -u Aave -w 4321

