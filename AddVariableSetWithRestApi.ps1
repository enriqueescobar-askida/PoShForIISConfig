$baseUri = "http://localhost" #update this
$apiKey = "API-xxxxxxxxxxxxxxxxxxxxxxxxx" #update this
$headers = @{"X-Octopus-ApiKey" = $apiKey}

function Create-OctopusResource([string]$uri, $resource)
{
    return Invoke-RestMethod `
        -Method Post `
        -Uri ($baseUri + $uri) `
        -Body ($resource | ConvertTo-Json -Depth 5) `
        -Headers $headers
}

function Modify-OctopusResource($uri, $resource)
{
    return Invoke-RestMethod `
        -Method Put `
        -Uri ($baseUri + $uri) `
        -Body ($resource | ConvertTo-Json -Depth 5) `
        -Headers $headers
}

function Get-OctopusResource($uri, [string]$id)
{
    return Invoke-RestMethod `
        -Method Get `
        -Uri ($baseUri + $uri + "/$id") `
        -Headers $headers
}

function Get-OctopusResourceUri([string]$uriTemplate)
{
    return $uriTemplate.Substring(0, $uriTemplate.IndexOf("{"))
}

$links = (Invoke-RestMethod -Uri "$baseUri/api" -Method Get -Headers $headers).Links

#create the new library variable set
$libraryVariableSet = @{}
$libraryVariableSet.Name = "PoSh Test Library Variable Set"

$resourceUri = Get-OctopusResourceUri $links.LibraryVariables
$libraryVariableSet = Create-OctopusResource $resourceUri $libraryVariableSet
$libraryVariableSet

#get the underlying variable set that was created for the library variable set
$resourceUri = Get-OctopusResourceUri $links.Variables
$variableSet = Get-OctopusResource $resourceUri $libraryVariableSet.VariableSetId

#If you want to scope the new variables you can do that by using this object
$scope = New-Object PSObject -Property @{
    Environment = @('Environments-1') #This will have to be updated to match your environment Id
    Machine = @('machines-1') #This will have to be updated to match your machine Id
    Role = @('app-server') #This will have to be updated to match your role names
}

#examples for both non-sensitive and sensitive variables below, use which ever suits your needs
$newVariable = @{
    Name = "ApiTest"
    Value = "Test"
    Scope = $scope #if you don't want any scope, set this to $null
    IsSensitive = $false
    IsEditable = $true 
    Prompt = $null
}

#Sensitive variable
$newSecretVariable = @{
    Name = "SecretApiTest"
    Value = "T0p`$ecr3t"
    Scope = $scope #if you don't want any scope, set this to $null
    IsSensitive = $true
    IsEditable = $false
    Prompt = $null
}

#add the variable(s) to the variable set
$variableSet.Variables += New-Object PSObject -Property $newVariable
$variableSet.Variables += New-Object PSObject -Property $newSecretVariable

#update the variable set
$variableSet = Modify-OctopusResource $variableSet.Links.Self $variableSet
$variableSet