#Spencer Day
#10/26/22
#This is a Powershell script to delete users, based on unique ID, from the Vera
#admin portal.

#get the authorization tokenn and set it in the header
$auth = Read-Host "Enter the authroization code: start with Basic"
$headers = @{
	Authorization=$auth
}

#location of the file with user ID's to delete.
#This needs to be updated for each person
#$file_data = Get-Content C:\Users\212806585\Desktop/delete.txt
$file_data = Get-Content ./delete.txt

#Figure out how many lines(people) need to be deleted. 
#This length is used in the for loop
#$file_data.Length
$arr = $file_data -is [system.array]
if ($arr -eq 'True')
{
	$length=$file_data.Length
}

elseif ($file_data)
{
	$length=1
}

#There is no one to delete
else
{
	Write-Output "There are no users listed to delete"
	Read-Host "Press Enter to close this window"
	Exit
}

#initialize array for users that were not deleted
$user=@()
$Fail='False'

for (($i=0); $i -lt $length; $i++)
{
	if ($length -eq 1)
	{
		$url = 'https://aviation.vera.gepower.com/api/user/'+ $file_data
	}
	else
	{
		$url = 'https://aviation.vera.gepower.com/api/user/'+ $file_data[$i]
	}
	$response = try { Invoke-WebRequest -Method 'Delete' -Uri $url -Headers $headers } catch { $_.Exception.Response }
	$count++
	if ($response.StatusCode -ne 200)
	{
		$Fail="True"
		if ($length -eq 1)
		{
			$user=$user + $file_data
		}
		else
		{
			$user=$user + $file_data[$i]
		}
	}
		
}

#After attempting to delete users...

#Successfully deleted everyone (more than 1 person)
if ($count -gt 1 -And $Fail -eq 'False')
{
	Write-Output "All users are deleted"
}

#Successfully deleted the only person 
elseif ($count -eq 1 -And $Fail -eq 'False')
{
	Write-Output "User is deleted"
}

#Failed to delete the only person
elseif ($count -eq 1 -And $Fail -eq 'True')
{
	Write-Output "User " $user "could not be deleted"
}

#Failed to delete everyone
elseif ($count -gt 1 -And $Fail -eq 'True' -And $count -eq $user.Length)
{
	Write-Output "No users were deleted"
}

#Failed to delete more than one person
elseif ($count -gt 1 -And $Fail -eq 'True')
{
	Write-Output "All users were deleted except for "
	for (($x=0); $x -lt $user.Length; $x++)
	{
		$user[$x]
	}
}


Read-Host "Press Enter to close this window"


