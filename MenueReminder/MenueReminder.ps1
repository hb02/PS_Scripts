cls
#Declare Variables
$url = "ENTER-Website"
[String[]]$ToRecipient = "toRecipient@test.com"
[String[]]$BCCRecipient = "recipient1@test.com; recipient2@test.com"


# // create a request
	[Net.HttpWebRequest] $req = [Net.WebRequest]::create($url)
	$req.Method = "GET"
	$req.Timeout = 600

	# // Set if you need a username/password to access the resource
	#$req.Credentials = New-Object Net.NetworkCredential("username", "password");

	[Net.HttpWebResponse] $result = $req.GetResponse()
	[IO.Stream] $stream = $result.GetResponseStream()
	[IO.StreamReader] $reader = New-Object IO.StreamReader($stream)
	[string] $output = $reader.readToEnd()
	$stream.flush()
	$stream.close()

	#// return the text of the web page and modify it
	#//Modifiy OutPut
	$output -like "BLAHA"
	$output = $output -replace "BLAHA", "BLUBB"
	$FullSite = $Output
	#Write-Host $output

#//Creating Outlook Element - Codebased by https://github.com/MrPowerScripts/PowerScripts/tree/master/Outlook
	$OL = New-Object -ComObject outlook.application
	Start-Sleep 2
	
	#Create Item
	$mItem = $OL.CreateItem("olMailItem")
	$mItem.To = $ToRecipient
	$mItem.bcc = $BCCRecipient
	$mItem.Subject = "My Awsome Subject"
	$mItem.HTMLBody = $FullSite
	#Enable if you want to display you Mail
	#$mItem.Display()

	#Sending e-mail via outlook
	$mItem.Send()
