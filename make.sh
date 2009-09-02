#!/bin/sh
# Simple compilation & testing
# script for infiniverse-client

fbc -w all "src/infiniverse.bas" -x "./infiniverse-client"
./infiniverse-client $@ -u Aave -w 4321

