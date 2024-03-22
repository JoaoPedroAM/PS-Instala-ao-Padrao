# Checa se o powershell foi inicializado como admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # Se não, checa 
    Start-Process powershell -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -admin' -f ($myinvocation.MyCommand.Definition))
    exit
}


function InstallUpdateUtility {
    param (
        [string]$brand
    )

    switch ($brand) {
        "1" {
            Write-Output "Installing Lenovo System Update..."
            winget install -e --id Lenovo.SystemUpdate
        }
        "2" {
            Write-Output "Installing Dell Command Update..."
            winget install -e --id Dell.CommandUpdate
        }
        default {
            Write-Output "Unknown brand. Skipping..."
        }
    }
}

# Instala o winget 
function Install-WingetIfMissing {
    # Check if Winget is already installed
    if (Test-Path ~\AppData\Local\Microsoft\WindowsApps\winget.exe) {
      Write-Host "Winget já instalado, pulando instalação."
    } else {
      Write-Host "Winget não encontrado, instalando..."
      $progressPreference = 'silentlyContinue'
      Write-Information "Baixando winget e suas dependecias..."
  
      # Download and install dependencies silently
      Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -UseBasicParsing
      Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx -UseBasicParsing
      Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx -OutFile Microsoft.UI.Xaml.2.8.x64.appx -UseBasicParsing
  
      # Install the downloaded packages
      Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx -ErrorAction SilentlyContinue
      Add-AppxPackage Microsoft.UI.Xaml.2.8.x64.appx -ErrorAction SilentlyContinue
      Add-AppxPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -ErrorAction SilentlyContinue
  
      # Check if Winget installation was successful
      if (Test-Path ~\AppData\Local\Microsoft\WindowsApps\winget.exe) {
        Write-Host "Winget installation successful!"
  
        # Configure Winget to automatically accept source agreements
        $configPath = [Environment]::GetFolderPath("LocalApplicationData") + "\Microsoft\Winget\winget.config"
        if (!(Test-Path $configPath)) {
          New-Item $configPath -ItemType File
        }
        $configContent = Get-Content $configPath -Raw
        if ($configContent -notmatch '"autoAcceptAgreements": true') {
          Add-Content $configPath '"experimental": { "msstore": { "autoAcceptAgreements": true } }'
        }
        Write-Host "Winget configured for automatic agreement acceptance."
      } else {
        Write-Error "Winget installation failed!"
      }
    }
  }
  
  # Call the function to check and install Winget
  Install-WingetIfMissing
  
  

#Decide a marca da maquina
do{
    Write-Host "Escolha a marca da sua maquina:"
    Write-Host "1. Lenovo"
    Write-Host "2. Dell"
    Write-Host "3. Outros"
    $brandNumber = Read-Host "Entre com algum dos números (1, 2, 3):"
} until ($brandNumber -eq "1" -or $brandNumber -eq "2" -or $brandNumber -eq "3")

# Instala o app de update com base na marca selecionada
InstallUpdateUtility -brand $brandNumber



winget install 7-zip -q
winget install Adobe.Acrobat.Reader.64-bit -q
winget install Mozilla.Firefox.ESR -q
winget install Microsoft.Teams -q
winget install Oracle.JavaRuntimeEnvironment -q
winget install Notepad++.Notepad++ -q

