$vbCableCount = (Get-WmiObject Win32_SoundDevice | Where-Object { $_.Name -like "*VB-Audio*" } | Measure-Object).Count
Write-Output $vbCableCount