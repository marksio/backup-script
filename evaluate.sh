#!/bin/bash

# Define variable
DIR="testing_backup"
backupFilename="backup_15073448.sh"
evaluationLogFilename="logfile_evaluate.txt"
config_file_name="testing"
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
        if [ $sessionyn = 'n' ]; then
            end
            thanks
            break
        elif [ $sessionyn = 'y' ]; then
            echo ""
        else 
            printf "Wrong input. Please enter the correct value\n"
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
        '3' - Summary of number of File(s) // Folder(s)
        '4' - View logfile of this test
        '5' - Delete Old // Previous '${DIR}' Folder
        "
        read -p "What scenario number you would like to test (From above):" menu
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
            countFile
            break
            ;;
        "4" )
            viewLog
            break
            ;;
        "5" )
            rm -rf testing_backup
            echo "
            Folder '${DIR}' Deleted
            "
            thanks
            exit
            ;;
        *)
            printf "Wrong input. Please enter the correct value.\n"
            ;;
        esac
    done
    createLog
}

function predefineCase() {
    while :
    do
        echo "
        '1' - Predefine setting without error, no config file existed on the destination (Creation of backup file)
        '2' - MUST RUN #1 first ~ Predefine setting without error, existed config file on the destination (2 Times)
        '3' - Error issue, wrong input when prompt user on session or program continuity
        '4' - Error issue, file existed but still create backup on the same destination
        '5' - Error issue, invalid input when prompt yes or no on do you have a default config file
        "
        read -p "What scenario number you would like to test (From above):" test
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
    done
    while :
    do
        read -p "Do you want to view the log or summary ('y' for Yes // 'n' for No) : " viewLogyn
        if [ $viewLogyn = 'y' ]; then
            printLog
            break
        elif [ $viewLogyn = 'n' ]; then
            break
        else
            printf "Wrong input. Please enter the correct value.\n"
        fi
    done
}
# '1' - Predefine setting without error, no config file existed on the destination (Creation of backup file)
function nPredefineNoError() {
    yn="n"
    session="n"
    echo -e "$dir_backup_config_file\n$yn\n$config_file_name\n$source\n$dest\n$session" | bash ./$backupFilename
    echo ""
    echo "All your evaluated backup file included logfile is allocated at '${DIR}' except for the config file."
    echo "Your evaluated folder name is '$(basename $dest)' which is destination is inside '${DIR}'"
    echo "Your source is from '$(basename $source)'"
    echo "Your config file name is at '${config_file_name}.txt' at 'backup_config_file'"
    echo "Your logfile name is '${evaluationLogFilename}' at '${DIR}'"
    echo ""
}

# '2' - MUST RUN #1 first ~ Predefine setting without error, existed config file on the destination (Creation of backup file)
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
function nPredefineError() {
    yn="n"
    session="asdfadreqr"
    echo -e "$yn\n$config_file_name\n$source\n$dest\n$session" | bash ./$backupFilename
}

# '4' - Error issue, file existed but still create backup on the same destination
function yPredefineError() {
    yn="y"
    exist_config_file_name="testing_backup/testing_folder"
    session="n"
    echo -e "$yn\n$exist_config_file_name\n$session" | bash ./$backupFilename
}

# '5' - Error issue, invalid input when prompt yes or no on do you have a default config file 
function invalid() {
    yn="asfad"
    echo -e "$yn" | bash ./$backupFilename 1>&2
	exit 1
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

# Viewlog file
function viewLog() {
    while :
    do
        if [ ! -f "$DIR/$evaluationLogFilename" ]; then
            echo "
            There is no $evaluationLogFilename file exist.
            Please run the Pre-Configuration Test or Manual Test first.
            "
            main
        fi
        read -p "Do you have Visual Studio Code ('y' for Yes // 'n' for No):" programA
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
    done 
}

# Count number of file(s) // folder(s) in summary
function countFile() {
    printf "Total number of file(s) in Source directory '${source}'\n"
    countSourceFile
    printf "\nTotal number of file(s) in Destination in '$(getLatestDestFolder)' under the directory of '${dest}'\n"
    countDestFile
    printf "\nTotal number of file(s) in each Destination folder under the directory of '${dest}'\n"
    countDestFileOnDir
    printf "You have perform $(countDir) evaluation and there is total of $(countDir) folder(s) in the directory of ''${dest}''\n"
    if [ $(countSourceFile) = $(countDestFile) ]; then
        printf "\nTotal number of file(s) matched which is $(countSourceFile)\n"
    fi
    echo ""
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
        if [ $delDir = "y" ]; then
            rm -rf testing_backup
            echo "
            Folder '${DIR}' Deleted
            "
            break
        elif [ $delDir = 'n' ]; then
            break
        else
            printf "Wrong input. Please enter the correct value.\n" 
        fi
    done    
}

function thanks() {
    echo '~~~ Thank You for using me ~~~'
}

# Execution of program
main