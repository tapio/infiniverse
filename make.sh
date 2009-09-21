#!/bin/sh
# Simple compilation & testing
# script for infiniverse-client

fbc -w all "src/infiniverse.bas" -x "./infiniverse-client"
fbc -w all "src/updater.bas" -x "./updater"
./infiniverse-client $@ -u Aave -w 4321

