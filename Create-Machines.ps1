#Adding libraries
Add-Type -Path 'C:\OctopusLibraries\Newtonsoft.Json.dll'
Add-Type -Path 'C:\OctopusLibraries\Octopus.Client.dll'
Add-Type -Path 'C:\OctopusLibraries\Octopus.Platform.dll'

#Setting variables
$apikey = 'API-QBGAAZEUMSUKJVSADFSDFA5Y2FLC'
$OctopusURI = 'http://OctopusServer/octopus/api/'

#Creating a connection
$endpoint = new-object Octopus.Client.OctopusServerEndpoint $OctopusURI,$apikey
$repository = new-object Octopus.Client.OctopusRepository $endpoint

#Set the machine properties
$Properties = @{Name="MachineName";Thumbprint="1AE1B6F81A30C2C5771AC5B234S4FE975";EnvironmentIds="Environments-65";Roles="web-server";URI="https://MyServer:10933/";CommunicationStyle="TentaclePassive"}

$envObj = New-Object Octopus.Client.Model.MachineResource -Property $Properties
$repository.Machines.Create($envObj)
