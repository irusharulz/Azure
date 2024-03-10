# Azure VM Tag Removal Script

## Overview
This PowerShell script connects to Azure, removes specified tags from VMs, their OS disks, and data disks, and logs activities to "RemoveAzureVMTagging.log".

## Usage
1. **Connect to Azure:** Authenticate with your Azure account.

2. **Select Subscription:** Enter the Subscription ID.

3. **Provide VM List:** Input the path to a file containing VM names.

4. **Specify Tag to Remove:** Enter tag name and value.

5. **Execution:** Script iterates over VMs, removes tags, and logs outcomes.

## Logging
All actions and results are logged to "RemoveAzureVMTagging.log" with timestamps.

## Prerequisites
- PowerShell with Azure modules.
- Azure account with correct permissions.

## Notes
- Author: Irusha Malalgoda
- Last Updated: 2024-03-10
- Version: 1.0
