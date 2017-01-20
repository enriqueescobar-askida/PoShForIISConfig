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
 
#First example of Querying Octopus from Powershell
#Getting all the users on this Octopus instance
$repository.Users.FindAll()