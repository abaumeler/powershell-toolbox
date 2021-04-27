####################################################################
# A.Baumeler
# 18.06.2020
# 
# Copies a Folder reursively from the source path to the destination
# path. Writes a logfile to the log-path
# Multiple jobs can be defined and are processed sequentially
# Provides support to rename and exclude certain subfolders 
####################################################################

####################
# Parameters
####################
param(
    [Parameter(Mandatory = $true)][string]$config = "conf.xml",
    [Parameter(Mandatory = $false)][boolean]$dryrun = $true,
    [Parameter(Mandatory = $false)][boolean]$dbg = $false
)

$Global:ConfigAvailable = $false
$Global:ConfigXML = $null
$Global:RoboArgs = $null
$Global:PrefixRegex = $null
$Global:LogFile = $null
$Global:LogID = $null
$Global:ErrorLevel = "[ERROR]"
$Global:WarningLevel = "[WARN]"
$Global:InformationLevel = "[INFO]"
$Global:DebugLevel = "[Debug]"

# Reads the config file and sets the global variables accordingly
function Read-Config {
    # Check if Config File is present
    if (-not (Test-Path $config)) {
        Write-Host "Configuration file is not acessible"
    }
    else {
        [xml]$Global:Configxml = Get-Content $config
        $Global:LogID = ([string]([guid]::NewGuid())).Split('-')[0]
        $Global:LogPath = $Global:Configxml.Settings.General.LogPath
        $Global:PrefixRegex = $Global:Configxml.Settings.General.PrefixRemoveRegex
        $Global:LogFile = "$($Global:LogPath)\JobRun_$($Global:LogID).log"
        $Global:RoboArgs = $Global:Configxml.Settings.General.RoboArgs
        $Global:IgnoreFoldersList = $Global:Configxml.Settings.General.IgnoreFoldersList
        $Global:ConfigAvailable = $true
    }    
}

function Write-Log {
    param(
        [string]$level,
        [string]$message)

    if ($Global:configAvailable) {
        $timestamp = Get-Date -Format 'yyyy.MM.dd hh:mm:ss'
        if($dbg){
            Add-Content $Global:LogFile -value "$($timestamp): $($level) $($message)" 
        }elseif($level -ne $Global:DebugLevel){
            Add-Content $Global:LogFile -value "$($timestamp): $($level) $($message)"
        }     
    } 
}

function Invoke-Robocopy{
    param(
        [string]$source,
        [string]$destination,
        [string]$ignoreFolderArguments,
		[string]$jobnumber,
		[string]$name)

    if (-not $dryrun) {
        $roboExpression = "robocopy '$source' '$destination' /Log+:'$Global:LogPath'\'JobRun_$($Global:LogID)_Job_$($jobnumber)_$($name).log' $ignoreFolderArguments $Global:RoboArgs"
        Invoke-Expression -Command $roboExpression 
    }
    else {
        $roboExpression = "robocopy '$source' '$destination' /l /Log+:'$Global:LogPath'\'JobRun_$($Global:LogID)_Job_$($jobnumber)_$($name).log' $ignoreFolderArguments $Global:RoboArgs"
        Invoke-Expression -Command $roboExpression 
    }

}

####################
# Script Entry
####################

Read-Config

if ($Global:configAvailable) {
    Write-Log $Global:InformationLevel "Dryrun: $($dryrun)"
    Write-Log $Global:InformationLevel "Debug: $($dbg)"
    Write-Log $Global:InformationLevel "Global Robocopy Arguments: $($Global:RoboArgs)"
    Write-Log $Global:InformationLevel "Global Prefix Regex: $($Global:PrefixRegex)"
    Write-Log $Global:InformationLevel "Ignore Folders List: $($Global:IgnoreFoldersList)" 
    Write-Log $Global:InformationLevel "Starting to process copy jobs"
        
    Write-Log $Global:DebugLevel "Reading job list"
    $jobs = $Global:ConfigXML.Settings.JobList.Job
    Write-Log $Global:DebugLevel "Job list read"
    
    $jobCount = $Global:ConfigXML.Settings.JobList.ChildNodes.Count
    Write-Log $Global:InformationLevel "$($jobCount) Jobs to process"
    $currentJob = 1
    
    foreach ($job in $jobs) {
        $ignoreFoldersArguments = $null
        $cleanPrefix = $false
        if($job.CleanPrefix -eq "1"){
            $cleanPrefix = $true
        }

        $ignoreFolders = $false
        if($job.UseIgnoreFolders -eq "1"){
            $ignoreFolders = $true
        }

        Write-Log $Global:InformationLevel "-----------------------------------------------------------"
        Write-Log $Global:InformationLevel "Processing job $($currentJob) of $($jobCount) "
        Write-Log $Global:InformationLevel "Jobname: $($job.Name)"
        Write-Log $Global:InformationLevel "Source: $($job.SourcePath)"
        Write-Log $Global:InformationLevel "Target: $($job.DestinationPath)"
        Write-Log $Global:InformationLevel "CleanPrefix: $($cleanPrefix)"   
        Write-Log $Global:InformationLevel "IgnoreFolders: $($ignoreFolders)"     
       
        $sourceFolders = Get-ChildItem -Literalpath $job.SourcePath -Directory

        if($ignoreFolders){
            #Prepare IgnoreFoldersList to be used with robocopy
            $ignoreFoldersArguments = "/XD"
            $folders = $Global:IgnoreFoldersList -split ";"
            foreach($folder in $folders){
                $ignoreFoldersArguments = $ignoreFoldersArguments + " " + $folder
            }
            Write-Log $Global:DebugLevel "ignoreFoldersArguments: $($ignoreFoldersArguments)"
        }

        foreach($sourceFolder in $sourceFolders){
            $sourceFolderPath = $sourceFolder.FullName
            $sourceFolderName = $sourceFolder.Name
            $targetFolderName = $sourceFolderName

            if($cleanPrefix){
                $targetFolderName = $sourceFolderName -replace $Global:PrefixRegex,""
                $targetFolderName = $targetFolderName.TrimStart('-', ' ')
            }      
            $targetFolderPath = "$($job.DestinationPath)\$($targetFolderName)" 

            Write-Log $Global:InformationLevel "Processing folder: $sourceFolder"
            Write-Log $Global:DebugLevel "Sourcefolder: $sourceFolderName"
            Write-Log $Global:DebugLevel "Targetfolder: $targetFolderName"

            Invoke-Robocopy $sourceFolderPath $targetFolderPath $ignoreFoldersArguments $currentJob $($job.Name)
        }
        Write-Log $Global:InformationLevel "Job $($currentJob) completed"
        $currentJob += 1
    }
    Write-Log $Global:InformationLevel "All jobs processed"
}    