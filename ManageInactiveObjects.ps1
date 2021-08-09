# Predefine variables
$90Days = (get-date).adddays(-90)
$groupNotDisable = (Get-ADGroup 'Gr_NeverDisable').DistinguishedName 
$skipNeverDisableObjects = $True

$checkAll = $True
$checkUsers = $False
$checkComputers = $False
$checkGroups = $False

[string]$userBasePath = ([adsi]'').DistinguishedName
$userBasePathDefault = $True

[string]$computerBasePath = ([adsi]'').DistinguishedName
$computerBasePathDefault = $True

[string]$groupBasePath = ([adsi]'').DistinguishedName
$groupBasePathDefault = $True

for ( $i = 0; $i -lt $args.count; $i++ ) {
    if ($args[$i] -eq "/?"){
		echo 	""
		echo 	"Allowed parameters:"
		echo 	"/ii		/include-ignored		Show objects which are a member of 'Gr_NeverDisable'"
		echo 	"/su		/scope:users			Check users"
		echo 	"/sc		/scope:computers		Check computers"
		echo 	"/sg		/scope:groups			Check groups"
		echo 	"/b  [PATH]	/base [PATH]			Defines the search path for users AND computer"
		echo 	"/bu [PATH]	/base:users [PATH]		Defines the search path for users"
		echo 	"/bc [PATH]	/base:computers [PATH]		Defines the search path for computer"
		echo 	"/bg [PATH]	/base:groups [PATH]		Defines the search path for groups"
		echo 	""
		echo 	"The search path must be a valid LDAP-Path (e.g. OU=Clients,DC=domain,DC=com)"
		echo 	""
		exit 0
	}
	elseif ($args[$i] -eq "/ii" -OR $args[$i] -eq "/include-ignored"){ 
		$skipNeverDisableObjects = $False 
	}
	elseif ($args[$i] -eq "/su" -OR $args[$i] -eq "/scope:users"){ 
		$checkAll = $False
		$checkUsers = $True 
	}
	elseif ($args[$i] -eq "/sc" -OR $args[$i] -eq "/scope:computers"){ 
		$checkAll = $False
		$checkComputers = $True 
	}
	elseif ($args[$i] -eq "/sg" -OR $args[$i] -eq "/scope:groups"){ 
		$checkAll = $False
		$checkGroups = $True 
	}
	elseif ($args[$i] -eq "/b" -OR $args[$i] -eq "/base"){
		
		if( $userBasePathDefault -ne $True -OR $computerBasePathDefault -ne $TRUE){
			Write-Host "Base for user or computer already set" -ForegroundColor Red
			exit -1
		}

		if( ($i + 1) -ge $args.count){
			Write-Host "Base not found...." -ForegroundColor Red
			exit -1
		}
		
		$userBasePath = $args[$i + 1]
		$userBasePathDefault = $False

		$computerBasePath = $args[$i + 1]
		$computerBasePathDefault = $False
		
		$groupBasePath = $args[$i + 1]
		$groupBasePathDefault = $False
		
		$i++
	}
	elseif ($args[$i] -eq "/bu" -OR $args[$i] -eq "/base:users"){
		
		if($userBasePathDefault -ne $True){
			Write-Host "Base for user already set" -ForegroundColor Red
			exit -1
		}

		if( ($i + 1) -ge $args.count){
			Write-Host "Base not found...." -ForegroundColor Red
			exit -1
		}
		
		$userBasePath = $args[$i + 1]
		$userBasePathDefault = $False
		
		$i++
	}
	elseif ($args[$i] -eq "/bc" -OR $args[$i] -eq "/base:computers"){
		
		if($computerBasePathDefault -ne $TRUE){
			Write-Host "Base for computer already set" -ForegroundColor Red
			exit -1
		}

		if( ($i + 1) -ge $args.count){
			Write-Host "Base not found...." -ForegroundColor Red
			exit -1
		}

		$computerBasePath = $args[$i + 1]
		$computerBasePathDefault = $False
		
		$i++
	}
	elseif ($args[$i] -eq "/bg" -OR $args[$i] -eq "/base:groups"){
		
		if($computerBasePathDefault -ne $TRUE){
			Write-Host "Base for groups already set" -ForegroundColor Red
			exit -1
		}

		if( ($i + 1) -ge $args.count){
			Write-Host "Base not found...." -ForegroundColor Red
			exit -1
		}

		$groupBasePath = $args[$i + 1]
		$groupBasePathDefault = $False
		
		$i++
	}
}

