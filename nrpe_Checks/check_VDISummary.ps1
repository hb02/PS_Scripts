$env:PSModulePath = $env:PSModulePath + ";C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Modules"
Import-Module VMware.Hv.Helper
Import-Module VMware.VimAutomation.Sdk
Import-Module VMware.VimAutomation.Vmc
Import-Module VMware.VimAutomation.Nsxt
Import-Module VMware.VimAutomation.vROps
Import-Module VMware.VimAutomation.Cloud
Import-Module VMware.ImageBuilder
Import-Module VMware.VimAutomation.Storage
Import-Module VMware.VumAutomation
Import-Module VMware.VimAutomation.Security
Import-Module VMware.VimAutomation.Hcx
#Import-Module VMware.Powercli

#Please Change Settings here / Instead of $HVUserName/$HVPassword you can create an Credential-Object with Get-Credential
$HVUserName = "ENTERUSERNAME"
$HVPassword = "EnterPathToPreviousCreatedPasswordFile" | convertto-securestring
$HVDomain = "ENTERDOMAIN"
$ConnectionServer = "ENTERSERVER"
$StatsFile = "PATHTOFILE"


$HVServer = Connect-HVServer -Server $ConnectionServer -Domain $HVDomain -User $HVUserName -Password $HVPassword
$Services= $HVServer.ExtensionData
$ProblemCount = $null

$baseStates = @('PROVISIONING_ERROR',
                'ERROR',
                'MAINTENANCE',
                'AGENT_UNREACHABLE',
                'AGENT_ERR_STARTUP_IN_PROGRESS',
                'AGENT_ERR_DISABLED',
                'AGENT_ERR_INVALID_IP',
                'AGENT_ERR_NEED_REBOOT',
                'AGENT_ERR_PROTOCOL_FAILURE',
                'AGENT_ERR_DOMAIN_FAILURE',
                'AGENT_CONFIG_ERROR',
                'ALREADY_USED',
                'UNKNOWN')

if($Services){

    #Getting all
    $AllMachines = (Get-HVMachineSummary).Count
    $AvailableMachines = (Get-HVMachineSummary -State AVAILABLE).Count
    $ConnectedMachines = (Get-HVMachineSummary -State CONNECTED).Count
    $DisconnectedMachines = (Get-HVMachineSummary -State DISCONNECTED).Count

    #Write-Output "Short Summary:"

    foreach($State in $baseStates){
        $Count = ""
    #    Write-Output "Getting $State"
        $Machines = Get-HVMachineSummary -State $State -SuppressInfo $true
        $Count = $Machines.Count
        If($Count-ne "0"){
    #        Write-Output "Find $Count Machines in State $State"
            $ProblemWS = $ProblemWS + "\n" + $State
            foreach($Machine in $Machines){
                $ProblemWS = $ProblemWS + "\n" + $Machine.Base.Name.ToString()
    #            Write-Output $Machine.Base.Name.ToString()
            }         
        }
        $ProblemCount = $ProblemCount + $Count
    }

    #Write-Output ""
    #Write-Output "$ProblemCount # of Machines with Problems"
    #Write-Output "$AvailableMachines # of Available Machines"
    #Write-Output "$ConnectedMachines # of Connected Machines"
    #Write-Output "$DisconnectedMachines # of Disonnected Machines"
    #Write-Output "__________________________________________"
    #Write-Output "$AllMachines # of total Machines"

	$MainStatus =  " $AvailableMachines from $AllMachines available. $ConnectedMachines Machines connected"
    $PerfData = "|'All_Machines'=${AllMachines}Stk 'Available_Machines'=${AvailableMachines}Stk 'Machines_in_use'=${ConnectedMachines}Stk 'Machines_Disconnected'=${DisconnectedMachines}Stk 'Machines_with_Problems'=${ProblemCount}Stk"

	$ExitCode = ""
    If ($ProblemCount -eq "0"){
		$Status = "Check OK"
        $ExtendedStatus = ""
        $ExitCode = 0
    } else {
		$Status = "Warning"
        $ExtendedStatus = "\n" + $ProblemWS
        $ExitCode = 1
    }
}else{
    $Status = "Error: Could not connect to HV-Server"
    $ExitCode = 2
}

$Output = $Status + ": " + $MainStatus + "." + $PerfData + $ExtendedStatus
Write-Output $Output
Disconnect-HVServer -Server $ConnectionServer -confirm:$false
$env:PSModulePath = $env:PSModulePath -replace ";C:\\Program Files (x86)\\VMware\\Infrastructure\\PowerCLI\\Modules"

#Writing our Data to file
$TimeStamp = Get-Date -UFormat "%d.%m.%Y %T"

${TimeStamp} | Out-File -FilePath $StatsFile -Force
${AllMachines} | Out-File -FilePath $StatsFile -Append
${AvailableMachines} | Out-File -FilePath $StatsFile -Append
${ConnectedMachines} | Out-File -FilePath $StatsFile -Append
${DisconnectedMachines} | Out-File -FilePath $StatsFile -Append
${ProblemCount} | Out-File -FilePath $StatsFile -Append

Exit ($ExitCode)