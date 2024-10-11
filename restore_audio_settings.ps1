# restore_audio_settings.ps1

# Set execution policy and install necessary modules
Set-ExecutionPolicy Bypass -Scope Process -Force
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -ErrorAction SilentlyContinue
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name AudioDeviceCmdlets -Force -AllowClobber -ErrorAction SilentlyContinue
Import-Module AudioDeviceCmdlets

# Function to set default audio device
function Set-DefaultAudioDevice {
    param (
        [string]$DeviceType,
        [string]$OriginalDeviceName
    )
    
    $devices = Get-AudioDevice -List | Where-Object { $_.Type -eq $DeviceType }
    
    # First, try to find the original default device
    $defaultDevice = $devices | Where-Object { $_.Name -eq $OriginalDeviceName } | Select-Object -First 1
    
    # If original device not found, try to find a non-VB-Cable device that was previously default
    if (-not $defaultDevice) {
        $defaultDevice = $devices | Where-Object { $_.Default -and $_.Name -notlike "*VB-Audio*" } | Select-Object -First 1
    }
    
    # If still no device found, choose the first non-VB-Cable device
    if (-not $defaultDevice) {
        $defaultDevice = $devices | Where-Object { $_.Name -notlike "*VB-Audio*" } | Select-Object -First 1
    }
    
    if ($defaultDevice) {
        Set-AudioDevice -ID $defaultDevice.ID
        Write-Host "Set default $DeviceType device to: $($defaultDevice.Name)"
    } else {
        Write-Host "No suitable $DeviceType device found to set as default"
    }
}

# Get command line arguments
$originalPlaybackDevice = $args[0]
$originalRecordingDevice = $args[1]

# Set default playback device
Set-DefaultAudioDevice -DeviceType "Playback" -OriginalDeviceName $originalPlaybackDevice

# Set default recording device
Set-DefaultAudioDevice -DeviceType "Recording" -OriginalDeviceName $originalRecordingDevice

Write-Host "Audio device configuration completed."