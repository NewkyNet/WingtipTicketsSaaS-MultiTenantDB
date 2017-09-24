﻿# Script for provisioning and de-provisioning tenants in a multi-tenant database.

# IMPORTANT: Before provisioning tenants using this script ensure the catalog is initialized using 
# http://events.wtp-mt.<USER>.trafficmanager.net

# Parameters for scenarios #1 and #2, provision or deprovision a single tenant 
$TenantName = "Red Maple Racing" #  name of the venue to be added/removed as a tenant
$VenueType  = "motorracing" # valid types: blues, classicalmusic, dance, jazz, judo, motorracing, multipurpose, opera, rockmusic, soccer 
$PostalCode = "98052"

$Scenario = 1
<# Select the scenario to run
    #    Scenario
    1       Provision a tenant in the default multi-tenant database
    2       Provision a tenant in a new single-tenant database
    3       Remove a provisioned tenant
    4       Provision a batch of tenants
#>

## ------------------------------------------------------------------------------------------------

Import-Module "$PSScriptRoot\..\Common\CatalogAndDatabaseManagement" -Force
Import-Module "$PSScriptRoot\..\Common\SubscriptionManagement" -Force
Import-Module "$PSScriptRoot\..\WtpConfig" -Force
Import-Module "$PSScriptRoot\..\UserConfig" -Force

# Get Azure credentials if not already logged on,  Use -Force to select a different subscription 
Initialize-Subscription -NoEcho

### Provision a tenant in the default multi-tenant database
if ($Scenario -eq 1)
{
    New-Tenant `
        -TenantName $TenantName `
        -VenueType $VenueType `
        -PostalCode $PostalCode `
        -ErrorAction Stop `
        > $null

    Write-Output "Provisioning complete for tenant '$TenantName'"

    # Open the events page for the new venue
    Start-Process "http://events.wtp.$($wtpUser.Name).trafficmanager.net/$(Get-NormalizedTenantName $TenantName)"
    
    exit
}
#>

### Provision a tenant in a single-tenant database
if ($Scenario -eq 2)
{
    & $PSScriptRoot\New-TenantAndDatabase `
        -TenantName $TenantName `
        -VenueType $VenueType `
        -PostalCode $PostalCode `
        -ErrorAction Stop `
        > $null

    Write-Output "Provisioning complete for tenant '$TenantName'"

    # Open the events page for the new venue
    Start-Process "http://events.wtp.$($wtpUser.Name).trafficmanager.net/$(Get-NormalizedTenantName $TenantName)"
    
    exit
}

### Remove a provisioned tenant
if ($Scenario -eq 3)
{
    & $PSScriptRoot\Remove-ProvisionedTenant.ps1 -TenantName $TenantName 
    exit

}

### Provision a batch of tenants
if ($Scenario -eq 4)
{
    $config = Get-Configuration

    $tenantNames = $config.TenantNameBatch

    & $PSScriptRoot\New-TenantBatch.ps1 `
        -NewTenants $tenantNames 

    exit
} 

Write-Output "Invalid scenario selected"
              