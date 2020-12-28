####################################################
#
# A.Baumeler, 2020
# 
# This script uses the .NET FileSystemWatcher class to 
# monitor file events in folder(s). The advantage of this method 
# over using WMI eventing is that this can monitor sub-folders.
# The -Action parameter can contain any valid Powershell commands.  
# The script can be set to a wildcard filter, and IncludeSubdirectories 
# can be changed to $true. You need not subscribe to all three 
# types of event.  All three are shown for example. 
####################################################

 
# Path to monitor, paht must exist or script will fail
$folder = 'D:\Test'
# What to monitor, wildcards are accepted
$filter = '*.*' 
 
# In the following line, you can change 'IncludeSubdirectories to $true if required.                           
$fsw = New-Object IO.FileSystemWatcher $folder, $filter -Property @{IncludeSubdirectories = $false;NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite'} 
 
# Here, all three events are registerd.  You need only subscribe to events that you need: 

# Create event
Register-ObjectEvent $fsw Created -SourceIdentifier FileCreated -Action { 
$name = $Event.SourceEventArgs.Name 
$changeType = $Event.SourceEventArgs.ChangeType 
$timeStamp = $Event.TimeGenerated 
Write-Host "The file '$name' was $changeType at $timeStamp" -fore green 
Out-File -FilePath d:\outlog.txt -Append -InputObject "The file '$name' was $changeType at $timeStamp"} 
 
# deletion event
Register-ObjectEvent $fsw Deleted -SourceIdentifier FileDeleted -Action { 
$name = $Event.SourceEventArgs.Name 
$changeType = $Event.SourceEventArgs.ChangeType
$user = $Event.SourceEventArgs. 
$timeStamp = $Event.TimeGenerated 
Write-Host "The file '$name' was $changeType at $timeStamp" -fore red 
Out-File -FilePath d:\outlog.txt -Append -InputObject "The file '$name' was $changeType at $timeStamp"} 
 
#change event
Register-ObjectEvent $fsw Changed -SourceIdentifier FileChanged -Action { 
$name = $Event.SourceEventArgs.Name 
$changeType = $Event.SourceEventArgs.ChangeType 
$timeStamp = $Event.TimeGenerated 
Write-Host "The file '$name' was $changeType at $timeStamp" -fore white 
Out-File -FilePath d:\outlog.txt -Append -InputObject "The file '$name' was $changeType at $timeStamp"} 
 
# To stop the monitoring, run the following commands: 
# Unregister-Event FileDeleted 
# Unregister-Event FileCreated 
# Unregister-Event FileChanged