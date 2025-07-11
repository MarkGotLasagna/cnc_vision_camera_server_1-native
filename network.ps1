################################################################## NETWORK CONFIG FOR WINDOWS
# This script auto-elevates to admin privileges to set the selected network adapter properties.
# By default, Windows (host) manages peers connected to the device (guests) using its own logic, 
# so we need this script to set a static IP address for the adapter, so that a (ssh) tunnel 
# can be established to develop on the Pi4.
##################################################################

#┌───────────────────┐         ┌──────────────────┐                          
#│Elevate Powershell │         │ List available   │                       ┌─┐
#│to Admin privileges├────────►│ Network Adapters │                       │A│
#└───────────────────┘         └────────┬─────────┘                       │P│
#                                       │                    ┌───────────►│P│
#       ┌───────────────────────────────┘                    │            │L│
#┌──────▼─────────┐                                          │            │Y│
#│Select          │       ┌────────────────┐         ┌───────┼─────────┐  └─┘
#│Network Adapter ┼───────►Input IP Address┼────────►│Input Subnet Mask│     
#│(1, 2, 3, ecc.) │       └────────────────┘         └─────────────────┘     
#└────────────────┘                                                          

### AUTO-ELEVATE LOGIC
# Run this if shell not opened with admin privileges
# * VC Code will fail executing this script if not run as admin (Powershell extension)
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {

    Write-Host "This script requires admin privileges.`nContinue? (Y/N)" -ForegroundColor Yellow

    $confirmation = Read-Host
    if ($confirmation -eq 'Y') {
        Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    }
    exit
}

### CONFIG FILE SETUP
$saveFile = "network_config.toml"

### LOAD PREVIOUSLY SELECTED NETWORK ADAPTER (if exists)
if (Test-Path $saveFile) {
    $toml = Get-Content $saveFile -Raw
    if ($toml -match "adapter\s*=\s*'([^']+)'") {
        $adapterName = $matches[1]
        Write-Host "Using previously selected adapter: $adapterName"
    } else {
        Write-Host "Failed to parse adapter name from config." -ForegroundColor Red
        Remove-Item $saveFile
        exit
    }
} else {
    # List adapters and select one
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } 
    Write-Host "Available network adapters:`n"
    for ($i = 0; $i -lt $adapters.Count; $i++) {
        Write-Host "$i) $($adapters[$i].Name) - $($adapters[$i].InterfaceDescription)"
    }
    $selection = Read-Host "`nEnter the number of the adapter to select"
    if ($selection -match '^\d+$' -and $selection -lt $adapters.Count) {
        $adapterName = $adapters[$selection].Name
        @"
[network]
adapter = '$adapterName'
"@ | Out-File -Encoding utf8 $saveFile
    } else {
        Write-Host "Invalid selection." -ForegroundColor Red
        exit
    }
}

### READ IP & SUBNETMASK
$ipAddress = Read-Host "Enter static IPv4 address (e.g. 192.168.137.1)"
$subnetMask = Read-Host "Enter subnet mask (e.g. 255.255.255.0)"

### CONVERT SUBNETMASK (CIDR)
function Convert-SubnetToPrefix($mask) {
    $binary = ($mask -split '\.') | ForEach-Object {
        [Convert]::ToString($_, 2).PadLeft(8, '0')
    }
    return ($binary -join '').ToCharArray() | Where-Object { $_ -eq '1' } | Measure-Object | Select-Object -ExpandProperty Count
}

$prefixLength = Convert-SubnetToPrefix $subnetMask

### APPLY STATIC IP SETTINGS
try {
    Write-Host "`nApplying static IP configuration..." -ForegroundColor Cyan

    Set-NetIPInterface -InterfaceAlias $adapterName -Dhcp Disabled # Disable DHCP

    # Remove previous IP addresses (clean up just in case)
    Get-NetIPAddress -InterfaceAlias $adapterName -AddressFamily IPv4 |
        Remove-NetIPAddress -Confirm:$false -ErrorAction SilentlyContinue

    # Set static IP without default gateway
    New-NetIPAddress -InterfaceAlias $adapterName `
                    -IPAddress $ipAddress `
                    -PrefixLength $prefixLength

    # Set DNS (optional: use Google & Cloudflare)
    # This is done by default from the Pi4's DHCP server config
    # Set-DnsClientServerAddress -InterfaceAlias $adapterName -ServerAddresses ("8.8.8.8", "1.1.1.1")

    Write-Host "`n IP configuration applied successfully to '$adapterName'" -ForegroundColor Green
    Write-Host "   IP: $ipAddress/$prefixLength"
} catch {
    Write-Host "Failed to apply IP settings: $_" -ForegroundColor Red
}
