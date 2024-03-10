# Azure Virtual Machine Tagging Automation Script

## Introduction
This PowerShell script automates the process of tagging Azure Virtual Machines (VMs) and their associated disks with specified metadata. Tagging VMs and resources in Azure aids in organizing, managing, and tracking resources effectively.

## Author
This script was authored by Irusha Malalgoda, designed to streamline Azure VM tagging processes.

## Last Modified
The script was last modified on 2024-03-10, ensuring its relevance and efficiency in Azure resource management tasks.

## Instructions for Use
1. **Connect to Azure Account:** 
    - The script connects to an Azure account. Ensure you have the necessary permissions and credentials set up to connect.

2. **Provide Subscription Details:** 
    - Enter the Subscription ID when prompted. The script allows selection from available subscriptions.

3. **Input VMs List File:** 
    - Enter the path to the file containing a list of VMs. The file should contain one VM name per line.

4. **Set Tags:** 
    - Specify the tag name and value. This script supports setting a single tag for all VMs.

5. **Execute the Script:** 
    - Run the script. It will iterate through the VMs, tagging each VM and its associated disks.

6. **Review Log File:** 
    - The script logs messages to "AzureVMTagging.log" for reference. Review this file to check for any errors or to track the execution progress.

## Notes
- This script assumes that the necessary Azure PowerShell modules are installed.
- Ensure that the Azure account used has the required permissions to manage VMs and their associated resources.
- Review and customize the script as needed for your specific tagging requirements or environment.
- Always test the script in a non-production environment before deploying it in a production environment.