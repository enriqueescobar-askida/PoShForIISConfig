Import-Module WebAdministration;
#look for Axon-ID AppPool
$iisAppPoolName="Axon-ID_AppPool";
$iisAppPoolDotNetVersion="v4.0";
$iisAppPoolPipeLineMode="Integrated";
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
