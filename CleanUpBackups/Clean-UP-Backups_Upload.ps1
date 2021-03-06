#Change Settings here
#GeneralLogfile Settings
$LogFilePath = "[Change Path]" #"C:\Log-Files" 
$Logfile = "[Enter Logfile]" #"\File-Delete"+ (Get-Date -Format dd_MM_yy-HH_mm_ss) +".log" 
$LogFileAge = "30"

$PathToCheck = "[ChangePath]" #"C:\Backups\MySQL\servers\localhost"
$FileType = "[ChangePath]" #"*.psc"
$FileAge = "30"

#Settings for MailSending
$MailUser = "[ENTER User]"
$MailFrom = "[Enter From MailAdress]"
$MailTo = "[Enter To MailAdress]"

Out-File -FilePath $Logfile -Append -InputObject ("------------------- Last Execution: " + (Get-Date -Format F) + " ------------------------------")

$Heute = Get-Date
$BackupFiles = Get-ChildItem -Recurse -Filter $FileType $PathToCheck | Where-Object {($Heute - $_.LastWriteTime).Days -gt $FileAge} #| Remove-Item

Out-File -FilePath $Logfile -Append -InputObject ("------------------- Deleted Files: " + (Get-Date -Format F) + " ------------------------------")

ForEach ($File in $BackupFiles) {
    If ($File.FullName -gt ""){
        Out-File -FilePath $Logfile -Append -InputObject ($File.FullName + ' | ' + $File.LastWriteTime)
        Remove-Item $File.FullName
    }
}

Out-File -FilePath $Logfile -Append -InputObject ("------------------- Finished Execution: " + (Get-Date -Format F) + " ------------------------------")

Get-ChildItem -Recurse -Filter "*.log" $LogFilePath | Where-Object {($Heute - $_.LastWriteTime).Days -gt $LogFileAge} | Remove-Item


$pw = Get-Content .\MailPW.txt | ConvertTo-SecureString
$cred = New-Object System.Management.Automation.PSCredential $MailUser , $pw

Send-MailMessage -From $MailFrom -Subject "Cleaned Backup's Log" -To $MailTo -Attachments $Logfile -Body "View Attached log file" -DeliveryNotificationOption OnFailure -SmtpServer 127.0.0.1 -Credential $cred