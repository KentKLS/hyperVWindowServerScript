$VMname= "VM-TEST"
$VMpath = "D:\VM"
$VHDpath = "D:\VM\VM-TEST\VM-TEST-C.vhdx"
$VMswitch = "KentInternal"
$ISOPath = "C:\Users\quentin.sirjean\Downloads\SERVER_EVAL_x64FRE_en-us.iso"

New-VM -Name $VMname  -Path $VMpath -MemoryStartupBytes 4GB -NewVHDPath $VHDpath  -NewVHDSizeBytes 30GB -Generation 2 -Switch $VMswitch  -BootDevice CD 

Add-VMDvdDrive -VMName $VMName -Path $ISOPath


Start-VM -Name $VMName