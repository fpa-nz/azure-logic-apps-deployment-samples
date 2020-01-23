<#
    .SYNOPSIS
        A bare test to show that items can be created. replace the logic in this powershell script to deploy whatever you need

    .PARAMETER project
        The name of the project this deployment is for

    .PARAMETER location
        The region or location name to use for the resource group and the resources in that group

    .PARAMETER environment
        The alphabetical character that identifies the deployment environment to use in the name for each resource that's created in the resource group. For example, values include "d" for development, "t" for test, "s" for staging, and "p" for production.

    .EXAMPLE
        Deploys a logic app to the "westus" region by using the default values.

        ./bare-test.ps1 -project sales-reporting -location westus -environment dev
#>

param(
    [Parameter(Mandatory = $True)]
    [string]
    $project,

    [Parameter(Mandatory = $False)]
    [string]
    $location = "australiaeast",

    [Parameter(Mandatory = $True)]
    [string]
    $environment
)

Function Get-ResourceGroupName {
    <#
        .SYNOPSIS
            Return the resource group name for the instance number that's passed as input.
    #>
        return ("{0}-{1}" -f $project, $environment) -replace "[^A-Za-z-0-9]", "-"
}

Function Check-ResourceGroup {
    <#
        .SYNOPSIS
            Check whether the resource group exists. If not, let us know.
    #>
    Param(
        [Parameter(Mandatory = $True, HelpMessage = "The name for the resource group to create, if not already existing")]
        [string]$resourceGroupName
    )
    
    Write-Host "Working with the project resource group name: '$resourceGroupName'"

    Write-Host "Checking whether the project resource group exists"
    $resourceGroup = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
    if (!$resourceGroup) {
		throw "We have a problem. The Resource Group for this project doesn't exist. So I can't use it :¨("
    }
    else {
        Write-Host "Using project resource group '$resourceGroupName'";
    }
}


#******************************************************************************
# Script body
# Execution begins here
#******************************************************************************

$resourceGroupName = Get-ResourceGroupName

Check-ResourceGroup -resourceGroupName $resourceGroupName;

$storageAccountName = "$($project)st$($environment)"
$storageAccountName = $storageAccountName.ToLower() -replace "[^A-Za-z0-9]", ""
Write-Host "Using storage account name $($storageAccountName)"

$storageAccount = New-AzStorageAccount -Name $storageAccountName -ResourceGroupName $resourceGroupName -Location $location  -SkuName Standard_LRS  -Kind StorageV2

Write-Host $storageAccount