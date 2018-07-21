Import-Module dbatools

$path = Split-Path $MyInvocation.MyCommand.Path

$config = Import-PowerShellDataFile -Path "$path\Config.psd1"

Write-Output ("Running with Instance: {0}" -f $config.Instance2016 )
Write-Output ("Running with PrimaryDatabase: {0}" -f $config.PrimaryDatabase )
Write-Output ("Running with SecondaryDatabase: {0}" -f $config.SecondaryDatabase )
Write-Output ("Running with BackupFile: {0}" -f $config.BackupFile )

## get first database up and running
    Remove-DbaDatabase -SqlInstance $config.Instance2016 -Database $config.PrimaryDatabase -Confirm:$false
    Restore-DbaDatabase -SqlInstance $config.Instance2016 -Path $config.BackupFile -DatabaseName $Config.PrimaryDatabase -useDestinationDefaultDirectories

    ## Run Some Activity
    Write-Output ("Running workload from {0}" -f $config.WorkloadFile)
    $null = Invoke-Sqlcmd2 -ServerInstance $config.Instance2016 -Database $config.PrimaryDatabase -InputFile $config.WorkloadFile -ParseGO

## setup second db
    Remove-DbaDatabase -SqlInstance $config.Instance2016 -Database $config.SecondaryDatabase -Confirm:$false
    Restore-DbaDatabase -SqlInstance $config.Instance2016 -Path $config.BackupFile -DatabaseName $Config.SecondaryDatabase -useDestinationDefaultDirectories -DestinationFileSuffix '_2'



Write-Output '-----'
Write-Output 'Go filter SSMS for sales schema'