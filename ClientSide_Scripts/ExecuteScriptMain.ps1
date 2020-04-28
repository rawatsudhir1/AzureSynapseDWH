# Block 1 :- Connet to Azure Subscription
    Connect-AzAccount
    #Add-AzureAccount #Selet account if you have multiple accounts in one subscription 
# End of Block 1

# Block 2 :- Create a New VM on Azure
    $ResourceGroupName ="XXXXXXXXX"
    $VMName = "XXXXXXXXXXX"
    $VMLocation = "EastUS"
    $VMSize = "Standard_F32s_v2" #Check for other VM sizes on Azure https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sizes
    $VMUsername="XXXXXXXX"
    $VMPassword=ConvertTo-SecureString Password@123 -AsPlainText -Force
    $VirtualNetworkName = "XXXXXXXVnet"
    $SubnetName = "XXXXXXXXXXX"
    $PublicIpAddress="XXXXXXXXXXXXXXXX"
    $SecurityGroupName = "XXXXXXXXXXX"
    $ImageName = "MicrosoftWindowsDesktop:Windows-10:19h1-pro-gensecond:18362.720.2003120536"

    New-AzVm `
                -ResourceGroupName $ResourceGroupName `
                -Name $VMName `
                -Location $VMLocation `
                -VirtualNetworkName $VirtualNetworkName `
                -SubnetName $SubnetName `
                -SecurityGroupName $SecurityGroupName `
                -PublicIpAddressName $PublicIpAddress `
                -Image $ImageName `
                -Credential $cred `
                -OpenPorts 3389
             
# End of Block 2


# Block 3 :- Install and configure software
    $StorageAccountName= "XXXXXXXXXXX" 
    $StorageAccountKey= "XXXXXXXXXXXXXXXXXXXXXXXXXX"
    $fileUri = @("https://XXXXXXX.blob.core.windows.net/scripts/swInstall1.ps1",
    "https://XXXXXXXXXXX.blob.core.windows.net/scripts/swInstall2.ps1",
    "https://XXXXXXXXXXXX.blob.core.windows.net/scripts/MoveAJmeter.ps1",
    "https://XXXXXXXXXXXXXX.blob.core.windows.net/scripts/Moveloadtest.ps1")

    $settings = @{"fileUris" = $fileUri};
    $VMLocation = "East US"
    $protectedSettings = @{"storageAccountName" = $storageAcctName; "storageAccountKey" = $storageKey; "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File swInstall1.ps1"};
    Set-AzVMExtension -ResourceGroupName $ResourceGroupName `
        -Location $VMLocation `
        -VMName $VMName `
        -Name "SetupLoadMachine" `
        -Publisher "Microsoft.Compute" `
        -ExtensionType "CustomScriptExtension" `
        -TypeHandlerVersion "1.10" `
        -Settings $settings    `
        -ProtectedSettings $protectedSettings

# End of Block 3 

# Block 4 # Restart VM after s/w installation 
    Restart-AzVM -ResourceGroupName $ResourceGroupName -Name  $VMName
# End of Block 4 

# Block 5 :- invoke script 
    Invoke-AzVMRunCommand -ResourceGroupName $ResourceGroupName -VMName $VMName -CommandId 'RunPowerShellScript' -ScriptPath 'D:\Work\WVDesktop\BlogPost\SynapseDWH\AzureSynapseDWH\Scripts\EastRunloadtest.ps1' 
# End of Block 5

# OPTIONAL Remove Resource Group Once perf testing is done. 
    Remove-AzResourceGroup -Name "sudhirawDWH"
# END

