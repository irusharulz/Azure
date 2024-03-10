<#
.SYNOPSIS
This script connects to an Azure account, switches to a specified subscription, and removes specified tags from virtual machines (VMs), their OS disks, and data disks.

.DESCRIPTION
The script starts by connecting to an Azure account and switching to a specified subscription. It then prompts the user to provide a path to a file containing a list of VM names. After reading the VM names from the file, the script prompts the user to enter the name and value of the tag to be removed from the VMs.

After setting up the necessary parameters, the script iterates over each VM in the list, removing the specified tag from the VM, its OS disk, and any associated data disks if present. Progress and outcomes are logged to a file named "RemoveAzureVMTagging.log".

.PARAMETER None
This script does not accept any parameters. All inputs are gathered interactively during script execution.

.NOTES
Author: [Irusha Malalgoda]
Last modified: [2024-03-10]
Version: 1.0

#>

# Function to log messages to a log file
function LogMessage {
    param(
        [string]$Message
    )

    $LogPath = "RemoveAzureVMTagging.log"
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Format the log entry
    $LogEntry = "[ $TimeStamp ] $Message"

    # Write log entry to log file
    Add-Content -Path $LogPath -Value $LogEntry
}

Write-Host "Script execution started"
LogMessage "***Script execution started***"

# Connect to Azure Account
Connect-AzAccount
if ($?) {
    Write-Host "Successfully connected to Azure account." -ForegroundColor Green
    LogMessage "Successfully connected to Azure account."
} else {
    Write-Host  "Failed to connect to Azure account." -ForegroundColor Red
    LogMessage "Failed to connect to Azure account."
    exit
}

# Get Azure subscription
$Subscriptions = Get-AzSubscription
if ($Subscriptions) {
    Write-Host "Available Subscriptions:"
    $Subscriptions | Format-Table -Property Name, Id

    $SubscriptionId = Read-Host "Enter the Subscription ID:"
    $Context = Get-AzSubscription -SubscriptionId $SubscriptionId

    if ($Context) {
        Set-AzContext -SubscriptionId $SubscriptionId  > $null
        Write-Host "Subscription switched to: $($Context.Name)" -ForegroundColor Blue
        LogMessage "Subscription switched to: $($Context.Name)"
    } else {
        Write-Host "Invalid Subscription ID entered." -ForegroundColor Green Yellow
        LogMessage "Invalid Subscription ID entered."
        exit
    }
} else {
    Write-Host "No subscriptions found." -ForegroundColor Red
    LogMessage "No subscriptions found."
    exit
}

# Upload the VMs file to a known location
$filePath = Read-Host "Enter the path to the VMs list file (e.g., C:\path\to\VMlist.txt)"

# Read the VMs list file
$VMs = Get-Content -Path $filePath

# Print the count of VM list
Write-Host "Number of Assigned VMs: $($VMs.Count)"
LogMessage "Count of the VMs going to tag: $($VMs.Count)"

Write-Host " "

# Set tags
$Tags = @{
    ($tagn = Read-Host "Enter the tag name to delete:") = ($val = Read-Host "Enter the value for $($tagn) tag:")
}

Write-Host " "
# Output tags
Write-Host "Tag values to remove"
LogMessage "Tag values to remove"
foreach ($key in $Tags.Keys) {
    Write-Host "$key : $($Tags[$key])"
    LogMessage "$key : $($Tags[$key])"
}

#Remove Tag VMs
foreach ($VM in $VMs) {
    $NewVM = Get-AzVM -Name $VM
    #Print Working on VM name & log
    Write-Host "Working on : $($NewVM.Name)" -ForegroundColor Blue
    LogMessage "Working on : $($NewVM.Name)"

    if ($NewVM) {
        #Remove Tag for the VM
        $VMTag = Update-AzTag -ResourceId $NewVM.Id -Tag $Tags -Operation Delete
        if ($VMTag) {
            Write-Host "Tag removing operation successful for VM: $VM"
            LogMessage "Tag removing operation successful for VM: $VM"
         } 
        else {
            Write-Host "Tag removing operation unsuccessful for VM: $VM"  -ForegroundColor Red
            LogMessage "Tag removing operation unsuccessful for VM: $VM"
        }

        #Removing Tag on OS Disk, Assume per vm have 1 OS disk & print disk name
        $ODisk = Get-AzDisk -ResourceGroupName $NewVM.ResourceGroupName -DiskName $NewVM.StorageProfile.OsDisk.Name
        Write-Host "Working on VM: $($NewVM.Name) in OS disk : $($ODisk.Name)"
        LogMessage "Working on VM: $($NewVM.Name) in OS disk : $($ODisk.Name)"
        $ODT = Update-AzTag  -ResourceId $ODisk.Id -Tag $Tags -Operation Delete
        if ($ODT) {
            Write-Host "Tag removing successful on VM: $($NewVM.Name) in OS disk : $($ODisk.Name)"
            LogMessage "Tag removing successful on VM: $($NewVM.Name) in OS disk : $($ODisk.Name)"
         } 
        else {
            Write-Host "Tag removing unsuccessful on VM: $($NewVM.Name) in OS disk : $($ODisk.Name)"  -ForegroundColor Red
            LogMessage "Tag removing unsuccessful on VM: $($NewVM.Name) in OS disk : $($ODisk.Name)"
        }

        #Removing Tag on Data Disk,If Data disks presents & print disk names
        $DDisks = $NewVM.StorageProfile.DataDisks
        if($DDisks -eq $null){
            Write-Host "No data disk found in $($NewVM.Name)"
            LogMessage "No data disk found in $($NewVM.Name)"
        }
        else{
        foreach($D in $DDisks){
            $DD = Get-AzDisk -ResourceGroupName $NewVM.ResourceGroupName -DiskName $D.Name
            Write-Host "Working on VM: $($NewVM.Name) in Data disk : $($D.Name)"
            LogMessage "Working on VM: $($NewVM.Name) in Data disk : $($D.Name)"
            $DDT = Update-AzTag  -ResourceId $DD.Id -Tag $Tags -Operation Delete
            if ($ODT) {
                Write-Host "Tag removing successful on VM: $($NewVM.Name) in Data disk : $($D.Name)"
                LogMessage "Tag removing successful on VM: $($NewVM.Name) in Data disk : $($D.Name)"
            } else {
                Write-Host "Tag removing unsuccessful on VM: $($NewVM.Name) in Data disk : $($D.Name)"  -ForegroundColor Red
                LogMessage "Tag removing unsuccessful on VM: $($NewVM.Name) in Data disk : $($D.Name)"
            }
        }
    }

        
    } else {
        LogMessage "Failed to retrieve VM: $VM"
    }

    #Completed working on
    Write-Host "Completed Working on : $($NewVM.Name)" -ForegroundColor Blue
    LogMessage "Completed Working on : $($NewVM.Name)"
}

Write-Host "Script execution finished..."
LogMessage "***Script execution finished***"