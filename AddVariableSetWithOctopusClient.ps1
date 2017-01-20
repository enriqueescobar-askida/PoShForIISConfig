
Add-Type -Path 'C:\Code\GitHub\OctopusDeploy\source\Octopus.Server\bin\Octopus.Client.dll'
Add-Type -Path 'C:\Code\GitHub\OctopusDeploy\source\Octopus.Server\bin\Octopus.Platform.dll'

$baseUri = "http://localhost" #update this
$apiKey = "API-xxxxxxxxxxxxxxxxxxxxxxxxx" #update this

$endpoint = New-Object Octopus.Client.OctopusServerEndpoint $baseUri, $apiKey
$repository = New-Object Octopus.Client.OctopusRepository $endpoint

$libraryVariableSet = New-Object Octopus.Client.Model.LibraryVariableSetResource
$libraryVariableSet.Name = "Client Test Library Variable Set"

$libraryVariableSet = $repository.LibraryVariableSets.Create($libraryVariableSet);
$libraryVariableSet

$newVariable = New-Object Octopus.Client.Model.VariableResource
$newVariable.Name = "ApiTest"
$newVariable.Value = "Test"
#if you want to scope your variable
$newVariable.Scope.Add([Octopus.Platform.Model.ScopeField]::Environment, (New-Object Octopus.Platform.Model.ScopeValue "Environments-1"))
$newVariable.Scope.Add([Octopus.Platform.Model.ScopeField]::Machine, (New-Object Octopus.Platform.Model.ScopeValue "machines-1"))
$newVariable.Scope.Add([Octopus.Platform.Model.ScopeField]::Role, (New-Object Octopus.Platform.Model.ScopeValue "app-server"))

$newSecretVariable = New-Object Octopus.Client.Model.VariableResource
$newSecretVariable.Name = "SecretApiTest"
$newSecretVariable.Value = "T0p`$ecr3t"
$newSecretVariable.IsSensitive = $true
$newSecretVariable.Scope.Add([Octopus.Platform.Model.ScopeField]::Environment, (New-Object Octopus.Platform.Model.ScopeValue "Environments-1"))
$newSecretVariable.Scope.Add([Octopus.Platform.Model.ScopeField]::Machine, (New-Object Octopus.Platform.Model.ScopeValue "machines-1"))
$newSecretVariable.Scope.Add([Octopus.Platform.Model.ScopeField]::Role, (New-Object Octopus.Platform.Model.ScopeValue "app-server"))

$variableSet = $repository.VariableSets.Get($libraryVariableSet.VariableSetId)
$variableSet

$variableSet.Variables.Add($newVariable)
$variableSet.Variables.Add($newSecretVariable)
$variableSet

$variableSet = $repository.VariableSets.Modify($variableSet)
$variableSet