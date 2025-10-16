Param(
  [Parameter(Mandatory=$true, Position=0)]
  [string]$ProtocolUrl
)

# Allow TLS 1.2+
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

Function Show-Info([string]$msg){
  try {
    Add-Type -AssemblyName System.Windows.Forms | Out-Null
    [System.Windows.Forms.MessageBox]::Show($msg, "ArleWorld", 0, [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
  } catch {}
}

Function Show-Error([string]$msg){
  try {
    Add-Type -AssemblyName System.Windows.Forms | Out-Null
    [System.Windows.Forms.MessageBox]::Show($msg, "ArleWorld - Erro", 0, [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
  } catch {}
}

try {
  # Parse query: arleworld://?u=<url>&n=<filename>
  if ($ProtocolUrl -match "\?(.+)$") {
    $qs = $Matches[1]
  } else {
    throw "URL do protocolo inválida."
  }

  $params = @{}
  foreach($pair in $qs -split "&"){
    if($pair -match "="){
      $k,$v = $pair -split "=",2
      $params[$k] = [uri]::UnescapeDataString($v)
    }
  }

  $url = $params['u']
  if ([string]::IsNullOrWhiteSpace($url)) { throw "Parâmetro 'u' (URL) ausente." }
  $name = $params['n']
  if ([string]::IsNullOrWhiteSpace($name)) {
    $name = [System.IO.Path]::GetFileName((New-Object System.Uri($url)).AbsolutePath)
    if ([string]::IsNullOrWhiteSpace($name)) { $name = "mundo.mcworld" }
  }

  $dir = Join-Path $env:TEMP "ArleWorld"
  if (!(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  $dst = Join-Path $dir $name

  $ProgressPreference = 'SilentlyContinue'
  Invoke-WebRequest -Uri $url -OutFile $dst -UseBasicParsing

  if (!(Test-Path $dst)) { throw "Falha ao baixar o arquivo." }

  # Abre o .mcworld com o app padrão (Minecraft/Education)
  Start-Process -FilePath $dst | Out-Null

} catch {
  Show-Error("Não foi possível abrir o mundo automaticamente.`n`nDetalhes: $($_.Exception.Message)")
  exit 1
}
exit 0
