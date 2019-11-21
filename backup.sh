#!/bin/bash

# Declare variable
logfileName="logfile_backup.txt"
logfileNameForEvaluate="logfile_backup_evaluate.txt"
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

# Prompt user on the availability of the configuration file
# Then redirect to respective function
function configFileSetting() {
    while :
    do
        read -p "Do you want to use OR have a default config setting ('y' for Yes, 'n' for No): " yn
        if [ "$?" != "0" ]; then
            printf "\n[Error]!!!\n\n" 1>&2
            exit 1
        else
            if [ $yn = "y" ]; then
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
            elif [ $yn = "n" ];  then
                nConfig
                break
            else
                printf "\nYou have entered wrong character !!\n\n"
            fi  
        fi
    done
    
}

# When user have a configuration file
function yConfig() {
    cd $dirBackupConfigFile    
    printf "\nList of file(s) on the current directory is/are\n" 
    ls
    while :
    do
        read -p "Enter the your default config setting file name (Without .txt): " exist_config_file_name
        if [ "$?" != "0" ]; then
            printf "\n[Error]!!!\n\n" 1>&2
            exit 1
        else
            if [ ! -f "${exist_config_file_name}.txt" ]; then
                printf "\n'${exist_config_file_name}.txt' configuration file not found."
                printf "\n\nList of file(s) on the current directory is/are\n" 
                ls
            else 
                break
            fi
        fi
    done
    printf "'$exist_config_file_name.txt' configuration file found.\n\n"
    while read s d; do
        source=$s dest=$d
    done < $exist_config_file_name.txt
    cd ..
}

# When user do not have a configuration file
function nConfig() {
    if [ -d "$dirBackupConfigFile" ]; then
        printf "\n'${dirBackupConfigFile}' folder existed\n"
    fi
    printf "Your default configuration file will be store at '${dirBackupConfigFile}' folder on the same directory of this script\n\n"
    while :
    do
        read -p "Enter file name for default config (No file extention needed, It will Automatically define as .txt): " config_file_name
        if [ "$?" != "0" ]; then
            printf "\n[Error]!!!\n\n" 1>&2
            exit 1
        else
            if [ -e "$config_file_name" ]; then
                echo "
                '${config_file_name}' file existed
                "
            else 
                break
            fi
        fi
    done  
    promptUserBackupSourceDest # Call this function to prompt user on the source and destination 
    if [ ! -d $dirBackupConfigFile ]; then
        mkdir $dirBackupConfigFile
    fi
    printf "\nCreated '${dirBackupConfigFile}' folder on the same directory of this script\n"
    echo "$source $dest" >> "$dirBackupConfigFile/$config_file_name.txt"
    if [ $? -eq 0 ]; then
        printf "Created config file '${config_file_name}.txt' Successfully at '${dirBackupConfigFile}' folder.\n"
        printf "$(datetime) - Created config file '${config_file_name}.txt' Successfully at '${dirBackupConfigFile}' folder.\n\n" >> $logfileName
    else
        printf "There is error creating config file '${config_file_name}.txt'.\n\n"
        printf "$(datetime) - There is error creating config file '${config_file_name}.txt'.\n\n" >> $logfileName
    fi
}

# Prompt user on the source and destination 
function promptUserBackupSourceDest() {
    while :
    do
        printf "\nYour current working directory is " 
        pwd
        read -p "Enter the FULL location path of the file you wish to backup (From / Source): " source
        if [ "$?" != "0" ]; then
            printf "\n[Error]!!!\n\n" 1>&2
            exit 1
        else
            if [ ! -d "$source" ]; then
                printf "\nDirectory does not exist!\n" 
            else 
                break
            fi
        fi
    done
    printf "\nYour current working directory is " 
    pwd
    while :
    do
        read -p "Enter the FULL location path of the file you wish to saved to (Destination): " dest
        if [ "$?" != "0" ]; then
            printf "\n[Error]!!!\n\n" 1>&2
            exit 1
        else
            if [ ! -d "$dest" ]; then
                mkdir $dest 
                break
            else
                printf "\nExisting directory name. Please try different directory name.\n\n"        
            fi
        fi
    done
}

# Execution of the backing up process (Copy from source to destionation)
function backupFile() {
    destTimestamp=$(basename $source)"_"$(datetime)
    cp -r $source"/." $dest/$destTimestamp
    if [ $? -eq 0 ]; then
        printf "Backup total of '$(countSourceFile)' file(s) from '${source}' to '${dest}' Successfully.\n\n"
        printf "$(datetime) - Backup total of '$(countSourceFile)' file(s) from '${source}' to '${dest}' Successfully.\n\n" >> $logfileName
        printf "~~~ Summary of Number of File(s) or Folder(s) Backed Up ~~~\n$(countFile)\n\n" >> $logfileName
        if [ ! -f "$logfileNameForEvaluate" ]; then
            let counter=1
            printf "$counter $(datetime) ${source} ${dest} ${destTimestamp} \n" >> $logfileNameForEvaluate
        else 
            while read co da s de deTime; do
                counter=$co
            done < $logfileNameForEvaluate
            let counter=counter+1
            printf "$counter $(datetime) ${source} ${dest} ${destTimestamp} \n" >> $logfileNameForEvaluate
        fi        
    else
        printf "\nThere is [ERROR] backing up files from '${source}' to '${dest}'. Check you destination path.\n\n"
        printf "$(datetime) - There is [ERROR] backing up files from '${source}' to '${dest}'. Check you destination path.\n\n" >> $logfileName
    fi
}

# Being called by backupFile function to insert all this summary of file to logfile
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
    find $dest/$vargetLatestDestFolder/$getLatestDestFolder -type f | wc -l
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
        ls $dest -A | wc -l  
}

# Prompt user on session or program continuity
function sessionBackup() {
    while :
    do
        read -p "Do you want to continue this backup script ('y' for Yes // 'n'for No) : " session
        if [ "$?" != "0" ]; then
            printf "\n[Error]!!!\n\n" 1>&2
            exit 1
        else
            if [ $session = "y" ]; then
                main
            elif [ $session = "n" ]; then
                printf "\n~~~ Thank You using me ~~~\n\n"
                exit
            else
                printf "\nPlease enter the valid value !!\n\n"
            fi
        fi
    done
}

# Execution of program
main