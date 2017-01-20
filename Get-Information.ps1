#Adding libraries
Add-Type -Path "C:\Test\Newtonsoft.Json.dll"
Add-Type -Path "C:\Test\Octopus.Client.dll"
Add-Type -Path "C:\Test\Octopus.Platform.dll"
 
#Connection variables
#$apikey = "API-CUOHLLEPUAQA8NDCBPKNMNJS2I"
#$OctopusURI = "http://bsas-web-01.cloudapp.net/"
 
#Creating a connection
$endpoint = new-object Octopus.Client.OctopusServerEndpoint $OctopusURI,$apikey
$repository = new-object Octopus.Client.OctopusRepository $endpoint

#Getting all the users on this Octopus instance
$repository.Users.Findall()
$repository.DeploymentProcesses.FindAll()
$repository.Deployments.FindAll()
$repository.Environments.FindAll()
$repository.Machines.FindAll()
$repository.ProjectGroups.FindAll()
$repository.Projects.FindAll()
$repository.Releases.FindAll()

$machines = $repository.machines.FindAll()
$machines | Where-Object {$_.IsDisabled -eq $false} | Select Name,Uri

$machines = $repository.machines.FindAll()
$machines | Where-Object {$_.IsDisabled -eq $TRUE} | Select Name,Uri

# 1)Getting one machine using FindByName
$repository.machines.FindByName('BSAS-DC-01.cloudapp.net')
 
# 2.1)Getting all the machines into the $Machines variable
$machines = $repository.machines.FindAll()
 
# 2.2)Using Powershell to filter by property value. In this case by name
$machines | ?{$_.name -eq 'BSAS-DC-01.cloudapp.net'}

$machines = $repository.machines.FindAll()
$machines | ?{$_.name -like "BSAS*"]

<#
.Synopsis
Gets Octopus tentacles from an Octopus instance
.DESCRIPTION
Long description
.EXAMPLE
Get-Tentacle -name "WebServer01"
.EXAMPLE
Get-Tentacle -name "Web*"
.EXAMPLE
Get-Tentacle -name "Web*","DB*"
.EXAMPLE
Get-Tentacle -name "Web*" -Status Online
#>
 
Function Get-Tentacle
{
[CmdletBinding()]
Param
(
# Name of the tentacles.
[string[]]$Name = "*",
 
# Status of the tentacle. Only accepts values 'Online' and 'Offline'
[validateset('Online','Offline')]
[string]$Status
)
 
Begin
{
 
#Adding libraries
Add-Type -Path "C:\Test\Newtonsoft.Json.dll"
Add-Type -Path "C:\Test\Octopus.Client.dll"
Add-Type -Path "C:\Test\Octopus.Platform.dll"
 
#Connection variables
$apikey = 'API-CUOHLLEPUAQA8NDCBPKNMNJS2I'
$OctopusURI = 'http://bsas-web-01.cloudapp.net'
 
#Creating a connection
$endpoint = new-object Octopus.Client.OctopusServerEndpoint $OctopusURI,$apikey
$repository = new-object Octopus.Client.OctopusRepository $endpoint
 
#Getting all the machines. Not the sharpest solution, but way more practical for filtering.
$machines = $repository.machines.FindAll()
 
$output = @()
 
}
 
Process
{
 
foreach ($n in $name){
 
if($Status){
$output = $machines | ?{$_.name -like $name -and $_.status -eq $Status}
}
 
else{
 
$output += $machines | ?{$_.name -like $n}
}
}
}
End{
return $output
}
}