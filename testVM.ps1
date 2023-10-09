#Ci-dessous paramètre nécessaire a la création de la VM
$VMname= "VM-TESTX"
$VMpath = "D:\VM"
$VHDpath = "D:\VM\VM-TEST\VM-TEST-X.vhdx"
$VMswitch = "Default Switch"
$ISOPath = "C:\Users\quentin.sirjean\Downloads\SERVER_EVAL_x64FRE_en-us.iso"
$unnatendPath = "C:\Users\quentin.sirjean\testPWScript\TestUna.xml"

#Under = params used in the Convert-WindowsImage Command
$convertParams = @{
    SourcePath          = $ISOPath
    SizeBytes           = 30GB
    Edition             = 2
    VHDFormat           = 'VHDX'
    VHDPath             = $VHDpath
    VHDType             = 'Dynamic'
    VHDPartitionStyle   = 'GPT'
    UnattendPath        = $unnatendPath
}

#line creating a new VM 
New-VM -Name $VMname  -Path $VMpath -MemoryStartupBytes 4GB -NewVHDPath $VHDpath  -NewVHDSizeBytes 30GB -Generation 2 -Switch $VMswitch

#Adding a dvd drive to the VM containing the ISO File of the OS you wanna install  
Add-VMDvdDrive -VMName $VMName -Path $ISOPath

#Convert WindowsImage create a "new" vhdx combining the VHD created with the VM and the Unnatend file to create a VHD with the OS already fully installed
Convert-WindowsImage @convertParams

#Start the VM
Start-VM -Name $VMName

#wait for a determined amount of time (time for your VM to boot)
Start-Sleep -Seconds 500