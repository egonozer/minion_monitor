#!/usr/bin/env bash

## Variables
minknow_path="/var/lib/minknow/data"
hd_path="/media/minion/easystore/data"

echo ""
echo "MinION monitor"
echo "Dynamically moves fast5 files to external drive"
echo ""

echo "Waiting for experiment to appear..."

name="na"
while read path; do
    name=`echo $path | perl -pe "s/.*\///g"`
    break
done < <(fswatch --event 'Created' --event 'MovedTo' ${minknow_path})

echo "Experiment name: ${name}"
echo ""

## Set up file destination on HDD
if [ -d "${hd_path}/${name}" ]
then
    echo "FYI: '${hd_path}/${name}' already exists."
else
    mkdir ${hd_path}/${name}
fi

trap signoff SIGINT
signoff() {
    echo ""
    echo "All done"
    exit
}

echo "Waiting for fast5 files..."
fswatch --event 'Created' --event 'MovedTo' ${minknow_path}/${name}/ |
    while read path; do
        file=`echo $path | perl -pe "s/.*\///g"`
        if [[ $file == *".fast5" ]]
        then
            ##back up the file
            timestart=`date +%s`
            mv ${path} ${hd_path}/${name}/
            ccode=$?
            timestop=`date +%s`
            exectime=`expr $timestop - $timestart`
            dt=$(date '+%m/%d/%Y %H:%M:%S')
            if [ $ccode -eq 0 ]
            then
                echo "[${dt}] Moved $file (${exectime}s)"
            else
                echo "[${dt}] FAILED TO MOVE $file [exit code ${ccode}]"
            fi
        fi
    done