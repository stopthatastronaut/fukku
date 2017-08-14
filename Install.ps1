Write-Host "Starting Fukku installation"


# generate the otp

$randompass = (-Join (((65..90) | % { [char]$_ }) + (0..9) + "!_$%-+".ToCharArray() | Get-Random -Count 32))



# create/update user account

if(-not (Get-LocalUser | ? { $_.Name -eq "fukkuuser" }))
{
    New-LocalUser fukkuuser -Password ($randompass | ConvertTo-SecureString -AsPlainText -force) -PasswordNeverExpires -Description "user for PowerShell.REST.API" -verbose 
}
else {
    # change password here
    Get-LocalUser fukkuuser | Set-LocalUser -Password ($randompass | ConvertTo-SecureString -AsPlainText -force) -verbose 
}

# remove fukku service

if(get-service| select-object { $_.Name -eq "DynamicPowerShellApi" } )
{
    & C:\fukku\DynamicPowerShellApi.Host.exe --uninstall-service 
}

# move the config file

cp c:\fukku\repo\DynamicPowerShellApi.Host.exe.config C:\fukku -Force -Verbose

# move the ScriptRepository

if(Test-Path C:\fukku\ScriptRepository)
{
    [IO.Directory]::Delete('C:\fukku\ScriptRepository', $true) # recognised powershell bug means Remove-item doesn't work
}

cp c:\fukku\repo\ScriptRepository c:\fukku -Recurse -Force -Verbose

# restart the fukku service

& C:\fukku\DynamicPowerShellApi.Host.exe --install-service --service-user ".\fukkuuser" --service-password $randompass

# test it's running

$state = Get-Service "DynamicPowerShellApi" | select-object -expand State 

Write-host "Current service state : $state"

# happy fun times to slack