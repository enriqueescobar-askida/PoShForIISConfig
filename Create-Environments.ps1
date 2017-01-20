#Adding libraries
Add-Type -Path "C:\Test\Newtonsoft.Json.dll"
Add-Type -Path "C:\Test\Octopus.Client.dll"
Add-Type -Path "C:\Test\Octopus.Platform.dll"
 
#Connection variables
$apikey = "API-CUOHLLEPUAQA8NDCBPKNMNJS2I"
$OctopusURI = "http://bsas-web-01.cloudapp.net/"
 
#Creating a connection
$endpoint = new-object Octopus.Client.OctopusServerEndpoint $OctopusURI,$apikey
$repository = new-object Octopus.Client.OctopusRepository $endpoint

$Environments = $Repository.environments.FindAll()
$Environments

#Creating Staging Environment
$Properties = @{Name="Staging";Description="Such an awesome Staging environment"}
$envObj = New-Object Octopus.Client.Model.EnvironmentResource -Property $Properties
$repository.Environments.Create($envObj)
 
#Creating Production Environment
$Properties = @{Name="Production";Description="The most stable environment you'll ever see"}
$envObj = New-Object Octopus.Client.Model.EnvironmentResource -Property $Properties
$repository.Environments.Create($envObj)

# 1) Get the Environment Object
$envObj = $repository.Environments.FindByName("dev")
 
# 2)modify the "name" property of the $envObj object
 
$envObj.Name = "Development"
 
# 3) modify the "Description" property of the $envObj object
$envObj.Description = "This is the Development environment"
 
# 4) Save the changes made to the environment
$repository.Environments.Modify($envObj)

$EnvName = ("Staging","Production")
 
Foreach ($e in $envName){
#using FindByName to check if the env exists
If ($repository.Environments.FindByName($e)){
  Write-Output "The following environment already exists: $e"
}
 
#If FindByName doesn't return a result we go ahead and create the environment.
else{
  $Properties = @{Name=$e;Description="Amazing description"}
  $envObj = New-Object Octopus.Client.Model.EnvironmentResource -Property $Properties
  $repository.Environments.Create($envObj)
}
 
}