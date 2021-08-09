$currentDateAsString = Get-Date -Format "yyyy-MM-dd"

for ( $i = 0; $i -lt $args.count; $i++ ) {
    if ($args[$i] -eq "/?"){
		echo ""
		echo "Allowed parameters:"
		echo "This script dont support arguments"
		echo ""
		exit 0
	}
}

echo ""
echo "============================================================"
echo "== Set 'Disabled At' to users"
echo "============================================================"
echo ""

$users = Get-AdUser -filter { (enabled -eq $False) } -Properties "ExtensionAttribute1" | Where-Object { ( -not ($_.ExtensionAttribute1 -match "Disabled At: [0-9]{4}\-[0-9]{2}\-[0-9]{2}")) -Or ( -not ($_.ExtensionAttribute1 -like "*") ) }
$users = $users | Sort-Object -Property Name
if( $users.length -ne 0 )
{
	Foreach ($user in $users)
	{	
		# Get name of user
		$name = $user.name
		$extensionAttribute = $user.ExtensionAttribute1
		
		# Output the user which will get disabled
		echo "User:  $name [$extensionAttribute]"
		
		# Set disable date
		$user | Set-AdUser -replace @{ExtensionAttribute1="Disabled At: $currentDateAsString"}
		
		# Disable user
		#$user | Disable-ADAccount
		
	}
}
Else {
	echo "Nothing to set 'Disabled At'"
}

echo ""
echo "============================================================"
echo "== Remove 'Disabled At' or invalid values from enabled users"
echo "============================================================"
echo ""

$users = Get-AdUser -filter { ExtensionAttribute1 -like "*" -AND (enabled -eq $True) }
$users = $users | Sort-Object -Property Name
if( $users.length -ne 0 )
{
	Foreach ($user in $users)
	{	
		# Get name of user
		$name = $user.name
		$extensionAttribute = $user.ExtensionAttribute1
		
		# Output the user which will get disabled
		echo "User:  $name [$extensionAttribute]"
		
		# Set disable date
		$user | Set-AdUser -clear ExtensionAttribute1
		
		# Disable user
		#$user | Disable-ADAccount
		
	}
}
Else {
	echo "Nothing to remove 'Disabled At'"
}

echo ""
echo "============================================================"
echo "== Set 'Disabled At' to computer"
echo "============================================================"
echo ""

$computers = Get-AdComputer -filter { (enabled -eq $False) } -Properties "ExtensionAttribute1" | Where-Object { ( -not ($_.ExtensionAttribute1 -match "Disabled At: [0-9]{4}\-[0-9]{2}\-[0-9]{2}")) -Or ( -not ($_.ExtensionAttribute1 -like "*") ) }
$computers = $computers | Sort-Object -Property Name
if( $computers.length -ne 0 )
{
	Foreach ($computer in $computers)
	{	
		# Get name of computer
		$name = $computer.name
		$extensionAttribute = $computer.ExtensionAttribute1
		
		# Output the computer which will get disabled
		echo "Computer:  $name [$extensionAttribute]"
		
		# Set disable date
		$computer | Set-AdComputer -replace @{ExtensionAttribute1="Disabled At: $currentDateAsString"}
		
		# Disable computer
		#$computer | Disable-AdComputer
		
	}
}
Else {
	echo "Nothing to set 'Disabled At'"
}

echo ""
echo "============================================================"
echo "== Remove 'Disabled At' or invalid values from enabled computers"
echo "============================================================"
echo ""

$computers = Get-AdComputer -filter { ExtensionAttribute1 -like "*" -AND (enabled -eq $True) }
$computers = $computers | Sort-Object -Property Name
if( $computers.length -ne 0 )
{
	Foreach ($computer in $computers)
	{	
		# Get name of user
		$name = $computer.name
		$extensionAttribute = $computer.ExtensionAttribute1
		
		# Output the computer which will get disabled
		echo "Computer:  $name [$extensionAttribute]"
		
		# Set disable date
		$computer | Set-AdComputer -clear ExtensionAttribute1
		
		# Disable computer
		#$computer | Disable-AdComputer
		
	}
}
Else {
	echo "Nothing to remove 'Disabled At'"
}

echo ""
echo "============================================================"
echo "== Set 'Disabled At' to groups"
echo "============================================================"
echo ""

$groups = Get-ADGroup -filter { (enabled -eq $False) } -Properties "ExtensionAttribute1" | Where-Object { ( -not ($_.ExtensionAttribute1 -match "Disabled At: [0-9]{4}\-[0-9]{2}\-[0-9]{2}")) -Or ( -not ($_.ExtensionAttribute1 -like "*") ) }
$groups = $groups | Sort-Object -Property Name
if( $groups.length -ne 0 )
{
	Foreach ($group in $groups)
	{	
		# Get name of group
		$name = $group.name
		$extensionAttribute = $group.ExtensionAttribute1
		
		# Output the group which will get disabled
		echo "Group:  $name [$extensionAttribute]"
		
		# Set disable date
		$group | Set-ADGroup -replace @{ExtensionAttribute1="Disabled At: $currentDateAsString"}
		
		# Disable group
		#$group | Disable-ADGroup
		
	}
}
Else {
	echo "Nothing to set 'Disabled At'"
}

echo ""
echo "============================================================"
echo "== Remove 'Disabled At' or invalid values from enabled group"
echo "============================================================"
echo ""

$groups = Get-ADGroup -filter { ExtensionAttribute1 -like "*" -AND (enabled -eq $True) }
$groups = $groups | Sort-Object -Property Name
if( $groups.length -ne 0 )
{
	Foreach ($group in $groups)
	{	
		# Get name of user
		$name = $group.name
		$extensionAttribute = $group.ExtensionAttribute1
		
		# Output the group which will get disabled
		echo "Group:  $name [$extensionAttribute]"
		
		# Set disable date
		$group | Set-ADGroup -clear ExtensionAttribute1
		
		# Disable group
		#$group | Disable-ADGroup
		
	}
}
Else {
	echo "Nothing to remove 'Disabled At'"
}