if($checkAll -eq $True -OR $checkUsers -eq $True)
{
	echo ""
	echo "============================================================"
	echo "== Disable users"
	echo "============================================================"
	echo ""

	[array]$users = Get-AdUser -SearchBase $userBasePath -filter {(lastlogondate -notlike "*" -OR lastlogondate -le $90days) -AND (passwordlastset -le $90days) -AND (enabled -eq $True)} -Properties lastlogondate, passwordlastset, memberof
	if($users -ne $null){
		[array]$usersNotInGroup = $users | Where-Object { -not $_.memberof.contains($groupNotDisable) } | Sort-Object -Property Name
		if( $usersNotInGroup.length -ne 0 )
		{
			Foreach ($user in $usersNotInGroup)
			{				
				# Output the information
				$user | select Name, DistinguishedName
				
				# Disable
				#$user | Disable-ADAccount
			}
		}
		Else {
			echo "Nothing to disable"
		}

		[array]$usersInGroup = $users | Where-Object { $_.memberof.contains($groupNotDisable) } | Sort-Object -Property Name
		if( $usersInGroup.length -ne 0 )
		{
			echo ""
			if ( $skipNeverDisableObjects -eq $False )
			{
				echo "=============="
				echo "== Hidden"
				echo ""
			
				Foreach ($user in $usersInGroup)
				{	
					# Output the information
					$user | select Name, DistinguishedName
				}
			}
			Else {
				$usersCount = $usersInGroup.length
				echo "$usersCount users hidden"
			}
		}
	}
	else {
		Write-Host "No users found (please check your search path)" -ForegroundColor Yellow
	}
}

if($checkAll -eq $True -OR $checkComputers -eq $True)
{
	echo ""
	echo "============================================================"
	echo "== Disable computers"
	echo "============================================================"
	echo ""

	[array]$computers = Get-ADComputer -SearchBase $computerBasePath -filter {(lastlogondate -notlike "*" -OR lastlogondate -le $90days) -AND (passwordlastset -le $90days) -AND (enabled -eq $True)} -Properties lastlogondate, passwordlastset, memberof
	if($computers -ne $null){
		[array]$computersNotInGroup = $computers | Where-Object { -not $_.memberof.contains($groupNotDisable) } | Sort-Object -Property Name
		if( $computersNotInGroup.length -ne 0 )
		{
			Foreach ($computer in $computersNotInGroup)
			{			
				# Output the information
				$computer | select Name, DistinguishedName
				
				# Disable
				#$computer | Disable-ADComputer
			}
		}
		Else {
			echo "Nothing to disable"
		}

		[array]$computersInGroup = $computers | Where-Object { $_.memberof.contains($groupNotDisable) } | Sort-Object -Property Name
		if( $computersInGroup.length -ne 0 )
		{
			echo ""
			if ( $skipNeverDisableObjects -eq $False )
			{
				echo "=============="
				echo "== Hidden"
				echo ""
			
				Foreach ($computer in $computersInGroup)
				{	
					# Output the information
					$computer | select Name, DistinguishedName
				}
			}
			Else {
				$computersCount = $computersInGroup.length
				echo "$computersCount computers hidden"
			}
		}
	}
	else {
		Write-Host "No computers found (please check your search path)" -ForegroundColor Yellow
	}
}

if($checkAll -eq $True -OR $checkGroups -eq $True)
{
	echo ""
	echo "============================================================"
	echo "== Disable groups"
	echo "============================================================"
	echo ""

	[array]$groups = Get-ADGroup -SearchBase $groupBasePath -Filter * -Properties Members | where {-not $_.members}
	if($groups -ne $null){
		[array]$groupsNotInGroup = $groups | Where-Object { -not $_.memberof.contains($groupNotDisable) } | Sort-Object -Property Name
		if( $groupsNotInGroup.length -ne 0 )
		{
			Foreach ($group in $groupsNotInGroup)
			{	
				# Output the information
				$group | select Name, DistinguishedName
				
				# Disable
				#$group | Disable-ADGroup
			}
		}
		Else {
			echo "Nothing to disable"
		}

		[array]$groupsInGroup = $groups | Where-Object { $_.memberof.contains($groupNotDisable) } | Sort-Object -Property Name
		if( $groupsInGroup.length -ne 0 )
		{
			echo ""
			if ( $skipNeverDisableObjects -eq $False )
			{
				echo "=============="
				echo "== Hidden"
				echo ""
			
				Foreach ($group in $groupsInGroup)
				{	
					# Output the information
					$group | select Name, DistinguishedName
				}
			}
			Else {
				$groupsCount = $groupsInGroup.length
				echo "$groupsCount groups hidden"
			}
		}
	}
	else {
		Write-Host "No groups found (please check your search path)" -ForegroundColor Yellow
	}
}

echo ""