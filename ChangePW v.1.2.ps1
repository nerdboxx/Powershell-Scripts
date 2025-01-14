Import-Module ActiveDirectory

echo ""
echo "Loading Domainlist..."
echo ""

$domainlist = @() #Creates the empty array 
$domainlist = $domainlist + (Get-ADDomain).Forest #Adds the current AD Forest to the array
$domainlist = $domainlist + (Get-ADTrust -Server $domainlist[0] -Filter *).Name #Adds the Forests of the Trustlist into the array

for($x=0; $x -lt $domainlist.count; $x++) #Runs through the list to collect all AD Forests
	{
		$domains = $domains + (Get-ADTrust -Server $domainlist[$x] -Filter *).Name
	}

$domains = $domains | Sort | Get-Unique #Sorts the list alphabetically and removes all the duplicates

do {

do{
for($i=0; $i -lt $domains.Count;$i++){ #Shows the lists of domains in the color yellow
	Write-Host "$($i + 1): $($domains[$i])" -ForegroundColor yellow
}

do{
	try{
		$domainChoice = Read-Host "Please select a domain"
		echo ""
		$intdomainChoice = [int]$domainChoice #String to integer conversion
		-ErrorAction Stop
	}catch {
		if($intdomainChoice -gt $domains.count){
			Write-Host "Number to high. Insert a correct number!" -ForegroundColor Red
		}
		elseif($intdomainChoice -isnot [int]){
			Write-Host "Please insert a number" -ForegroundColor Red
		}
		echo ""
	}
	
} while($intdomainChoice -isnot [int] -or $intdomainChoice -gt $domains.count)


}while ($intdomainChoice -gt $domains.Count -and $domainChoice -is [int]) #Checks if the input is in the

$selectedDomain = $domains[$intdomainChoice-1] #To correct the user's choice

Write-Host "Your domain choice: $selectedDomain" -ForegroundColor green

$user = $env:UserName
$splituser = $user.split("") #Choose the split character which suits your company the best (e.g. ".")
$UserName = $splituser[0] #Write only the left part of the split into the variable


$aduser = (Get-ADUser -Server $selectedDomain -filter "samaccountname -like '$UserName*'").samAccountName #Searches for samAccountNames in the chosen domain
$splitaduser = $aduser.split("")
echo ""

do{

for($x=0; $x -lt $splitaduser.count; $x++){
	Write-Host "$($x + 1): $($splitaduser[$x])" -ForegroundColor yellow
}

do{
	try{
		echo ""
		$userChoice = Read-Host "Please select a user"
		echo ""
		$intuserChoice = [int]$userChoice
		-ErrorAction stop
	}catch {
		if($intuserChoice -gt $splitaduser.count){
			Write-Host "Number to high. Insert a correct number!" -ForegroundColor Red
		}
		elseif($intuserChoice -isnot [int]){
			Write-Host "Please insert a number" -ForegroundColor Red
		}
	}
	


}while($intuserChoice -isnot [int] -or $intuserChoice -gt $splitaduser.count)


}while ($intuserChoice -gt $splitaduser.Count)

$selectedUser = $splitaduser[$intuserChoice-1]

Set-ADAccountPassword -Identity $selectedUser -Server $selectedDomain #Initializes the password change process via Set-ADAccountPassword


$another = Read-Host "Do you want to change another password? (yes/no)"
}while ($another -like "y*") #A bit sloppy but does the trick. Can also be something more specific (e.g "-eq "yes" -and -eq "y"")
