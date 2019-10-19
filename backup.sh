#!/bin/bash

# Declare variable
logfileName="logfile_backup.txt"
dirBackupConfigFile="backup_config_file"

function datetime() {
    echo `date +"%d-%m-%Y_%H:%M:%S:%N"`
}

# Only main function will be call first then only other function will be called. Main function is like the boss, allocate tasks to others
function main() {
    welcome
    configFileSetting
    backupFile
    sessionBackup
}

function welcome() {
    echo "
    ~~~ This is a Script that Help you To Backup your Files ~~~
    "
}

function configFileSetting() {
    while :
    do
        read -p "Do you have default config setting ('y' for Yes, 'n' for No): " yn
        if [ "$?" != "0" ]; then
            printf "\n[Error]!!!\n\n" 1>&2
            break
        fi
        case $yn in
        "y")
            if [ ! -d "$dirBackupConfigFile" ]; then
                echo "
                '${dirBackupConfigFile}' directory is not exist.
                "
                configFileSetting
                break
            else 
                yConfig
                break
            fi        
            ;;
        "n" )
            nConfig
            break
            ;;
        *)
            echo "You have entered wrong character !!"
            ;;
        esac
    done
    
}

function yConfig() {
    cd $dirBackupConfigFile    
    echo "List of file(s) on the current directory is/are" 
    ls
    while :
    do
        read -p "Enter the your default config setting file name (Without .txt): " exist_config_file_name
        if [ "$?" != "0" ]; then
            printf "\n[Error]!!!\n\n" 1>&2
            exit
        fi
        if [ ! -f "${exist_config_file_name}.txt" ]; then
            echo "
            '${exist_config_file_name}.txt' file not found.
            "
            echo "List of file(s) on the current directory is/are" 
            ls
        else 
            break
        fi
    done
    echo "'$exist_config_file_name.txt' file found."
    while read s d; do
        source=$s dest=$d
    done < $exist_config_file_name.txt
    cd ..
}

function nConfig() {
    if [ -d "$dirBackupConfigFile" ]; then
        echo "
        '${dirBackupConfigFile}' folder existed
        "
    fi
    echo "
    Your default configuration file will be store at '${dirBackupConfigFile}' folder on the same directory of this script
    "
    while :
    do
        read -p "Enter file name for default config (No file extention needed, It will Automatically define as .txt): " config_file_name
        if [ -e "$config_file_name" ]; then
            echo "
            '${config_file_name}' file existed
            "
        else 
            break
        fi
        if [ "$?" != "0" ]; then
            printf "\n[Error]!!!\n\n" 1>&2
            exit 1
        fi
    done  
    promptUserBackupSourceDest
    mkdir $dirBackupConfigFile
    echo "Created '${dirBackupConfigFile}' folder on the same directory of this script"
    echo "$source $dest" >> "$dirBackupConfigFile/$config_file_name.txt"
    if [ $? -eq 0 ]; then
        echo "Created config file '${config_file_name}.txt' Successfully at '${dirBackupConfigFile}' folder."
        echo $(datetime) - "Created config file '${config_file_name}.txt' Successfully at '${dirBackupConfigFile}' folder." >> $logfileName
    else
        echo "There is error creating config file '${config_file_name}.txt'."
        echo $(datetime) - "There is error creating config file '${config_file_name}.txt'." >> $logfileName
    fi
}

function promptUserBackupSourceDest() {
    while :
    do
        echo "Your current working directory is" 
        pwd
        read -p "Enter the FULL location path of the file you wish to backup (From / Source): " source
        if [ ! -d "$source" ]; then
            echo "Directory does not exist!" 
        else 
            break
        fi
        if [ "$?" != "0" ]; then
            printf "\n[Error]!!!\n\n" 1>&2
            exit 1
        fi
    done
    echo "Your current working directory is" 
    pwd
    read -p "Enter the FULL location path of the file you wish to saved to (Destination): " dest
    if [ ! -d "$dest" ]; then
        mkdir $dest            
    fi
}

function backupFile() {
    destTimestamp=$(basename $source)"_"$(datetime)
    cp -r $source"/." $dest/$destTimestamp
    if [ $? -eq 0 ]; then
        printf "Backup total of '$(countSourceFile)' file(s) from '${source}' to '${dest}' Successfully.\n"
        printf "$(datetime) - Backup total of '$(countSourceFile)' file(s) from '${source}' to '${dest}' Successfully.\n" >> $logfileName
        printf "~~~ Summary of Number of File(s) or Folder(s) Backed Up ~~~\n$(countFile)\n\n" >> $logfileName
    else
        echo "There is [ERROR] backing up files from '${source}' to '${dest}'. Check you destination path.
        "
        echo $(datetime) - "There is [ERROR] backing up files from '${source}' to '${dest}'. Check you destination path." >> $logfileName
    fi
}

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

function searchFile() {
    find . -name $dest*
}

# Prompt user on session or program continuity
function sessionBackup() {
    while :
    do
        read -p "Do you want to continue this backup script ('y' for Yes // 'n'for No) : " session
        if [ "$?" != "0" ]; then
            printf "\n[Error]!!!\n\n" 1>&2
            exit 1
        fi
        case $session in
        "Y" | "y")
            main
            ;;
        "N" | "n" )
            echo "~~~ Thank You using me ~~~"
            exit
            ;;
        *)
            echo "Please enter the valid value !!"
            ;;
        esac
    done
}

# Execution of program
main