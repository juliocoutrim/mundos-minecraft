# Instala o protocolo arleworld:// para acionar o launcher
Param(
  [string]$LauncherSourcePath = "$PSScriptRoot\launch-world.ps1"
)

try {
  $targetDir = Join-Path $env:LOCALAPPDATA "ArleWorld"
  if (!(Test-Path $targetDir)) { New-Item -ItemType Directory -Force -Path $targetDir | Out-Null }

  $launcherTarget = Join-Path $targetDir "launch-world.ps1"
  if (Test-Path $LauncherSourcePath) {
    Copy-Item -Force -Path $LauncherSourcePath -Destination $launcherTarget
  } else {
    throw "Arquivo launch-world.ps1 não encontrado. Coloque-o na mesma pasta deste instalador."
  }

  # Registra em HKCU (não requer admin)
  New-Item -Path "HKCU:\Software\Classes\arleworld" -Force | Out-Null
  New-ItemProperty -Path "HKCU:\Software\Classes\arleworld" -Name "URL Protocol" -Value "" -Force | Out-Null
  New-Item -Path "HKCU:\Software\Classes\arleworld\shell\open\command" -Force | Out-Null
  $cmd = 'powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "%LOCALAPPDATA%\ArleWorld\launch-world.ps1" "%1"'
  Set-ItemProperty -Path "HKCU:\Software\Classes\arleworld\shell\open\command" -Name '(default)' -Value $cmd

  Add-Type -AssemblyName System.Windows.Forms | Out-Null
  [System.Windows.Forms.MessageBox]::Show("Instalação concluída. Agora links arleworld:// podem abrir e importar o mundo automaticamente.", "ArleWorld", 0, [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
  exit 0
} catch {
  Add-Type -AssemblyName System.Windows.Forms | Out-Null
  [System.Windows.Forms.MessageBox]::Show("Falha ao instalar: $($_.Exception.Message)", "ArleWorld - Erro", 0, [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
  exit 1
}
