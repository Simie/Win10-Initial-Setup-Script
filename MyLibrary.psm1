# Enable Reconnecting Network Drives on Login
Function EnableReconnectNetworkDrivesOnLogin {

	Write-Output "Enabling Reconnect Network Drives on Login..."
	
    $taskName = "Reconnect Network Drives"
    $scriptPath = "C:\Scripts"

	# Copy script to location on disk
    If(!(test-path $scriptPath))
    {
          New-Item -ItemType Directory -Force -Path $scriptPath
    }

    Copy-Item -Path "$PSScriptRoot/Scripts/MapDrives.ps1" -Destination "$scriptPath" -Force -Recurse

    $argument = "-NoProfile -WindowStyle Hidden -command $scriptPath\MapDrives.ps1 >> %TEMP%\StartupLog.txt 2>&1"

	$settings = New-ScheduledTaskSettingsSet -RunOnlyIfNetworkAvailable -StartWhenAvailable
	$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument $argument
	$principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Users" -RunLevel Limited
	$trigger =  New-ScheduledTaskTrigger -AtLogOn 
	
    if(Get-ScheduledTask | Where-Object {$_.TaskName -like $taskName})
    {
        Unregister-ScheduledTask $taskName -Confirm:$false
    }

	Register-ScheduledTask -Action $action -Trigger $trigger -Settings $settings -Principal $principal -TaskName $taskName -Description "Reconnects network drives at login."

}

# Disable Reconnecting Network Drives on Login
Function DisableReconnectNetworkDrivesOnLogin {
	
	Unregister-ScheduledTask -TaskName "Reconnect Network Drives" -Confirm:$false
    Remove-Item -Path "C:\Scripts\MapDrives.ps1"
	
}