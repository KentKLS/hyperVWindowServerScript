#Test 

$VMname= "VM-TEST-Z"
$username ='administrator'
$pass = ConvertTo-SecureString "vagrant" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($userName, $pass)
do {
   $result = New-PSSession -VMName $VMName -Credential $cred 

    if (-not $result) {
        Write-Verbose "Waiting for connection with '$VMName'..."
        Start-Sleep -Seconds 1
    }
} while (-not $result)
$result