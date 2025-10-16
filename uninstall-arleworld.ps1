# Remove o protocolo arleworld:// e os arquivos locais
try {
  Remove-Item -Path "HKCU:\Software\Classes\arleworld" -Recurse -Force -ErrorAction SilentlyContinue
  $targetDir = Join-Path $env:LOCALAPPDATA "ArleWorld"
  if (Test-Path $targetDir) { Remove-Item -Recurse -Force $targetDir }
  Add-Type -AssemblyName System.Windows.Forms | Out-Null
  [System.Windows.Forms.MessageBox]::Show("Desinstalação concluída.", "ArleWorld", 0, [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
  exit 0
} catch {
  Add-Type -AssemblyName System.Windows.Forms | Out-Null
  [System.Windows.Forms.MessageBox]::Show("Falha ao desinstalar: $($_.Exception.Message)", "ArleWorld - Erro", 0, [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
  exit 1
}
