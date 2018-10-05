Import-Module WebAdministration;
Sleep 2;
#look for "Axon-ID_Site"
$iisAppSiteName="Axon-ID_Site" ;
#look for Axon-ID AppPool
$iisAppPoolName="Axon-ID_AppPool";
echo "USE $iisAppPoolName & CREATE IIS\$iisAppSiteName";
if($iisAppPoolName -eq $null)    { throw "Empty site name, Argument one is missing" }
#navigate to the sites root
cd IIS:\Sites\ ;
ls ;
echo "TEST IIS\$iisAppSiteName";
Test-Path "$iisAppSiteName" -pathType Container ;
echo $LASTEXITCODE;
# input
#$ENV_AXONID="Axon-ID";
#$ENV_SITES="Sites";
#$ENV_NET="NET";
$envPath="$env:DataDrive\$ENV_AXONID\$ENV_SITES\$env:AXONID_ENVIRONMENT\$ENV_NET";
# Check if the folder exist if not create it 
If (!(Test-Path "$envPath")) {
    Write-Host "Directory <$envPath> not exists! CREATE";
    New-Item -Path "$envPath" -ItemType Directory;
    echo $LASTEXITCODE;
}
else {
    Write-Host "Directory <$envPath> already exists! LIST";
    ls "$envPath";
    echo $LASTEXITCODE;
}
echo $LASTEXITCODE;
#check if the app site exists
if (!(Test-Path "$iisAppSiteName" -pathType Container))
{
    echo "IIS:\Sites\$iisAppSiteName DOES NOT EXIST!" ;
    echo "iisAppSite=New-WebSite -Name $iisAppSiteName -ApplicationPool $iisAppPoolName -Force -Verbose -PhysicalPath $envPath";
    echo "Copy binding from IS:\Sites\Default Web Site";
    (Get-Item "IIS:\Sites\Default Web Site").bindings;
    $iisAppSite=New-WebSite -Name "$iisAppSiteName" -ApplicationPool "$iisAppPoolName" -Force -Verbose -PhysicalPath "$envPath" ;
    $iisAppSite.bindings = (Get-Item "IIS:\Sites\Default Web Site").bindings;
    #"Create a website $siteName from directory $envPath on port $port"
    #$website = New-Website -Name $iisAppSiteName -PhysicalPath $envPath -ApplicationPool $iisAppPoolName -Port $port
    if ((Get-WebsiteState -Name $iisAppSiteName).Value -ne "Started") {
        throw "Website $iisAppSiteName was created but did not start automatically. Probably something is broken!"
    }
    "Website created and started successfully"
}
else
{
    echo "IIS:\Sites\$iisAppSiteName EXISTS!" ;
    $iisAppSite=Get-Item "IIS:\Sites\$iisAppSiteName";
    $iisAppSite.Attributes;
}
# Stop the website if it exists and is running, dont error if it doesn't
if (Test-Path "IIS:\Sites\$iisAppSiteName") {
    if ((Get-WebsiteState -Name $iisAppSiteName).Value -ne "Stopped") {
        Stop-WebSite -Name $iisAppSiteName
        echo "Stopped website '$iisAppSiteName'"
    } else {
        echo "WARNING: Site '$iisAppSiteName' was already stopped. Have you already run this?"
    }
} else {
    echo "WARNING: Could not find a site called '$iisAppSiteName' to stop. Assuming this is a new install"
}
