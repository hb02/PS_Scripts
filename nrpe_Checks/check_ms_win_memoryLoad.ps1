$os = Get-Ciminstance Win32_OperatingSystem
$warn = 90
$crit = 99
$ExitCode = 0
$memoryFree = $os.FreePhysicalMemory
$memoryinUse = [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory)/ 1024,0)
$memoryTotal = [math]::Round($os.TotalVisibleMemorySize / 1024,0)

$pctFree = 100-[math]::Round(($os.FreePhysicalMemory/$os.TotalVisibleMemorySize)*100,0)

cls

if($pctFree -ge $crit){
    $MemWarning = "MEMORY CRITICAL"
    $ExitCode=2
}elseif(($pctFree -lt $crit) -and ($pctFree -ge $warn)){
    $MemWarning = "MEMORY WARNING"
    $ExitCode=1
}elseif($pctFree -lt $warn){
    $MemWarning = "MEMORY OK"
    $ExitCode=0
}else{
    $MemWarning = "ERROR in MEMORY"
    $ExitCode=2
}

Write-Host "${MemWarning} - Pysical usage: ${memoryinUse} MB (${pctfree}% of ${memoryTotal} MB) |'memory in use'=${memoryinUse}MB 'memory usage'=${pctfree}%;${warn};${crit} 'memory total'=${memoryTotal}MB"
Exit($ExitCode)