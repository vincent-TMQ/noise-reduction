!macro customInstall
  ; Initialize variables
  Var /GLOBAL VBCableInstalled
  Var /GLOBAL OriginalPlaybackDevice
  Var /GLOBAL OriginalRecordingDevice
  StrCpy $VBCableInstalled "false"

  ; Save current default audio devices
  nsExec::ExecToStack 'powershell -command "(Get-AudioDevice -Playback).Name"'
  Pop $0
  Pop $OriginalPlaybackDevice
  nsExec::ExecToStack 'powershell -command "(Get-AudioDevice -Recording).Name"'
  Pop $0
  Pop $OriginalRecordingDevice

  ; Check if VB-Cable is already installed
  ReadRegStr $0 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\VB-Audio Virtual Cable" "UninstallString"
  ${If} $0 != ""
    DetailPrint "VB-Cable is already installed. Skipping installation."
  ${Else}
    ; Run VB-Cable installer
    DetailPrint "Installing VB-Cable..."
    ExecWait '"$INSTDIR\resources\vbcable\VBCABLE_Setup_x64.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART' $0
    ${If} $0 != 0
      DetailPrint "VB-Cable installation failed with exit code $0"
      MessageBox MB_OK|MB_ICONEXCLAMATION "VB-Cable installation encountered an issue (Error code: $0). You may need to install it manually later. Please check the application logs for more details."
    ${Else}
      DetailPrint "VB-Cable installed successfully"
      StrCpy $VBCableInstalled "true"
    ${EndIf}
  ${EndIf}
  
  ; Restore original default audio devices using PowerShell script
  DetailPrint "Restoring original audio settings..."
  nsExec::ExecToStack 'powershell -ExecutionPolicy Bypass -File "$INSTDIR\resources\restore_audio_settings.ps1" "$OriginalPlaybackDevice" "$OriginalRecordingDevice"'
  Pop $0
  Pop $1
  DetailPrint "PowerShell Output: $1"
  ${If} $0 != 0
    DetailPrint "Error restoring audio settings. Exit code: $0"
  ${EndIf}

  ; Show restart message at the end of installation
  ${If} $VBCableInstalled == "true"
    MessageBox MB_OK|MB_ICONINFORMATION "Installation completed successfully. To ensure all components (including VB-Cable) work correctly, please restart your computer before using the application."
  ${Else}
    MessageBox MB_OK|MB_ICONINFORMATION "Installation completed. You can now use the application."
  ${EndIf}
!macroend

; The uninstall macro remains unchanged
!macro customUnInstall
  ; Prompt user before uninstalling VB-Cable
  MessageBox MB_YESNO "Do you want to uninstall VB-Cable as well?" IDYES uninstall IDNO skip_uninstall
  uninstall:
    DetailPrint "Uninstalling VB-Cable..."
    ExecWait '"$INSTDIR\resources\vbcable\VBCABLE_Setup_x64.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /UNINSTALL' $0
    ${If} $0 != 0
      DetailPrint "VB-Cable uninstallation failed with exit code $0"
      MessageBox MB_OK|MB_ICONEXCLAMATION "VB-Cable uninstallation encountered an issue. You may need to uninstall it manually later."
    ${Else}
      DetailPrint "VB-Cable uninstalled successfully"
      MessageBox MB_OK|MB_ICONINFORMATION "VB-Cable has been uninstalled. To complete the process, please restart your computer."
    ${EndIf}
  skip_uninstall:
!macroend