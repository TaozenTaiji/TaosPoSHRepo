#By BigTeddy 05 September 2011

#This script uses the .NET FileSystemWatcher class to monitor file events in folder(s).
#The advantage of this method over using WMI eventing is that this can monitor sub-folders.
#The -Action parameter can contain any valid Powershell commands.  I have just included two for example.
#The script can be set to a wildcard filter, and IncludeSubdirectories can be changed to $true.
#You need not subscribe to all three types of event.  All three are shown for example.
# Version 1.1

$watchedfolder = ""
$transcriptpath = ""
$destinationpath = ""
$logpath = ""
$errorlogs = ""


$folder = '$watchedfolder' # Enter the root path you want to monitor.
$filter = '*.*'  # You can enter a wildcard filter here.

# In the following line, you can change 'IncludeSubdirectories to $true if required.                          
$fsw = New-Object IO.FileSystemWatcher $folder, $filter -Property @{IncludeSubdirectories = $false;NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite'}

# Here, all three events are registerd.  You need only subscribe to events that you need:

Register-ObjectEvent $fsw Created -SourceIdentifier FileCreated -Action {
Start-Transcript -Path $transcriptpath -append
$name = $Event.SourceEventArgs.Name
$changeType = $Event.SourceEventArgs.ChangeType
$timeStamp = $Event.TimeGenerated

while(!(test-path $destinationpath))      #This was added to test the ftp destination to make sure it was available before moving the file.
{
start-sleep 5
}

Move-Item -path E:\pdf_ftp\HeartAndVascularWI\$name -Destination $destinationpath -force -ErrorVariable errs -ErrorAction SilentlyContinue
if ($errs.Count -eq 0)
{
    Write-Host "The file $name was moved at $timeStamp" -fore green
    Out-File -FilePath $logpath -Append -InputObject "The file $name was successfully moved at $timeStamp with no errors"
}
else
{

	$date = Get-date -format "MM-dd-yyyy"
	Write-Host "There was an error moving the file $name at $timeStamp" -fore green
	Out-File -FilePath $logpath -Append -InputObject "There was an error moving the file $name at $timeStamp. See Errors\$date.txt for details."
        Out-file -filepath $errorlogs -append -InputObject $Error[0]
	
}

Stop-Transcript
}
while($true) {
    Start-Sleep  10
}


<#
Register-ObjectEvent $fsw Deleted -SourceIdentifier FileDeleted -Action {
$name = $Event.SourceEventArgs.Name
$changeType = $Event.SourceEventArgs.ChangeType
$timeStamp = $Event.TimeGenerated
Write-Host "The file '$name' was $changeType at $timeStamp" -fore red
Out-File -FilePath c:\scripts\filechange\outlog.txt -Append -InputObject "The file '$name' was $changeType at $timeStamp"}

Register-ObjectEvent $fsw Changed -SourceIdentifier FileChanged -Action {
$name = $Event.SourceEventArgs.Name
$changeType = $Event.SourceEventArgs.ChangeType
$timeStamp = $Event.TimeGenerated
Write-Host "The file '$name' was $changeType at $timeStamp" -fore white
Out-File -FilePath c:\scripts\filechange\outlog.txt -Append -InputObject "The file '$name' was $changeType at $timeStamp"}
#>
# To stop the monitoring, run the following commands:
# Unregister-Event FileDeleted
# Unregister-Event FileCreated
# Unregister-Event FileChanged