# This script will create a new release for a project
## Octopus Server-URL
$OctopusURL = "http://build-dev-hs.axon-id.loc:8080"
## Octopus Server-APIKey-Jenkins
$OctopusAPIKey = "API-QMSKCY7XZLXR7TTRUS7EQ7EKII"
## HTTP Request Header
$header = @{ "X-Octopus-ApiKey" = $OctopusAPIKey }
## Environment
$environmentName = "EnvHydroSoftIntegration"
$environmentID = "Environments-6"
$environJson = Invoke-WebRequest -Uri "$OctopusURL/api/Environments/all" -Headers $header| ConvertFrom-Json
$environJson = $environJson | ?{$_.name -eq $environmentName}
## Project
$projectName = "ProjectHydroSoftBuildAPI"
$projectJson = Invoke-WebRequest -Uri "$OctopusURL/api/projects/$projectName" -Headers $header| ConvertFrom-Json
## Project template 
$projectTmpl = Invoke-WebRequest -Uri "$OctopusURL/api/deploymentprocesses/deploymentprocess-$($projectJson.id)/template" -Headers $header | ConvertFrom-Json 
## HTTP Request Body
$body = @{
  ProjectId = "Projects-3"
  ChannelId = "Channels-5"
  Version = "0.0.0.0"
  ReleaseNotes = "the release notes " + $projectName
}
## try-catch
try
{
  ## Release
  $octoReleURL=$OctopusURL+"/api/releases?ignoreChannelRules=false"
  $projReleAnsw = Invoke-WebRequest $octoReleURL -Method POST -Headers $header -Body ($body | ConvertTo-Json)
  ## Deployment
  $deployBody = @{ 
                ReleaseID = ($projReleAnsw.Content|ConvertFrom-Json).Id
                EnvironmentID = $environJson.Id
  } | ConvertTo-Json
  $deployAnsw = Invoke-WebRequest -Uri $OctopusURL/api/deployments -Method Post -Headers $header -Body $deployBody
}
catch
{
  $Result = $_.Exception.Response.GetResponseStream()
  $Reader = New-Object System.IO.StreamReader($result)
  $ResponseBody = $Reader.ReadToEnd();
  $Response = $ResponseBody | ConvertFrom-Json
  $Response.Errors
}