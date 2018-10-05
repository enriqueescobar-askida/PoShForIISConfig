Import-Module WebAdministration;
 Sleep 2;
#look for Axon-ID AppPool
$iisAppPoolName="Axon-ID_AppPool";
$iisAppPoolDotNetVersion="v4.0";
$iisAppPoolPipeLineMode="Integrated";
if($iisAppPoolName -eq $null) { throw "Empty AppPool name, Argument two is missing" }
#backing up
$backupName = "$(Get-date -format "yyyyMMdd-HHmmss")-$iisAppPoolName"
"Backing up IIS config to backup named $backupName"
$backup = Backup-WebConfiguration $backupName
#navigate to the app pools root
cd IIS:\AppPools\ ;
ls ;
Test-Path $iisAppPoolName -pathType Container ;
#check if the app pool exists
if (!(Test-Path $iisAppPoolName -pathType Container))
{
    #create the app pool
    echo "$iisAppPoolName $iisAppPoolDotNetVersion $iisAppPoolPipeLineMode DOES NOT EXIST!" ;
    $iisWAP=New-WebAppPool -Verbose -Name $iisAppPoolName;
    $iisWAP.managedPipeLineMode = "$iisAppPoolPipeLineMode";
    Set-ItemProperty "IIS:\AppPools\$iisAppPoolName" managedRuntimeVersion "$iisAppPoolDotNetVersion";
    $iisWAP.managedPipelineMode;
    $iisWAP.managedRuntimeVersion;
    $iisWAP.managedRuntimeLoader;
}
else
{
    echo "$iisAppPoolName $iisAppPoolDotNetVersion $iisAppPoolPipeLineMode EXISTS!" ;
    $iisWAP=Get-Item "IIS:\AppPools\$iisAppPoolName";
    $iisWAP.managedPipeLineMode = "$iisAppPoolPipeLineMode";
    Set-ItemProperty "IIS:\AppPools\$iisAppPoolName" managedRuntimeVersion "$iisAppPoolDotNetVersion";
    $iisWAP.managedPipelineMode;
    $iisWAP.managedRuntimeVersion;
    $iisWAP.managedRuntimeLoader;
}
# Stop the AppPool if it exists and is running, dont error if it doesn't
if (Test-Path "$iisAppPoolName") {
    if ((Get-WebAppPoolState -Name $iisAppPoolName).Value -ne "Stopped") {
        Stop-WebAppPool -Name $iisAppPoolName
        echo "Stopped AppPool '$iisAppPoolName'"
    } else {
        echo "WARNING: AppPool '$iisAppPoolName' was already stopped. Have you already run this?"
    }
} else {
    echo "WARNING: Could not find an AppPool called '$iisAppPoolName' to stop. Assuming this is a new install"
}
