#!/bin/bash

# Declare variable
DIR="testing_backup"
backupFilename="backup.sh"
evaluationLogFilename="logfile_evaluate.txt"
backupEvaluateLogFilename="logfile_backup_evaluate.txt"
config_file_name="testing"
exist_config_file_name="testing"
source="../Documents"
dest="testing_backup/testing_noErrorPredefine"

function datetime() {
    echo `date +"%d-%m-%Y_%H:%M:%S:%N"`
}

# Only main function will be call first then only other function will be called. Main function is like the boss, allocate tasks to others
function main() {
    while :
    do
        welcome
        initialSetup
        menu
        read -p "Do you want to continue ('y' for Yes // 'n' for No) : " sessionyn
        if [ "$?" != "0" ]; then
            printf "\n[Error]!!!\n\n" 1>&2
            exit 1
        else
            if [ $sessionyn = 'n' ]; then
                end
                thanks
                break
            elif [ $sessionyn = 'y' ]; then
                echo ""
            else 
                printf "Wrong input. Please enter the correct value\n"
            fi
        fi
    done
}

function welcome() {
    echo "
    ~~~ This is a Script that Help you To Check OR Evaluate your Backup your Files ~~~
    "
}

function initialSetup() {
    if [ ! -d "$DIR" ]; then
        mkdir $DIR
    fi
}

# Prompt Menu to user
function menu() {
    while :
    do
        echo "
        '1' - Pre-configured Test
        '2' - Manual Test
        '3' - Test based on logfile of '${backupEvaluateLogFilename}' (Must the backup script at least once)
        '4' - Summary of number of File(s) // Folder(s)
        '5' - View logfile of this test
        '6' - Delete Old // Previous '${DIR}' Folder & config file '$config_file.txt' produced by this script
        "
        read -p "What scenario number you would like to test (From above):" menu
        if [ "$?" != "0" ]; then
            printf "\n[Error]!!!\n\n" 1>&2
            exit 1
        else
            case $menu in
            "1")
                predefineCase
                break
                ;;
            "2" )
                printf "\n\n\n\n\nThis backup script is executed though evaluate script\nSo remember for your backup destination will be at '${DIR}' 
                and your config file name will be '${config_file_name}'\n\n"
                ./$backupFilename
                break
                ;;
            "3" )
                testBackupEvaluateLogfile
                break
                ;;
            "4" )
                countFile
                break
                ;;
            "5" )
                viewLog
                break
                ;;
            "6" )
                rm -rf $DIR
                rm -rf asdfad
                if [ -f "$config_file_name.txt" ]; then
                    rm backup_config_file/$config_file_name.txt
                fi
                echo "
                Folder '${DIR}' Deleted
                "
                thanks
                break
                ;;
            *)
                printf "Wrong input. Please enter the correct value.\n"
                ;;
            esac
        fi
    done
    createLog
}

function predefineCase() {
    while :
    do
        echo "
        '1' - Predefine setting without error, no config file existed on the destination (Creation of backup file)
        '2' - MUST RUN #1 first ~ Predefine setting without error, existed config file on the destination (Automatically run for 2 Times)
        '3' - Error issue, wrong input when prompt user on session or program continuity
        '4' - Error issue, file existed but still create backup on the same destination
        '5' - Error issue, invalid input when prompt yes or no on do you have a default config file
        "
        read -p "What scenario number you would like to test (From above):" test
        if [ "$?" != "0" ]; then
            printf "\n[Error]!!!\n\n" 1>&2
            exit 1
        else
            case $test in
            "1")
                nPredefineNoError
                break
                ;;
            "2" )
                yPredefineNoError
                break
                ;;
            "3" )
                nPredefineError
                break
                ;;
            "4" )
                yPredefineError
                break
                ;;
            "5" )
                invalid
                break
                ;;
            *)
                printf "Wrong input. Please enter the correct value.\n"
                ;;
            esac
        fi
    done
    while :
    do
        read -p "Do you want to view the log or summary ('y' for Yes // 'n' for No) : " viewLogyn
        if [ "$?" != "0" ]; then
            printf "\n[Error]!!!\n\n" 1>&2
            exit 1
        else
            if [ $viewLogyn = 'y' ]; then
                printLog
                break
            elif [ $viewLogyn = 'n' ]; then
                break
            else
                printf "Wrong input. Please enter the correct value.\n"
            fi
        fi
    done
}

