#!/bin/bash

# SCRIPT FOR CRON TO START RAWDATA analysis from runfolder
# Check every runfolder in /nas-sync/upload/ 
# - if CTG_SampleSheet.rawdata.csv exists
#   - no ctg.rawdata.start OR no ctg.rawdata.done exists in runfolder
#   - ctg-interop folder within runfolder
# start rawdata delivery

# logs folder
cronlog="/projects/fs1/shared/ctg-cron/ctg-rawdata-cron/log.ctg-rawdata.log"
cronstout="/projects/fs1/shared/ctg-cron/ctg-rawdata-cron/log.ctg-rawdata.stout"

# all cron logs output goes
cronlog_all="/projects/fs1/shared/ctg-cron/ctg-cron.log"

# Go to root runfolder 
rootfolder="/projects/fs1/nas-sync/upload"
cd $rootfolder

# rawdata-driver
rawdriver="/projects/fs1/shared/ctg-cron/ctg-rawdata-cron/rawdata-crondriver"

# Function to run ctg-rawdata-driver
run_rawdata(){
    rootf=$1
    rf=$2
    touch $rootf/$rf/ctg.rawdata.start
    echo "$(date): $rf: STARTED: ctg-rawdata" >> $cronstout
    echo "$(date): $rf: STARTED: ctg-rawdata" >> $cronlog
    echo "$(date): $rf: STARTED: ctg-rawdata" >> $cronlog_all
    $rawdriver -d $rootf/$rf -u per >> $cronstout

    # If delivery fails (the command above fails to touch ctg.rawdata.done in the runfolder, it means it crashed
    if [ ! -f $rootf/$rf/ctg.rawdata.done ]; then
	echo "$(date): $rf: FAILED: ctg-rawdata" >> $cronlog
	echo "$(date): $rf: FAILED: ctg-rawdata" >> $cronlog_all
    else
	echo "$(date): $rf: DONE: ctg-rawdata" >> $cronlog
	echo "$(date): $rf: DONE: ctg-rawdata" >> $cronlog_all
    fi
}

# Iterate over all runfolders
# - Check if current files exist in runfolder:
# - ctg.sync.done 
# - ctg.rawdata.start 
# - ctg.rawdata.done
# - ctg-interop
# - CTG_SampleSheet.rawdata.csv

# Set to 0 - set to 1 if new rawdata-project found ready - break for loop when one is found (to avoid multiple transfers)
runpipe=0 

for runfolder in $(ls | grep "^2"); do

    cd $rootfolder

    runpipe=0 # set to 1 if all the following files exist
    
    # If CTG_SampleSheet.rawdata.csv
    if [ -f $rootfolder/$runfolder/CTG_SampleSheet.rawdata.csv ]; then
#	echo "$(date): $runfolder : CTG_SampleSheet.rawdata.csv exist.." 
	runpipe=0
	# If sync is complete
	if [ -f $rootfolder/$runfolder/sync.done ] || [ -f $rootfolder/$runfolder/ctg.sync.done ] ; then
#	    echo "$(date): $runfolder: sync done" 
	    runpipe=0
	    # If rawdata is not run or started
	    if [ -f $rootfolder/$runfolder/ctg.rawdata.start ] || [ -f $rootfolder/$runfolder/ctg.rawdata.done ] ;  then
#		echo "$(date): $runfolder : has already rawdata started / is done " 
		runpipe=0
	    # If rawdata is not started / run - set to run
	    else 
		if [ -d $rootfolder/$runfolder/ctg-interop ]; then
		    #		echo "**CRON** $(date): $runfolder : rawdata is not yet run -> start!" >> $cronlog
		    runpipe=1
		else
		    runpipe=0
		fi
	    fi
	fi
    fi

    if [ $runpipe == 1 ]
    then
	run_rawdata "$rootfolder" "$runfolder"
	break
    fi
	    
done


