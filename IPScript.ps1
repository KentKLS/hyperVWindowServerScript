$ip_address = (Get-VM -Name $VMname | Get-VMNetworkAdapter).IPAddresses | Select-String -Pattern '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' | ForEach-Object {
    $_.Matches.Value
}