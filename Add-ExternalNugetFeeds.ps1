#Adding libraries
Add-Type -Path C:\Test\Newtonsoft.Json.dll
Add-Type -Path C:\Test\Octopus.Client.dll
Add-Type -Path C:\Test\Octopus.Platform.dll
 
#Connection variables
$apikey = "API-CUOHLLEPUAQA8NDCBPKNMNJS2I"
$OctopusURI = "http://bsas-web-01.cloudapp.net/"
 
#Creating a connection
$endpoint = new-object Octopus.Client.OctopusServerEndpoint $OctopusURI,$apikey
$repository = new-object Octopus.Client.OctopusRepository $endpoint

$Properties = @{
FeedUri= "https://BSAS-Web-02.com/feed"
Name= "BSAS_Feed"
}

$FeedObj = New-Object Octopus.Client.Model.FeedResource -Property $Properties
$repository.Feeds.Create($FeedObj)

$FeedName = "BSAS_Feed"
$FeedURI = "https://BSAS-Web-02.com/feed"
 
If ($repository.Feeds.FindByName($FeedName)){
 write-output "Feed already exists: $feedname"
}
 
else{
 $Properties = @{
 FeedUri= $FeedURI
 Name= $FeedName
 }
 
 $FeedObj = New-Object Octopus.Client.Model.FeedResource -Property $Properties
 $repository.Feeds.Create($FeedObj)
}

# 1) Get Feed Object
$feedObj = $repository.Feeds.FindByName("BSAS_Feed")
 
# 2) Set the "name" property of the feed object
$feedObj.Name = "BSAS_Production_Feed"
 
# 3) Set the "FeedURI" property of the feed object
$feedObj.FeedUri = "https://BSAS-Web-02.com/Production/feed"
 
# 4) Save the changed made to the feed
$repository.Feeds.Modify($feedObj)