# '1' - Predefine setting without error, no config file existed on the destination (Creation of backup file)
function nPredefineNoError() {
    yn="n"
    session="n"
    echo -e "$yn\n$config_file_name\n$source\n$dest\n$session" | bash ./$backupFilename
    echo ""
    echo "All your evaluated backup file included logfile is allocated at '${DIR}' except for the config file."
    echo "Your evaluated folder name is '$(basename $dest)' which is destination is inside '${DIR}'"
    echo "Your source is from '$(basename $source)'"
    echo "Your config file name is at '${config_file_name}.txt' at 'backup_config_file'"
    echo "Your logfile name is '${evaluationLogFilename}' at '${DIR}'"
    echo ""
}

# '2' - MUST RUN #1 first ~ Predefine setting without error, existed config file on the destination (2 Times)
# It will create 2 folder with same file(s) inside 2 different folder
function yPredefineNoError() {
    yn="y"
    session="n"
    echo -e "$yn\n$exist_config_file_name\n$session" | bash ./$backupFilename
    echo -e "$yn\n$exist_config_file_name\n$session" | bash ./$backupFilename
    echo ""
    echo "All your evaluated backup file included logfile is allocated at '${DIR}' except for the config file."
    echo "Your evaluated folder name is '$(basename $dest)' which is destination is inside '${DIR}'"
    echo "Your source is from '$(basename $source)'"
    echo "Your config file name is at '${exist_config_file_name}.txt' at 'backup_config_file'"
    echo "Your logfile name is '${evaluationLogFilename}' at '${DIR}'"
    echo ""
}

# '3' - Error issue, wrong input when prompt user on session continuity
# Depending on any file(s) or folder(s) existent
# If file(s) or folder(s) existed, then it will create a folder name called "asdfad" outside the "testing_backup folder"
# If file(s) or folder(s) not exist, then it will backed up successfully but it prompt error
function nPredefineError() {
    yn="n"
    session="asdfad"
    echo -e "$yn\n$config_file_name\n$source\n$dest\n$session" | bash ./$backupFilename
}

# '4' - Error issue, file existed but still create backup on the same destination
# Unable to create a backup
# Error pop up
function yPredefineError() {
    yn="y"
    exist_config_file_name="testing_backup/testing_folder"
    session="n"
    echo -e "$yn\n$exist_config_file_name\n$session" | bash ./$backupFilename
}

# '5' - Error issue, invalid input when prompt yes or no on do you have a default config file 
# It directly pop error because of invalid input
function invalid() {
    yn="asfad"
    echo -e "$yn" | bash ./$backupFilename 
}

# Called by menu function to test on the logfile produced by backup script
function testBackupEvaluateLogfile() {
    while read co da s de deTime; do
        counter=$co logfileDateTime=$da sourceFortestBackupEvaluateLogfile=$s destFortestBackupEvaluateLogfile=$de destTimestamp=$deTime
    done < $backupEvaluateLogFilename
    countFileFortestBackupEvaluateLogfile
}

# Count number of file(s) // folder(s) in summary
function countFileFortestBackupEvaluateLogfile() {
    printf "Total number of file(s) in Source directory '${sourceFortestBackupEvaluateLogfile}'\n"
    countSourceFileFortestBackupEvaluateLogfile
    printf "\nTotal number of file(s) in most recent backup Destination in '${destTimestamp}' under the directory of '${destFortestBackupEvaluateLogfile} folder'\n"
    countDestFileFortestBackupEvaluateLogfile
    printf "\nTotal number of file(s) in each Destination folder under the directory of '${destFortestBackupEvaluateLogfile}'\n"
    countDestFileOnDirFortestBackupEvaluateLogfile
    printf "You have perform $(countDirFortestBackupEvaluateLogfile) of backup and there is total of $(countDirFortestBackupEvaluateLogfile) folder(s) in the directory of '${destFortestBackupEvaluateLogfile}'\n"
    if [ $(countSourceFileFortestBackupEvaluateLogfile) = $(countDestFileFortestBackupEvaluateLogfile) ]; then
        printf "\nTotal number of file(s) matched which is $(countSourceFileFortestBackupEvaluateLogfile) with the source and destination\n"
    fi
    printf "In total you have perform $counter of backup\n"
    echo ""
    printf "===================================================================================================\n"
    printf "===================================================================================================\n\n"
}

# Count number of file in source directory
function countSourceFileFortestBackupEvaluateLogfile() {
    find $sourceFortestBackupEvaluateLogfile -type f | wc -l
}

# Count number of file in destination
function countDestFileFortestBackupEvaluateLogfile() {
    cd $destFortestBackupEvaluateLogfile
    find $destTimestamp -type f | wc -l
    cd ../
}

