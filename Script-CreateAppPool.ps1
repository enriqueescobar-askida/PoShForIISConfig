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

try{
    ## delete the website & app pool if needed
    #if (Test-Path "IIS:\Sites\$siteName") {
    #    "Removing existing website $siteName"
    #    Remove-Website -Name $siteName
    #}
    ##remove anything already using that port
    #foreach($site in Get-ChildItem IIS:\Sites) {
    #    if( $site.Bindings.Collection.bindingInformation -eq ("*:" + $port + ":")){
    #        "Warning: Found an existing site '$($site.Name)' already using port $port. Removing it..."
    #        Remove-Website -Name  $site.Name 
    #        "Website $($site.Name) removed"
    #    }
    #}
	#check if the app pool exists
	if (!(Test-Path $iisAppPoolName -pathType Container))
	{
		#create the app pool
		echo "$iisAppPoolName $iisAppPoolDotNetVersion $iisAppPoolPipeLineMode DOES NOT EXIST!" ;
		echo "Create an appPool named $iisAppPoolName under v4.0 runtime, default (Integrated) pipeline"
		$iisWAP=New-WebAppPool -Verbose -Name $iisAppPoolName;
		$iisWAP.managedPipeLineMode = "$iisAppPoolPipeLineMode";
		Set-ItemProperty "IIS:\AppPools\$iisAppPoolName" managedRuntimeVersion "$iisAppPoolDotNetVersion";
		#$iisWAP.managedRuntimeVersion = "v4.0"
		#$iisWAP.processModel.identityType = 2 #NetworkService
		#if ($user -ne $null -AND $password -ne $null) {
		#	"Setting AppPool to run as $user"
		#	$iisWAP.processmodel.identityType = 3
		#	$iisWAP.processmodel.username = $user
		#	$iisWAP.processmodel.password = $password
		#}		
		#$iisWAP | Set-Item
		$iisWAP.managedPipelineMode;
		$iisWAP.managedRuntimeVersion;
		$iisWAP.managedRuntimeLoader;
		if ((Get-WebAppPoolState -Name $iisAppPoolName).Value -ne "Started") {
			throw "App pool $iisAppPoolName was created but did not start automatically. Probably something is broken!"
		}
		"Website AppPool created and started successfully"
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
		#if (Test-Path "IIS:\AppPools\$iisAppPoolName") {
		#	"Removing existing AppPool $iisAppPoolName"
		#	Remove-WebAppPool -Name $iisAppPoolName
		#}
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
} catch {
    "Error detected, running command 'Restore-WebConfiguration $backupName' to restore the web server to its initial state. Please wait..."
    sleep 3 #allow backup to unlock files
    Restore-WebConfiguration $backupName
    "IIS Restore complete. Throwing original error."
    throw
}
