# IIS check Section
Import-Module WebAdministration;
Sleep 2;
cd IIS: ;
Get-ChildItem 'IIS:\Sites' ;
Get-Item 'IIS:\Sites\Default Web Site\' ;
(Get-ItemProperty 'IIS:\Sites\Default Web Site\' -Name bindings).Collection ;
(Get-ItemProperty 'IIS:\Sites\Default Web Site\' -Name State).Value ;
#Set-ItemProperty 'IIS:\Sites\Default Web Site\' -Name State -value 'abscent' ;
Get-ChildItem 'IIS:\AppPools' ;
(Get-ItemProperty 'IIS:\AppPools\DefaultAppPool\' -Name processModel).startupTimeLimit ;
# PFX certificate section
$iisPfxCertificate="U:\wildcard_logibec_com_2020.pfx";
$iisPfxPassword="logibec";
Import-PfxCertificate -FilePath "$iisPfxCertificate" -CertStoreLocation Cert:\LocalMachine\My -Password "$iisPfxPassword";
$iisPfxThumbprint=(Get-ChildItem cert:\LocalMachine\My | Where-Object { $_.Subject -like "*$iisPfxPassword*" } | Select-Object -First 1).Thumbprint;
# App Path Section
$iisAppRootPath="C:\wwwroot";
If(!(test-path $iisAppRootPath))
{
    New-Item -ItemType Directory -Force -Path $iisAppRootPath;
}
Import-Module ActiveDirectory;
## Rights
$readOnly = [System.Security.AccessControl.FileSystemRights]::ReadAndExecute;
$readWrite = [System.Security.AccessControl.FileSystemRights]::Modify;
$fullControl = [System.Security.AccessControl.FileSystemRights]::FullControl;
## Inheritance
$inheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit";
## Propagation
$propagationFlag = [System.Security.AccessControl.PropagationFlags]::None;
## User
##$userRW = New-Object System.Security.Principal.NTAccount($groupNameRW)
##$userR = New-Object System.Security.Principal.NTAccount($groupNameR)
## Type
$type = [System.Security.AccessControl.AccessControlType]::Allow;
$accessControlEntryFC = New-Object System.Security.AccessControl.FileSystemAccessRule @('IIS_IUSRS', $fullControl, $inheritanceFlag, $propagationFlag, $type);
$accessControlEntryRW = New-Object System.Security.AccessControl.FileSystemAccessRule @("$env:USERNAME", $readWrite, $inheritanceFlag, $propagationFlag, $type);
$accessControlEntryR = New-Object System.Security.AccessControl.FileSystemAccessRule @("Domain Users", $readOnly, $inheritanceFlag, $propagationFlag, $type);
$objACL = Get-Acl $iisAppRootPath;
$objACL.AddAccessRule($accessControlEntryFC);
Set-Acl $iisAppRootPath $objACL;
###cmd:icacls "$iisAppRootPath" /grant "IIS_IUSRS":(OI)(CI)F /T;
#$HomeFolders = Get-ChildItem C:Homefolders -Directory
#foreach ($HomeFolder in $HomeFolders) {
#    $Path = $HomeFolder.FullName
#    $Acl = (Get-Item $Path).GetAccessControl('Access')
#    $Username = $HomeFolder.Name
#    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Modify', 'ContainerInherit,ObjectInherit', 'None', 'Allow')
#    $Acl.SetAccessRule($Ar)
#    Set-Acl -path $Path -AclObject $Acl
#}
#$Ar = New-Object
#System.Security.AccessControl.FileSystemAccessRule($Username, 'Modify', 'ContainerInherit,ObjectInherit', 'None', 'Allow')
#$acl = Get-Acl $iisAppRootPath 
#$colRights = [System.Security.AccessControl.FileSystemRights]"Read,Modify,ExecuteFile,ListDirectory" 
#$permission = "IIS_IUSRS",$colRights,"ContainerInherit,ObjectInherit”,”None”,”Allow” 
#$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission  
#$acl.AddAccessRule($accessRule) 
#$acl.SetAccessRule($accessRule)  
#$acl | Set-Acl $iisAppRootPath
# App Pool Section
## Stop default AppPools
Stop-WebAppPool -Name "DefaultAppPool" ;
Stop-WebAppPool -Name ".NET v4.5 Classic" ;
# App Site Section
## Stop default AppSite
Stop-WebSite -Name "Default Web Site";
## Create API IIS AppPool
$iisApplication="bi-platform-core";
$iisAppPoolName=$iisApplication+"_AppPool";
$iisAppPoolDotNetVersion="v4.0";
$iisAppPoolPipeLineMode="Integrated";
if($iisAppPoolName -eq $null) { throw "Empty AppPool name, Argument two is missing" } ;
### Back up WebConfiguration
$backupName = "$(Get-date -format "yyyyMMdd-HHmmss")-$iisAppPoolName" ;
"Backing up IIS config to backup named $backupName" ;
$backup = Backup-WebConfiguration $backupName ;
### Test API IIS AppPool
Test-Path "IIS:\$iisAppPoolName" -pathType Container ;
### Create API IIS AppPool
echo "$iisAppPoolName $iisAppPoolDotNetVersion $iisAppPoolPipeLineMode DOES NOT EXIST!" ;
echo "Create an appPool named $iisAppPoolName under v4.0 runtime, default (Integrated) pipeline" ;
$iisWAP=New-WebAppPool -Verbose -Name $iisAppPoolName;
$iisWAP.managedPipeLineMode = "$iisAppPoolPipeLineMode";
$iisWAP="True";
Set-ItemProperty "IIS:\AppPools\$iisAppPoolName" managedRuntimeVersion "$iisAppPoolDotNetVersion";
$iisWAP.managedPipelineMode;
$iisWAP.managedRuntimeVersion;
$iisWAP.managedRuntimeLoader;
### Verify API IIS AppPool
if ((Get-WebAppPoolState -Name $iisAppPoolName).Value -ne "Started") {
	throw "App pool $iisAppPoolName was created but did not start automatically. Probably something is broken!" ;
}
echo "Website AppPool created and started successfully" ;
## Create API IIS AppSite
$iisAppSiteName=$iisApplication;
echo "USE $iisAppPoolName & CREATE IIS\$iisAppSiteName";
if($iisAppPoolName -eq $null)    { throw "Empty site name, Argument one is missing" }
echo "TEST IIS\$iisAppSiteName";
Test-Path "$iisAppSiteName" -pathType Container ;
$iisAppSitePath="$iisAppRootPath\$iisApplication\webapp\_PublishedWebSites\BIWebPortal.WebApp";
### Check API IIS AppSite if the folder exist if not create it 
If (!(Test-Path "$iisAppSitePath")) {
    Write-Host "Directory <$iisAppSitePath> not exists! CREATE";
    New-Item -Path "$iisAppSitePath" -ItemType Directory;
    echo $LASTEXITCODE;
}
else {
    Write-Host "Directory <$iisAppSitePath> already exists! LIST";
    ls "$iisAppSitePath";
    echo $LASTEXITCODE;
}
### Check API IIS AppSite if the app site exists
if (!(Test-Path "$iisAppSiteName" -pathType Container))
{
    echo "IIS:\Sites\$iisAppSiteName DOES NOT EXIST!" ;
    echo "iisAppSite=New-WebSite -Name $iisAppSiteName -ApplicationPool $iisAppPoolName -Force -Verbose -PhysicalPath $iisAppSitePath";
    echo "Copy binding from IIS:\Sites\Default Web Site";
    (Get-Item "IIS:\Sites\Default Web Site").bindings;
    $iisAppURL=$iisApplication+"-local.logibec.com";
    $iisAppBind=@{protocol="https";bindingInformation="*:443:" + $iisAppURL};
    New-Item IIS:\Sites\$iisAppSiteName -Bindings $iisAppBind -PhysicalPath "$iisAppSitePath";
    Set-ItemProperty IIS:\Sites\$iisAppSiteName -Name ApplicationPool -Value $iisAppPoolName;
    #$iisAppSite=New-WebSite -Name "$iisAppSiteName" -ApplicationPool "$iisAppPoolName" -Force -Verbose -PhysicalPath "$iisAppSitePath" ;
    #$iisAppSite.bindings = (Get-Item "IIS:\Sites\Default Web Site").bindings;
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
### Stop API IIS AppSite if it exists and is running, dont error if it doesn't
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
## Create APP IIS AppPool
$iisApplication="bi-platform";
$iisAppPoolName=$iisApplication+"_AppPool";
$iisAppPoolDotNetVersion="v4.0";
$iisAppPoolPipeLineMode="Integrated";
if($iisAppPoolName -eq $null) { throw "Empty AppPool name, Argument two is missing" } ;
### Back up WebConfiguration
$backupName = "$(Get-date -format "yyyyMMdd-HHmmss")-$iisAppPoolName" ;
"Backing up IIS config to backup named $backupName" ;
$backup = Backup-WebConfiguration $backupName ;
### Test APP IIS AppPool
Test-Path "IIS:\$iisAppPoolName" -pathType Container ;
### Create APP IIS AppPool
echo "$iisAppPoolName $iisAppPoolDotNetVersion $iisAppPoolPipeLineMode DOES NOT EXIST!" ;
echo "Create an appPool named $iisAppPoolName under v4.0 runtime, default (Integrated) pipeline" ;
$iisWAP=New-WebAppPool -Verbose -Name $iisAppPoolName;
$iisWAP.managedPipeLineMode = "$iisAppPoolPipeLineMode";
$iisWAP="True";
Set-ItemProperty "IIS:\AppPools\$iisAppPoolName" managedRuntimeVersion "$iisAppPoolDotNetVersion";
$iisWAP.managedPipelineMode;
$iisWAP.managedRuntimeVersion;
$iisWAP.managedRuntimeLoader;
### Verify APP IIS AppPool
if ((Get-WebAppPoolState -Name $iisAppPoolName).Value -ne "Started") {
	throw "App pool $iisAppPoolName was created but did not start automatically. Probably something is broken!" ;
}
echo "Website AppPool created and started successfully" ;
## Create APP IIS AppSite
$iisAppSiteName=$iisApplication;
echo "USE $iisAppPoolName & CREATE IIS\$iisAppSiteName";
if($iisAppPoolName -eq $null)    { throw "Empty site name, Argument one is missing" }
echo "TEST IIS\$iisAppSiteName";
Test-Path "$iisAppSiteName" -pathType Container ;
$iisAppSitePath="$iisAppRootPath\$iisApplication\www";
### Check APP IIS AppSite if the folder exist if not create it 
If (!(Test-Path "$iisAppSitePath")) {
    Write-Host "Directory <$iisAppSitePath> not exists! CREATE";
    New-Item -Path "$iisAppSitePath" -ItemType Directory;
    echo $LASTEXITCODE;
}
else {
    Write-Host "Directory <$iisAppSitePath> already exists! LIST";
    ls "$iisAppSitePath";
    echo $LASTEXITCODE;
}
### Check APP IIS AppSite if the app site exists
if (!(Test-Path "$iisAppSiteName" -pathType Container))
{
    echo "IIS:\Sites\$iisAppSiteName DOES NOT EXIST!" ;
    echo "iisAppSite=New-WebSite -Name $iisAppSiteName -ApplicationPool $iisAppPoolName -Force -Verbose -PhysicalPath $iisAppSitePath";
    echo "Copy binding from IS:\Sites\Default Web Site";
    (Get-Item "IIS:\Sites\Default Web Site").bindings;
    $iisAppURL=$iisApplication+"-local.logibec.com";
    $iisAppBind=@{protocol="https";bindingInformation="*:443:" + $iisAppURL};
    New-Item IIS:\Sites\$iisAppSiteName -Bindings $iisAppBind -PhysicalPath "$iisAppSitePath";
    Set-ItemProperty IIS:\Sites\$iisAppSiteName -Name ApplicationPool -Value $iisAppPoolName;
    #$iisAppSite=New-WebSite -Name "$iisAppSiteName" -ApplicationPool "$iisAppPoolName" -Force -Verbose -PhysicalPath "$iisAppSitePath" ;
    #$iisAppSite.bindings = (Get-Item "IIS:\Sites\Default Web Site").bindings;
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
### Stop APP IIS AppSite if it exists and is running, dont error if it doesn't
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
