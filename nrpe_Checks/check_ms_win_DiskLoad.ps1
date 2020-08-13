Param(
  [Parameter(Mandatory=$true)]
  [string]$drive,
  [Parameter(Mandatory=$true)]
  [int]$warn,
  [Parameter(Mandatory=$true)]
  [int]$crit
)


#$drive = "c:"

#$warn = 97.5
#$crit = 99.5
$ExitCode = 0

#$disks = Get-CimInstance -Class CIM_LogicalDisk | Select-Object @{Name="Size(GB)";Expression={$_.size/1gb}}, @{Name="Free Space(GB)";Expression={$_.freespace/1gb}}, @{Name="Free (%)";Expression={"{0,6:P0}" -f(($_.freespace/1gb) / ($_.size/1gb))}}, DeviceID, DriveType | Where-Object DeviceID -EQ "${drive}"
$disk = Get-CimInstance -Class CIM_LogicalDisk | Where-Object DeviceID -EQ "${drive}"

$diskfree = [math]::Round(($disk.FreeSpace/1MB),2)
$diskinUse = [math]::Round((($disk.Size - $disk.FreeSpace)/1MB),2)
$disktotal = [math]::Round(($disk.Size/1MB),2)

$diskpctFree = 100-[math]::Round(($disk.FreeSpace/$disk.Size)*100,0)

if($diskpctFree -ge $crit){
    $DiskWarning = "DISK CRITICAL"
    $ExitCode=2
}elseif(($diskpctFree -lt $crit) -and ($pctFree -ge $warn)){
    $DiskWarning = "DISK WARNING"
    $ExitCode=1
}elseif($diskpctFree -lt $warn){
    $DiskWarning = "DISK OK"
    $ExitCode=0
}else{
    $DiskWarning = "DISK in MEMORY"
    $ExitCode=2
}

Write-Host "${DiskWarning} - Pysical usage: ${diskinUse} MB (${diskpctFree}% of ${disktotal} MB) |'disk in use'=${diskinUse}MB 'disk usage'=${diskpctFree}%;${warn};${crit} 'disk total'=${disktotal}MB"
Exit($ExitCode)