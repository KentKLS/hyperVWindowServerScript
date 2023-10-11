#Ci-dessous paramètre nécessaire a la création de la VM
$VMname = "VM-TEST-H"
$VMpath = "D:\VM"
$VHDpath = "D:\VM\VM-TEST\VM-TEST-H.vhdx"
$VMswitch = "Default Switch"
$VMswitch1 = "KentInternal"
$ISOPath = "C:\Users\quentin.sirjean\Downloads\SERVER_EVAL_x64FRE_en-us.iso"
$unnatendPath = "C:\Users\quentin.sirjean\testPWScript\testUnattend.xml"
$username = 'Administrator'
$password = 'vagrant'

#Under = params used in the Convert-WindowsImage Command
$convertParams = @{
    SourcePath        = $ISOPath
    SizeBytes         = 30GB
    Edition           = 2
    VHDFormat         = 'VHDX'
    VHDPath           = $VHDpath
    VHDType           = 'Dynamic'
    VHDPartitionStyle = 'GPT'
    UnattendPath      = $unnatendPath
}
#A function that wait for the VM to be booted to instance a PSSession with said VM
function Connect-To-VM {
    param (
        [string]$VMName,
        [string]$username,
        [string]$password
    )

    $pass = ConvertTo-SecureString $password -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential($username, $pass)

    do {
        $result = New-PSSession -VMName $VMName -Credential $cred -ErrorAction SilentlyContinue

        if (-not $result) {
            Write-Verbose "Waiting for connection with '$VMName'..."
            Start-Sleep -Seconds 1
        }
    } while (-not $result)

    $result
}

#line creating a new VM 
New-VM -Name $VMname  -Path $VMpath -MemoryStartupBytes 4GB -NewVHDPath $VHDpath  -NewVHDSizeBytes 30GB -Generation 2 -Switch $VMswitch

#Adding a dvd drive to the VM containing the ISO File of the OS you wanna install  
Add-VMDvdDrive -VMName $VMName -Path $ISOPath

#Convert WindowsImage create a "new" vhdx combining the VHD created with the VM and the Unnatend file to create a VHD with the OS already fully installed
#Need to have Hyper-ConvertImage Module Enabled (https://www.powershellgallery.com/packages/Hyper-ConvertImage/10.2) 
Convert-WindowsImage @convertParams

#Start the VM
Start-VM -Name $VMName

#Call to the function Connect-To-VM 
$session = Connect-To-VM -VMName $VMname -username $username -password $password

#Using the session created before to Invoke Command on the VM (the command are to enable IIS and download mariaDB and other dependancies)
Invoke-Command -Session $session { 

    Set-ExecutionPolicy Bypass -Scope Process
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServer
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-CommonHttpFeatures
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpErrors
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpRedirect
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationDevelopment
    Enable-WindowsOptionalFeature -online -FeatureName NetFx4Extended-ASPNET45
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-NetFxExtensibility45
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-HealthAndDiagnostics
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpLogging
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-LoggingLibraries
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-RequestMonitor
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpTracing
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-Security
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-RequestFiltering
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-Performance
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerManagementTools
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-IIS6ManagementCompatibility
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-Metabase
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementConsole
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-BasicAuthentication
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-WindowsAuthentication
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-StaticContent
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-DefaultDocument
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebSockets
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationInit
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIExtensions
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIFilter
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpCompressionStatic
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET45

    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    # Install soft
    choco install 7zip -y
    choco install mariadb.install -y
    choco install mariadb
    choco install iis.administration -y
    choco install php-manager -y


}


