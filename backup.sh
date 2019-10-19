#!/bin/bash

# Declare variable
logfileName="logfile_backup.txt"
dirBackupConfigFile="backup_config_file"

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
    else
        echo "There is [ERROR] backing up files from '${source}' to '${dest}'. Check you destination path.
        "
        echo $(datetime) - "There is [ERROR] backing up files from '${source}' to '${dest}'. Check you destination path." >> $logfileName
    fi
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

function datetime() {
    echo `date +"%d-%m-%Y_%H:%M:%S:%N"`
}

# Count number of file in source directory
function countSourceFile() {
    find $source -type f | wc -l
}

# Execution of program
main