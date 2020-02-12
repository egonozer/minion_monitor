#!/usr/bin/env bash

## Variables
minknow_path="/var/lib/minknow/data"
hd_path="/media/minion/easystore/data"
remote_address="quest.it.northwestern.edu"
remote_path="/projects/b1042/OzerLab/minion_basecalling"
bc_script="/projects/p30002/Scripts/auto_basecall.sh"
batch_size=50

echo ""
echo "MinION monitor and basecall"
echo "Dynamically performs the following steps:"
echo "  1) Backs up fast5 files to external drive"
echo "  2) Copies fast5 files to Quest"
echo "  3) Starts basecalling every ${batch_size} fast5 files"
echo ""
echo "INSTRUCTIONS:"
echo "- Start this script before starting MinKNOW"
echo "- Start the run in MinKNOW"
echo "- Walk away"
echo "- When the run is complete, press 'ctrl-c' to end the script and"
echo "  automatically start basecalling the remaining fast5 files on Quest"
echo ""

read -p "Enter your Quest user ID / netID: " uid

echo ""
echo "Waiting for experiment to appear..."

name="na"
while read path; do
    name=`echo $path | perl -pe "s/.*\///g"`
    break
done < <(fswatch --event 'Created' --event 'MovedTo' ${minknow_path})
    
echo "Experiment name: ${name}"

## Set up file destination on HDD
if [ -d "${hd_path}/${name}" ]
then
    echo "FYI: '${hd_path}/${name}' already exists."
else
    mkdir ${hd_path}/${name}
fi
echo "Backed up fast5 files found here: ${hd_path}/${name}"
echo "Basecalling files found here: ${remote_path}/${name}"

## Set up basecalling folder on Quest
file_count=0
folder_count=0

ssh ${uid}@${remote_address} "mkdir -p ${remote_path}/${name}/fast5_${folder_count}"

## This is to trap the ctrl-c keyboard input, but continue running these commands
trap signoff SIGINT
signoff() {
    echo ""
    if [[ $file_count -gt 0 ]]
    then
        dt=$(date '+%m/%d/%Y %H:%M:%S')
        echo "[${dt}] Starting basecalling on fast5_${folder_count}"
        ssh ${uid}@${remote_address} "bash ${bc_script} ${remote_path}/${name} $folder_count"
    fi
    dt=$(date '+%m/%d/%Y %H:%M:%S')
    echo "[${dt}] All done"
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
            cp ${path} ${hd_path}/${name}/
            ccode=$?
            timestop=`date +%s`
            exectime=`expr $timestop - $timestart`
            dt=$(date '+%m/%d/%Y %H:%M:%S')
            if [ $ccode -eq 0 ]
            then
                echo "[${dt}] Copied $file (${exectime}s)"
            else
                echo "[${dt}] FAILED TO COPY $file [exit code ${ccode}]"
            fi
            
            ##transfer file to Quest
            timestart=`date +%s`
            rsync -a -L ${path} ${uid}@${remote_address}:${remote_path}/${name}/fast5_${folder_count}/
            rcode=$?
            timestop=`date +%s`
            exectime=`expr $timestop - $timestart`
            dt=$(date '+%m/%d/%Y %H:%M:%S')
            if [ $rcode -eq 0 ]
            then
                echo "[${dt}] Moved $file to Quest (${exectime}s)"
            else
                echo "[${dt}] FAILED TO MOVE $file TO QUEST [exit code ${ccode}]"
            fi
            
            ##remove file from hard drive
            if [ $ccode -eq 0 ] || [ $rcode -eq 0 ]
            then
                rm ${path}
            else
                echo "****Unable to move or upload file $file"
            fi
            
            (( file_count++ ))
            
            if [[ $file_count -eq $batch_size ]]
            then
                dt=$(date '+%m/%d/%Y %H:%M:%S')
                echo "[${dt}] Starting basecalling on fast5_${folder_count}"
                ssh ${uid}@${remote_address} "bash ${bc_script} ${remote_path}/${name} $folder_count"
                file_count=0
                (( folder_count++ ))
                ssh ${uid}@${remote_address} "mkdir -p ${remote_path}/${name}/fast5_${folder_count}"
            fi
        fi
    done