# Count number of file inside each folder of testing_backup
function countDestFileOnDirFortestBackupEvaluateLogfile() {
    for entry in "$destFortestBackupEvaluateLogfile"/*
    do
        echo $(basename $entry)
        find $entry -type f | wc -l
        echo ""
    done
}

# Count number of folder in the testing_backup folder
function countDirFortestBackupEvaluateLogfile() {
    cd $destFortestBackupEvaluateLogfile
    ls -A | wc -l
    cd ../
}

# Creation of logfile
function createLog() {
    if [ -d "$dest" ]; then
        if [ $? -eq 0 ]; then
            printf "$(datetime) - Successfully run evaluation script on ${backupFilename}\n" >> $DIR/$evaluationLogFilename
            printf "Summary of Number of File(s) or Folder(s)\n" >> $DIR/$evaluationLogFilename
            printf "$(countFile)\n\n" >> $DIR/$evaluationLogFilename
        else
            printf "$(datetime) - [ERROR] Runnung evaluation script on ${backupFilename}\n\n" >> $DIR/$evaluationLogFilename
        fi       
    fi
}

# Printing of log
function printLog() {
    if [ -d "$dest" ]; then
        if [ $? -eq 0 ]; then
            printf "$(datetime) - Successfully run evaluation script on ${backupFilename}\n"
            printf "Summary of Number of File(s) or Folder(s)\n"
            countFile
        else
            printf "$(datetime) - [ERROR] Runnung evaluation script on ${backupFilename}\n"
        fi
    fi
}

# View logfile
function viewLog() {
    while :
    do
        if [ ! -f "$DIR/$evaluationLogFilename" ]; then
            echo "\nThere is no $evaluationLogFilename file exist.\nPlease run the Pre-Configuration Test or Manual Test first.\n\n"
            main
        fi
        read -p "Do you have Visual Studio Code ('y' for Yes // 'n' for No):" programA
        if [ "$?" != "0" ]; then
            printf "\n[Error]!!!\n\n" 1>&2
            exit 1
        else
            case $programA in
            "n")
                cat $DIR/$evaluationLogFilename
                break
                ;;
            "y" )
                code $DIR/$evaluationLogFilename
                break
                ;;
            *)
                printf "Wrong input. Please enter the correct value.\n"
                ;;
            esac
        fi
    done 
}

# Count number of file(s) // folder(s) in summary
function countFile() {
    printf "Total number of file(s) in Source directory '${source}'\n"
    countSourceFile
    printf "\nTotal number of file(s) in most recent backup Destination in '$(getLatestDestFolder)' under the directory of '${dest}'\n"
    countDestFile
    printf "\nTotal number of file(s) in each Destination folder under the directory of '${dest}'\n"
    countDestFileOnDir
    printf "You have perform $(countDir) evaluation and there is total of $(countDir) folder(s) in the directory of '${dest}'\n"
    if [ $(countSourceFile) = $(countDestFile) ]; then
        printf "\nTotal number of file(s) matched which is $(countSourceFile) with the source and destination\n"
    fi
    echo ""
    printf "===================================================================================================\n"
    printf "===================================================================================================\n\n"
}

# Count number of file in source directory
function countSourceFile() {
    find $source -type f | wc -l
}

# Count number of file in destination
function countDestFile() {
    vargetLatestDestFolder=$(getLatestDestFolder)
    cd $dest/$vargetLatestDestFolder
    find $getLatestDestFolder -type f | wc -l
    cd ../../../
}

# Count number of file inside each folder of testing_backup
function countDestFileOnDir() {
    for entry in "$dest"/*
    do
        echo $(basename $entry)
        find $entry -type f | wc -l
        echo ""
    done
}

# Get the folder name of the most recent created
function getLatestDestFolder() {
    varGetLatestDestFolder=$(ls -dt1 "$dest"/*/ | head -n1)
    echo $(basename $varGetLatestDestFolder)
}

# Count number of folder in the testing_backup folder
function countDir() {
    cd $dest 
    ls -A | wc -l
    cd ../../
}

# Prompting user on deletion of folder 'testing_backup'
function end() {
    while :
    do
        read -p "Do you want to delete this '${DIR}' directory ('y' for Yes // 'n' for No) : " delDir
        if [ "$?" != "0" ]; then
            printf "\n[Error]!!!\n\n" 1>&2
            exit 1
        else
            if [ $delDir = "y" ]; then
                rm -rf $DIR
                rm -rf asdfad
                if [ -f "$config_file_name.txt" ]; then
                    rm backup_config_file/$config_file_name.txt
                fi
                echo "
                Folder '${DIR}' Deleted
                "
                break
            elif [ $delDir = 'n' ]; then
                break
            else
                printf "Wrong input. Please enter the correct value.\n" 
            fi
        fi
    done    
}

function thanks() {
    echo '~~~ Thank You for using me ~~~'
}

# Execution of program
main