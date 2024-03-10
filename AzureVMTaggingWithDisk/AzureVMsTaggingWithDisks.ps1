<#
    Intro:
    This PowerShell script automates the tagging of Azure Virtual Machines (VMs) and their associated disks with specified metadata. Tagging VMs and resources in Azure aids in organizing, managing, and tracking resources effectively.

    Author:
    This script was authored by [Irusha Malalgoda], designed to streamline Azure VM tagging processes.

    Last Modified:
    The script was last modified on [2024-03-10], ensuring its relevance and efficiency in Azure resource management tasks.
#>

# Function to log messages to a log file
function LogMessage {
    param(
        [string]$Message
    )

    $LogPath = "AzureVMTagging.log"
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

# Print the count of assigned VMs
Write-Host "Number of Assigned VMs: $($VMs.Count)"
LogMessage "Count of the VMs going to tag: $($VMs.Count)"

Write-Host " "

# Set tags
$Tags = @{
    ($tagn = Read-Host "Enter the value for tag name:") = ($val = Read-Host "Enter the value for $($tagn) tag:")
}

Write-Host " "
# Output tags
Write-Host "Assigned Tags:"
LogMessage "Assigned Tags:"
foreach ($key in $Tags.Keys) {
    Write-Host "$key : $($Tags[$key])"
    LogMessage "$key : $($Tags[$key])"
}

# Tag VMs
foreach ($VM in $VMs) {
    $NewVM = Get-AzVM -Name $VM
    #Print Working on VM name & log
    Write-Host "Working on : $($NewVM.Name)" -ForegroundColor Blue
    LogMessage "Working on : $($NewVM.Name)"

    if ($NewVM) {
        #Setting Tag for the VM
        $VMTag = Update-AzTag -ResourceId $NewVM.Id -Tag $Tags -Operation Merge
        if ($VMTag) {
            Write-Host "Tagging operation successful for VM: $VM"
            LogMessage "Tagging operation successful for VM: $VM"
         } 
        else {
            Write-Host "Tag set unsuccessful on VM: $($NewVM.Name)"  -ForegroundColor Red
            LogMessage "Tag set unsuccessful on VM: $($NewVM.Name)" 
        }

        #Tagging OS Disk, Assume per vm have 1 OS disk & print disk name
        $ODisk = Get-AzDisk -ResourceGroupName $NewVM.ResourceGroupName -DiskName $NewVM.StorageProfile.OsDisk.Name
        Write-Host "Working on VM: $($NewVM.Name) in OS disk : $($ODisk.Name)"
        LogMessage "Working on VM: $($NewVM.Name) in OS disk : $($ODisk.Name)"
        $ODT = Update-AzTag  -ResourceId $ODisk.Id -Tag $Tags -Operation Merge
        if ($ODT) {
            Write-Host "Tag set successful on VM: $($NewVM.Name) in OS disk : $($ODisk.Name)"
            LogMessage "Tag set successful on VM: $($NewVM.Name) in OS disk : $($ODisk.Name)"
         } 
        else {
            Write-Host "Tag set unsuccessful on VM: $($NewVM.Name) in OS disk : $($ODisk.Name)"  -ForegroundColor Red
            LogMessage "Tag set unsuccessful on VM: $($NewVM.Name) in OS disk : $($ODisk.Name)"
        }

        #If Data disks presents & print disk names
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
            $DDT = Update-AzTag  -ResourceId $DD.Id -Tag $Tags -Operation Merge
            if ($ODT) {
                Write-Host "Tag set successful on VM: $($NewVM.Name) in Data disk : $($D.Name)"
                LogMessage "Tag set successful on VM: $($NewVM.Name) in Data disk : $($D.Name)"
            } else {
                Write-Host "Tag set unsuccessful on VM: $($NewVM.Name) in Data disk : $($D.Name)"  -ForegroundColor Red
                LogMessage "Tag set unsuccessful on VM: $($NewVM.Name) in Data disk : $($D.Name)"
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